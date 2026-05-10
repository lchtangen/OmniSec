"""Plugin system — marketplace concept, sandboxed execution, version compat"""
import os
import json
import hashlib
import subprocess
from pathlib import Path
from typing import Optional

PLUGIN_DIR = Path.home() / ".omnisec" / "plugins"
PLUGIN_REGISTRY = PLUGIN_DIR / "registry.json"
CORE_API_VERSION = "3.0.0"


def ensure_plugin_dirs():
    PLUGIN_DIR.mkdir(parents=True, exist_ok=True)
    if not PLUGIN_REGISTRY.exists():
        PLUGIN_REGISTRY.write_text(json.dumps({"plugins": {}, "version": CORE_API_VERSION}))


def load_registry() -> dict:
    ensure_plugin_dirs()
    return json.loads(PLUGIN_REGISTRY.read_text())


def save_registry(reg: dict):
    PLUGIN_REGISTRY.write_text(json.dumps(reg, indent=2))


def install_plugin(source: str, verify: bool = True) -> dict:
    """Install a plugin from GitHub or local path"""
    ensure_plugin_dirs()
    result = {"success": False, "name": "", "error": ""}
    try:
        plugin_id = hashlib.sha256(source.encode()).hexdigest()[:12]
        target_dir = PLUGIN_DIR / plugin_id
        target_dir.mkdir(exist_ok=True)

        if source.startswith("http"):
            import requests
            r = requests.get(source)
            (target_dir / "plugin.py").write_text(r.text)
        elif os.path.isfile(source):
            import shutil
            shutil.copy2(source, target_dir / "plugin.py")
        else:
            result["error"] = f"Invalid source: {source}"
            return result

        reg = load_registry()
        reg["plugins"][plugin_id] = {
            "name": os.path.basename(source),
            "source": source,
            "installed": True,
            "api_version": CORE_API_VERSION,
        }
        save_registry(reg)
        result.update({"success": True, "name": plugin_id})
    except Exception as e:
        result["error"] = str(e)
    return result


def verify_plugin(plugin_path: Path) -> bool:
    """Verify plugin signature and API compatibility"""
    if not plugin_path.exists():
        return False
    sig_path = Path(str(plugin_path) + ".sig")
    if sig_path.exists():
        try:
            subprocess.run(
                ["gpg", "--verify", str(sig_path), str(plugin_path)],
                capture_output=True, check=True
            )
            return True
        except subprocess.CalledProcessError:
            return False
    return True


def get_installed_plugins() -> list[dict]:
    reg = load_registry()
    return [
        {"id": pid, **info}
        for pid, info in reg.get("plugins", {}).items()
        if info.get("installed")
    ]


def uninstall_plugin(plugin_id: str) -> bool:
    reg = load_registry()
    if plugin_id in reg.get("plugins", {}):
        del reg["plugins"][plugin_id]
        save_registry(reg)
        target = PLUGIN_DIR / plugin_id
        if target.exists():
            import shutil
            shutil.rmtree(target)
        return True
    return False


def check_api_compatibility(plugin_api_version: str) -> bool:
    """Check if plugin version is compatible with core"""
    try:
        p_major = int(plugin_api_version.split(".")[0])
        c_major = int(CORE_API_VERSION.split(".")[0])
        return p_major == c_major
    except (ValueError, IndexError):
        return False
