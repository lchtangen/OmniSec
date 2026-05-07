# NH_SETUP_VERSION: 2.0 default
# Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default
# Termux login profile for SSH and app sessions
# Ensures SSH starts with Termux paths, not Android/vendor toybox paths.

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
export PREFIX
export HOME="${HOME:-/data/data/com.termux/files/home}"
case ":$PATH:" in *":$PREFIX/bin:"*) ;; *) PATH="$PREFIX/bin:$PATH" ;; esac
case ":$PATH:" in *":$PREFIX/bin/applets:"*) ;; *) PATH="$PREFIX/bin/applets:$PATH" ;; esac
case ":$PATH:" in *":/system/bin:"*) ;; *) PATH="/system/bin:$PATH" ;; esac
export PATH
export LD_LIBRARY_PATH="$PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export TMPDIR="$PREFIX/tmp"
export LANG="${LANG:-en_US.UTF-8}"
export TERM="${TERM:-xterm-256color}"

mkdir -p "$TMPDIR" 2>/dev/null || true

# Termux login exports LD_PRELOAD for termux-exec. Over SSH this can leak into
# Android/vendor binaries and break commands such as /system/bin/ls.
if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ]; then
    unset LD_PRELOAD
fi

[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
