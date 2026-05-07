#!/usr/bin/env python3
"""nh-agent — Autonomous reconnaissance agent with ReAct loop.
Runs inside Arch chroot, connects to local Ollama, executes security tools.
"""
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

REPORT_DIR = Path(os.environ.get("NH_AGENT_REPORT_DIR", "/home/archlinux/reports"))
REPORT_DIR.mkdir(parents=True, exist_ok=True)

OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://127.0.0.1:11434")
MODEL = os.environ.get("NH_AGENT_MODEL", "llama3.2:3b")
MAX_ITERATIONS = int(os.environ.get("NH_AGENT_MAX_ITER", 25))
TIMEOUT = int(os.environ.get("NH_AGENT_TIMEOUT", 120))

TOOLS = {
    "nmap": {
        "desc": "Port scanner and service detector",
        "args": "<target> [options]",
        "check": "nmap --version",
    },
    "whatweb": {
        "desc": "Web technology fingerprinting",
        "args": "<url>",
        "check": "whatweb --version",
    },
    "nikto": {
        "desc": "Web server vulnerability scanner",
        "args": "<url> [options]",
        "check": "nikto -Version",
    },
    "curl": {
        "desc": "HTTP client for raw requests",
        "args": "<url> [options]",
        "check": "curl --version",
    },
    "dig": {
        "desc": "DNS lookup utility",
        "args": "<domain> [type]",
        "check": "dig -v",
    },
    "nslookup": {
        "desc": "DNS query tool",
        "args": "<domain>",
        "check": "nslookup -version",
    },
    "ffuf": {
        "desc": "Web directory fuzzer",
        "args": "<url> [options]",
        "check": "ffuf -V",
    },
    "searchsploit": {
        "desc": "ExploitDB offline search",
        "args": "<search terms>",
        "check": "searchsploit --version",
    },
    "nuclei": {
        "desc": "Template-based vulnerability scanner",
        "args": "<target> [options]",
        "check": "nuclei -version",
    },
    "sqlmap": {
        "desc": "SQL injection detection and exploitation",
        "args": "<url> [options]",
        "check": "sqlmap --version",
    },
    "ping": {
        "desc": "ICMP echo to check host reachability",
        "args": "<host> [count]",
        "check": "ping -V",
    },
    "traceroute": {
        "desc": "Network path discovery",
        "args": "<host>",
        "check": "traceroute --version",
    },
    "whois": {
        "desc": "Domain registration info lookup",
        "args": "<domain>",
        "check": "whois --version",
    },
    "host": {
        "desc": "DNS lookup (simpler than dig)",
        "args": "<domain>",
        "check": "host -V",
    },
}

SYSTEM_PROMPT = """You are an autonomous reconnaissance agent running inside an Arch Linux ARM64 chroot on a rooted Android device. Your purpose is to help security professionals gather intelligence about targets.

You have access to the following tools:
{tool_descriptions}

You operate in a ReAct loop: Thought → Action → Observation → Thought...

When using tools, respond with exactly:
ACTION: tool_name|arg1 arg2 ...

When you have enough information to answer the user's goal, respond with:
FINAL: your comprehensive findings and analysis

Guidelines:
- Start with passive recon (whois, dig) before active scanning
- Be thorough but respect rate limits
- Report all findings including negative results
- If a tool is not available, note it and continue with available tools
- For web targets, start with whatweb/curl before nikto/ffuf
- Default to safe scanning options (avoid aggressive timing)
- Maximum {max_iter} tool iterations per session
"""


def ollama_request(prompt: str, system: str = None) -> str:
    data = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.1, "num_predict": 4096},
    }
    if system:
        data["system"] = system

    req = urllib.request.Request(
        f"{OLLAMA_HOST}/api/generate",
        data=json.dumps(data).encode(),
        headers={"Content-Type": "application/json"},
    )
    try:
        resp = urllib.request.urlopen(req, timeout=TIMEOUT)
        result = json.loads(resp.read())
        return result.get("response", "")
    except urllib.error.HTTPError as e:
        return f"ERROR: Ollama HTTP {e.code}: {e.read().decode()}"
    except Exception as e:
        return f"ERROR: {e}"


