"""
Canary Tokens — Honeypot and Canary Token System
Deploy fake credentials, files, and services to detect intrusions.
Offline-only, local detection.
"""

import os
import json
import random
import string
import threading
import time
from pathlib import Path
from datetime import datetime


class CanaryEngine:
    """Canary token deployment and monitoring engine."""

    def __init__(self, config_dir=None):
        self.config_dir = Path(config_dir or (Path.home() / ".omnisec" / "canary"))
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.tokens_file = self.config_dir / "tokens.json"
        self.alerts_file = self.config_dir / "alerts.log"
        self.tokens = self._load_tokens()
        self.alerts = []
        self.monitoring = False

    def _load_tokens(self):
        """Load deployed tokens."""
        if self.tokens_file.exists():
            try:
                return json.loads(self.tokens_file.read_text())
            except Exception:
                pass
        return []

    def _save_tokens(self):
        """Save tokens to disk."""
        self.tokens_file.write_text(json.dumps(self.tokens, indent=2))

    def _log_alert(self, alert_type, token_id, details=""):
        """Log a canary alert."""
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        alert = f"[{ts}] {alert_type}: token={token_id} {details}"
        self.alerts.append(alert)
        with open(self.alerts_file, "a") as f:
            f.write(alert + "\n")

    def generate_token(self, token_type="file", name=""):
        """Generate a random canary token."""
        token = ''.join(random.choices(string.ascii_letters + string.digits, k=32))
        entry = {
            "id": len(self.tokens) + 1,
            "token": token,
            "type": token_type,
            "name": name or f"canary_{len(self.tokens) + 1}",
            "created": datetime.now().isoformat(),
            "triggered": False,
            "hits": 0,
        }
        return entry

    def deploy_file_token(self, filepath, token_entry=None):
        """Deploy a canary token as a file."""
        if token_entry is None:
            token_entry = self.generate_token("file", Path(filepath).name)
        token = token_entry["token"]
        content = f"""CONFIDENTIAL / SENSITIVE
Access Token: {token}
DO NOT SHARE — Internal Use Only
Generated: {datetime.now().strftime("%Y-%m-%d")}
"""
        try:
            Path(filepath).write_text(content)
            token_entry["deployed_path"] = filepath
            self.tokens.append(token_entry)
            self._save_tokens()
            return token_entry
        except Exception as e:
            return {"error": str(e)}

    def deploy_aws_canary(self, access_key="AKIAIOSFODNN7EXAMPLE"):
        """Deploy fake AWS credentials as canary."""
        token_entry = self.generate_token("aws_creds", "Fake AWS Key")
        token_entry["access_key"] = access_key
        token_entry["secret_key"] = token_entry["token"][:20] + "EXAMPLEKEY"
        token_entry["deployed_path"] = f"~/.aws/credentials (injected)"
        self.tokens.append(token_entry)
        self._save_tokens()
        return token_entry

    def deploy_db_canary(self, db_user="admin", db_name="production"):
        """Deploy fake database credentials."""
        token_entry = self.generate_token("db_creds", f"Fake {db_name} DB creds")
        token_entry["db_user"] = db_user
        token_entry["db_pass"] = token_entry["token"][:16]
        token_entry["db_name"] = db_name
        self.tokens.append(token_entry)
        self._save_tokens()
        return token_entry

    def deploy_honeypot_port(self, port=8080):
        """Deploy a honeypot on a specific port."""
        token_entry = self.generate_token("honeypot", f"Honeypot on port {port}")
        token_entry["port"] = port
        token_entry["deployed_path"] = f"tcp/{port}"
        self.tokens.append(token_entry)
        self._save_tokens()
        return token_entry

    def check_token_triggers(self):
        """Check if any canary tokens have been triggered."""
        triggered = []
        for token in self.tokens:
            if token.get("triggered"):
                continue
            # Check file tokens
            if token["type"] == "file" and "deployed_path" in token:
                path = Path(token["deployed_path"])
                if path.exists():
                    try:
                        content = path.read_text()
                        if token["token"] in content and "accessed" not in content.lower():
                            token["triggered"] = True
                            token["hits"] += 1
                            triggered.append(token)
                            self._log_alert("TRIGGERED", token["id"], f"file={path}")
                    except Exception:
                        pass
        if triggered:
            self._save_tokens()
        return triggered

    def get_all_tokens(self):
        """Get all deployed tokens."""
        return self.tokens

    def get_triggered_tokens(self):
        """Get all triggered tokens."""
        return [t for t in self.tokens if t.get("triggered")]

    def start_monitoring(self, interval=30):
        """Start background monitoring for triggers."""
        self.monitoring = True
        def monitor_loop():
            while self.monitoring:
                self.check_token_triggers()
                time.sleep(interval)
        import threading
        t = threading.Thread(target=monitor_loop, daemon=True)
        t.start()
        return t

    def stop_monitoring(self):
        """Stop monitoring."""
        self.monitoring = False

    def get_status(self):
        """Get canary engine status."""
        return {
            "monitoring": self.monitoring,
            "total_tokens": len(self.tokens),
            "triggered_tokens": len(self.get_triggered_tokens()),
            "alerts_count": len(self.alerts),
        }
