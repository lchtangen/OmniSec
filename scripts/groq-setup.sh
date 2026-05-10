#!/usr/bin/env bash
# Groq CLI Setup — configure API key and install working CLI
set -euo pipefail

OMNISEC_HOME="${OMNISEC_HOME:-$HOME/.omnisec}"
VENV="${VENV:-$OMNISEC_HOME/.venv}"
GROQ_BIN="${GROQ_BIN:-$HOME/.local/bin/groq}"

install_sdk() {
    if "$VENV/bin/python" -c "import groq" 2>/dev/null; then
        echo "[OK] groq SDK already installed"
    else
        echo "[install] groq SDK..."
        "$VENV/bin/pip" install groq 2>&1 | tail -1
    fi
}

create_wrapper() {
    cat > "$GROQ_BIN" <<-'WRAPPER'
#!/usr/bin/env bash
# groq CLI — uses groq Python SDK
VENV="${VENV:-$HOME/.omnisec/.venv}"
OMNISEC_HOME="${OMNISEC_HOME:-$HOME/.omnisec}"
CONFIG="$OMNISEC_HOME/config"

# Load API key from config if not set in env
if [[ -z "${GROQ_API_KEY:-}" && -f "$CONFIG" ]]; then
    source "$CONFIG" 2>/dev/null || true
fi

if [[ -z "${GROQ_API_KEY:-}" ]]; then
    echo "GROQ_API_KEY not set." >&2
    echo "Set it:  export GROQ_API_KEY='gsk_your_key'" >&2
    echo "Or run:  groq-setup.sh --set-key" >&2
    exit 1
fi

export GROQ_API_KEY

case "${1:-}" in
    --help|-h)
        echo "Usage: groq <prompt>"
        echo "       echo 'prompt' | groq"
        echo "       groq --model <model> <prompt>"
        echo ""
        echo "Models: llama3-70b, llama3-8b, mixtral-8x7b, gemma2-9b (default: llama3-70b)"
        exit 0
        ;;
    --version|-V)
        "$VENV/bin/python" -c "import groq; print(f'groq SDK {groq.__version__}')"
        exit 0
        ;;
esac

exec "$VENV/bin/python" -c "
import sys, os, json
from groq import Groq

client = Groq(api_key=os.environ['GROQ_API_KEY'])
model = 'llama3-70b-8192'

args = sys.argv[1:]
if args and args[0] == '--model':
    model_map = {
        'llama3-70b': 'llama3-70b-8192',
        'llama3-8b': 'llama3-8b-8192',
        'mixtral': 'mixtral-8x7b-32768',
        'gemma2': 'gemma2-9b-it',
        'gemma2-9b': 'gemma2-9b-it',
    }
    model = model_map.get(args[1], args[1])
    args = args[2:]

prompt = ' '.join(args) if args else sys.stdin.read()

if not prompt.strip():
    print('Usage: groq <prompt>  or  echo \"prompt\" | groq')
    sys.exit(1)

try:
    stream = client.chat.completions.create(
        model=model,
        messages=[{'role': 'user', 'content': prompt}],
        stream=True,
    )
    for chunk in stream:
        content = chunk.choices[0].delta.content or ''
        print(content, end='', flush=True)
    print()
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" "$@"
WRAPPER
    chmod +x "$GROQ_BIN"
    echo "[created] $GROQ_BIN"
}

set_key() {
    mkdir -p "$OMNISEC_HOME"
    CONFIG="$OMNISEC_HOME/config"
    echo ""
    echo "Enter your Groq API key (gsk_...):"
    read -r key
    if [[ -z "$key" ]]; then
        echo "no key entered" >&2; exit 1
    fi
    if grep -q 'GROQ_API_KEY' "$CONFIG" 2>/dev/null; then
        sed -i "s|GROQ_API_KEY=.*|GROQ_API_KEY=$key|" "$CONFIG"
    else
        echo "GROQ_API_KEY=$key" >> "$CONFIG"
    fi
    chmod 0600 "$CONFIG"
    echo "[saved] API key to $CONFIG"
}

test_key() {
    source "$OMNISEC_HOME/config" 2>/dev/null || true
    export GROQ_API_KEY="${GROQ_API_KEY:-}"
    if [[ -z "$GROQ_API_KEY" ]]; then
        echo "GROQ_API_KEY not configured" >&2; exit 1
    fi
    echo "Testing Groq API connection..."
    echo "Hello, respond with just the word 'ok'." | "$GROQ_BIN" 2>&1 | head -3
}

case "${1:-help}" in
    install)  install_sdk; create_wrapper ;;
    --set-key|set-key) set_key ;;
    test)     test_key ;;
    help|--help|-h)
        echo "Usage: groq-setup.sh {install|set-key|test}"
        echo "  install    Install SDK + create CLI wrapper"
        echo "  set-key    Store API key in ~/.omnisec/config"
        echo "  test       Test the API connection"
        ;;
    *) install_sdk; create_wrapper; echo ""; echo "Now run: groq-setup.sh set-key" ;;
esac