def check_tool(name: str) -> bool:
    info = TOOLS.get(name)
    if not info:
        return False
    check_cmd = info["check"]
    try:
        subprocess.run(
            check_cmd.split(),
            capture_output=True,
            timeout=10,
        )
        return True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def run_tool(command: str) -> str:
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
        )
        output = result.stdout.strip() or result.stderr.strip()
        if not output:
            return "(no output)"
        lines = output.split("\n")
        if len(lines) > 200:
            output = "\n".join(lines[:200]) + f"\n... (truncated, {len(lines)} total lines)"
        return output
    except subprocess.TimeoutExpired:
        return f"ERROR: Command timed out after {TIMEOUT}s"
    except Exception as e:
        return f"ERROR: {e}"


def get_tool_descriptions() -> str:
    lines = []
    for name, info in sorted(TOOLS.items()):
        available = "✓" if check_tool(name) else "✗"
        lines.append(f"  {available} {name}: {info['desc']}")
        lines.append(f"      Usage: {name} {info['args']}")
    return "\n".join(lines)


def extract_action(response: str) -> tuple:
    for line in response.strip().split("\n"):
        line = line.strip()
        if line.upper().startswith("ACTION:"):
            parts = line[7:].strip().split("|", 1)
            tool = parts[0].strip()
            args = parts[1].strip() if len(parts) > 1 else ""
            return tool, args
    return None, None


def has_final(response: str) -> bool:
    return "FINAL:" in response.upper()


def extract_final(response: str) -> str:
    for line in response.strip().split("\n"):
        if line.upper().startswith("FINAL:"):
            return line[6:].strip()
    return response


def save_report(goal: str, log: list, final: str):
    ts = time.strftime("%Y%m%d-%H%M%S")
    safe_name = "".join(c if c.isalnum() or c in "-_" else "_" for c in goal[:40])
    report_file = REPORT_DIR / f"recon-{safe_name}-{ts}.md"
    lines = [
        f"# Reconnaissance Report: {goal}",
        f"**Date:** {time.strftime('%Y-%m-%d %H:%M:%S')}",
        f"**Model:** {MODEL}",
        "",
        "## Session Log",
        "",
    ]
    for entry in log:
        if entry.startswith("  $ "):
            lines.append(f"```bash\n{entry.strip()}\n```")
        else:
            lines.append(entry)
    lines.extend(["", "## Final Findings", "", final])
    report_file.write_text("\n".join(lines))
    return report_file


def run_agent(goal: str):
    tool_desc = get_tool_descriptions()
    system = SYSTEM_PROMPT.format(
        tool_descriptions=tool_desc, max_iter=MAX_ITERATIONS
    )

    available = [n for n in TOOLS if check_tool(n)]
    missing = [n for n in TOOLS if not check_tool(n)]
    print(f"nh-agent v1.0 — Autonomous Recon Agent")
    print(f"Model: {MODEL}  |  Max iterations: {MAX_ITERATIONS}")
    print(f"Tools available: {len(available)}/{len(TOOLS)}")
    if missing:
        print(f"Tools missing: {', '.join(missing)}")
    print()
    print(f"Goal: {goal}")
    print(f"{'='*60}")
    print()

    context = f"User goal: {goal}\n\nAvailable tools (✓ installed, ✗ not installed):\n{tool_desc}\n\nBegin. First, think about what information you need and start with passive recon."
    log = []
    iteration = 0

    while iteration < MAX_ITERATIONS:
        iteration += 1
        print(f"\n── Iteration {iteration}/{MAX_ITERATIONS} ──")

        response = ollama_request(context, system)
        if response.startswith("ERROR:"):
            print(f"  {response}")
            break

        print(f"  Thought: {response[:300]}")
        log.append(f"### Iteration {iteration}")
        log.append(f"  {response}")

        if has_final(response):
            final = extract_final(response)
            print(f"\n{'='*60}")
            print(f"FINAL: {final}")
            report = save_report(goal, log, final)
            print(f"\nReport saved: {report}")
            return

        tool, args = extract_action(response)
        if not tool:
            print("  No action found, asking LLM to continue...")
            context += f"\n\n{response}\n\nPlease specify an ACTION or FINAL."
            continue

        if tool not in TOOLS:
            print(f"  Unknown tool: {tool}")
            context += f"\n\n{response}\n\nERROR: Tool '{tool}' is not in the allowed list. Choose from: {', '.join(sorted(TOOLS.keys()))}"
            continue

        if not check_tool(tool):
            print(f"  Tool '{tool}' not installed, skipping...")
            context += f"\n\n{response}\n\nERROR: Tool '{tool}' is not installed on this system. Choose a different tool."
            continue

        cmd = f"{tool} {args}" if args else tool
        print(f"  Action: {cmd}")
        log.append(f"  $ {cmd}")

        result = run_tool(cmd)
        print(f"  Observation: {result[:300]}")

        context += f"\n\n{response}\n\nOutput:\n{result[:2000]}"
        log.append(f"  Result: {result[:500]}")

    print(f"\n{'='*60}")
    print(f"Reached max iterations ({MAX_ITERATIONS}) or encountered error.")
    final_note = f"Session ended after {iteration} iterations. Partial findings above."
    report = save_report(goal, log, final_note)
    print(f"Partial report saved: {report}")


