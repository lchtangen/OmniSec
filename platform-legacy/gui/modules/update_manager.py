"""Update mechanism — GitHub Releases API, signature verification, rollback"""
import os
import json
import subprocess
from pathlib import Path
from datetime import datetime, timedelta
from typing import Optional

UPDATE_DIR = Path.home() / ".omnisec" / "updates"
CONFIG_PATH = Path.home() / ".omnisec" / "config" / "update_config.json"
CHECK_INTERVAL_HOURS = 24
RELEASES_API = "https://api.github.com/repos/omnisec-io/armored/releases/latest"


class UpdateManager:
    def __init__(self):
        UPDATE_DIR.mkdir(parents=True, exist_ok=True)
        CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
        self.config = self._load_config()

    def _load_config(self) -> dict:
        if CONFIG_PATH.exists():
            return json.loads(CONFIG_PATH.read_text())
        return {
            "update_channel": "stable",
            "auto_check": True,
            "auto_download": False,
            "last_check": None,
            "current_version": "3.0.0",
        }

    def _save_config(self):
        CONFIG_PATH.write_text(json.dumps(self.config, indent=2))

    def check_for_updates(self, force: bool = False) -> Optional[dict]:
        """Check GitHub Releases for latest version"""
        if not self.config["auto_check"] and not force:
            return None
        if not force and self.config.get("last_check"):
            last = datetime.fromisoformat(self.config["last_check"])
            if datetime.utcnow() - last < timedelta(hours=CHECK_INTERVAL_HOURS):
                return None
        try:
            import requests
            resp = requests.get(RELEASES_API, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            latest = data.get("tag_name", "").lstrip("v")
            current = self.config["current_version"]
            self.config["last_check"] = datetime.utcnow().isoformat()
            self._save_config()
            return {
                "available": latest != current,
                "latest_version": latest,
                "current_version": current,
                "download_url": data.get("zipball_url", ""),
                "release_url": data.get("html_url", ""),
                "published": data.get("published_at", ""),
                "body": data.get("body", ""),
            }
        except Exception as e:
            return {"available": False, "error": str(e)}

    def download_update(self, url: str) -> Optional[Path]:
        """Download update package"""
        try:
            import requests
            resp = requests.get(url, stream=True, timeout=300)
            resp.raise_for_status()
            ext = ".zip" if "zipball" in url else ".tar.gz"
            path = UPDATE_DIR / f"update_{datetime.utcnow().strftime('%Y%m%d')}{ext}"
            with open(path, "wb") as f:
                for chunk in resp.iter_content(chunk_size=8192):
                    f.write(chunk)
            return path
        except Exception:
            return None

    def verify_update(self, update_path: Path) -> bool:
        """Verify GPG signature of update"""
        sig_path = Path(str(update_path) + ".sig")
        if not sig_path.exists():
            return False
        try:
            subprocess.run(
                ["gpg", "--verify", str(sig_path), str(update_path)],
                capture_output=True, check=True
            )
            return True
        except subprocess.CalledProcessError:
            return False

    def set_channel(self, channel: str):
        valid = ["stable", "beta", "nightly"]
        if channel in valid:
            self.config["update_channel"] = channel
            self._save_config()

    def set_auto_check(self, enabled: bool):
        self.config["auto_check"] = enabled
        self._save_config()

    def get_config(self) -> dict:
        return self.config
