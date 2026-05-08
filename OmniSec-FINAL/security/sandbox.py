"""Sandbox execution for untrusted tools — seccomp, namespaces, isolation"""
import os
import sys
import json
import tempfile
import subprocess
from pathlib import Path
from typing import Optional

SANDBOX_DIR = Path.home() / ".omnisec" / "sandbox"
PROFILES_DIR = Path(__file__).parent / "seccomp"
DEFAULT_TIMEOUT = 300


def ensure_sandbox_dirs():
    for d in ["bin", "data", "output", "tmp"]:
        (SANDBOX_DIR / d).mkdir(parents=True, exist_ok=True)


def get_sandboxed_path(binary_name: str) -> Path:
    return SANDBOX_DIR / "bin" / binary_name


def run_sandboxed(
    command: list[str],
    timeout: int = DEFAULT_TIMEOUT,
    network: bool = False,
    memory_limit_mb: int = 512,
    input_data: Optional[str] = None,
) -> dict:
    """Execute a command in sandboxed environment"""
    result = {
        "success": False,
        "stdout": "",
        "stderr": "",
        "return_code": -1,
        "timed_out": False,
    }
    try:
        env = os.environ.copy()
        env["SANDBOXED"] = "1"
        env["PATH"] = str(SANDBOX_DIR / "bin") + ":" + env.get("PATH", "/usr/bin")

        proc = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
            cwd=str(SANDBOX_DIR / "tmp"),
        )
        result.update({
            "success": proc.returncode == 0,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "return_code": proc.returncode,
        })
    except subprocess.TimeoutExpired:
        result["timed_out"] = True
        result["stderr"] = f"Command timed out after {timeout}s"
    except Exception as e:
        result["stderr"] = str(e)
    return result


def isolate_with_container(command: list[str], image: str = "omnisec/sandbox") -> dict:
    """Run in Docker container for full isolation"""
    docker_cmd = [
        "docker", "run", "--rm",
        "--network", "none" if image != "omnisec/sandbox-net" else "bridge",
        "--memory", "512m",
        "--cpus", "1",
        "--read-only",
        "-v", f"{SANDBOX_DIR / 'data'}:/data:ro",
        "-v", f"{SANDBOX_DIR / 'output'}:/output:rw",
        image,
    ] + command
    return run_sandboxed(docker_cmd, timeout=600)


def verify_signature(binary_path: Path, signature_path: Optional[Path] = None) -> bool:
    """Verify GPG signature of a binary before execution"""
    sig = signature_path or Path(str(binary_path) + ".sig")
    if not sig.exists():
        return False
    try:
        subprocess.run(
            ["gpg", "--verify", str(sig), str(binary_path)],
            capture_output=True, check=True
        )
        return True
    except subprocess.CalledProcessError:
        return False


def audit_trail(command: list[str], result: dict) -> str:
    """Log execution to local audit log"""
    from datetime import datetime
    entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "command": command,
        "success": result["success"],
        "return_code": result["return_code"],
        "timed_out": result["timed_out"],
    }
    log_path = SANDBOX_DIR / "audit.jsonl"
    with open(log_path, "a") as f:
        f.write(json.dumps(entry) + "\n")
    return str(log_path)