def list_models():
    try:
        req = urllib.request.Request(f"{OLLAMA_HOST}/api/tags")
        resp = urllib.request.urlopen(req, timeout=10)
        data = json.loads(resp.read())
        models = data.get("models", [])
        if not models:
            print("No models installed. Pull one: ollama pull llama3.2:3b")
            return
        print(f"{'NAME':<40} {'SIZE':<10} {'MODIFIED':<20}")
        print("-" * 70)
        for m in models:
            name = m.get("name", "?")
            size = m.get("size", 0)
            modified = m.get("modified_at", "?")[:16]
            size_str = f"{size / 1e9:.1f}GB" if size > 0 else "?"
            print(f"{name:<40} {size_str:<10} {modified:<20}")
    except Exception as e:
        print(f"Error connecting to Ollama: {e}")


def check_health():
    try:
        req = urllib.request.Request(f"{OLLAMA_HOST}/api/tags")
        urllib.request.urlopen(req, timeout=5)
        print("✓ Ollama server is running")
    except Exception:
        print("✗ Ollama server is NOT running")
        print("  Start it: ollama serve &")

    available = [n for n in TOOLS if check_tool(n)]
    missing = [n for n in TOOLS if not check_tool(n)]
    print(f"✓ {len(available)}/{len(TOOLS)} security tools available")
    if missing:
        print(f"  Missing: {', '.join(missing)}")
    print(f"✓ Report directory: {REPORT_DIR}")
    print(f"✓ Model configured: {MODEL}")
    print(f"✓ Max iterations: {MAX_ITERATIONS}")


def main():
    if len(sys.argv) < 2:
        print("Usage: nh-agent <command> [args]")
        print("Commands:")
        print("  recon <target>     Run autonomous reconnaissance")
        print("  ask <question>     Ask the AI a question")
        print("  models             List installed Ollama models")
        print("  health             Check agent health status")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "recon":
        if len(sys.argv) < 3:
            print("Usage: nh-agent recon <target> [description]")
            sys.exit(1)
        target = sys.argv[2]
        desc = " ".join(sys.argv[3:]) if len(sys.argv) > 3 else ""
        goal = f"Reconnaissance on {target}"
        if desc:
            goal += f" ({desc})"
        run_agent(goal)

    elif cmd == "ask":
        if len(sys.argv) < 3:
            print("Usage: nh-agent ask <question>")
            sys.exit(1)
        question = " ".join(sys.argv[2:])
        system = get_tool_descriptions()
        prompt = f"Answer this security/development question based on your knowledge. If you need to run tools to answer, use the ACTION format.\n\nQuestion: {question}"
        resp = ollama_request(prompt)
        print(resp)

    elif cmd == "models":
        list_models()

    elif cmd == "health":
        check_health()

    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    main()
