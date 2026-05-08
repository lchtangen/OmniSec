"""
Notification Engine — Multi-channel Notification System
Supports ntfy, Telegram, Discord webhooks, and local desktop notifications.
Offline-capable with push notification support via ntfy.
"""

import os
import json
import threading
import time
from pathlib import Path
from datetime import datetime


class NotificationEngine:
    """Multi-channel notification engine."""

    def __init__(self, config_dir=None):
        self.config_dir = Path(config_dir or (Path.home() / ".omnisec" / "notify"))
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.config_file = self.config_dir / "notify_config.json"
        self.config = self._load_config()
        self.history = []

    def _load_config(self):
        """Load notification configuration."""
        defaults = {
            "ntfy": {"enabled": False, "topic": "", "server": "https://ntfy.sh"},
            "telegram": {"enabled": False, "bot_token": "", "chat_id": ""},
            "discord": {"enabled": False, "webhook_url": ""},
            "desktop": {"enabled": True},
        }
        if self.config_file.exists():
            try:
                loaded = json.loads(self.config_file.read_text())
                defaults.update(loaded)
            except Exception:
                pass
        return defaults

    def _save_config(self):
        """Save notification configuration."""
        self.config_file.write_text(json.dumps(self.config, indent=2))

    def configure_ntfy(self, topic, server="https://ntfy.sh"):
        """Configure ntfy notifications."""
        self.config["ntfy"] = {"enabled": True, "topic": topic, "server": server}
        self._save_config()
        return True

    def configure_telegram(self, bot_token, chat_id):
        """Configure Telegram Bot notifications."""
        self.config["telegram"] = {"enabled": True, "bot_token": bot_token, "chat_id": chat_id}
        self._save_config()
        return True

    def configure_discord(self, webhook_url):
        """Configure Discord webhook notifications."""
        self.config["discord"] = {"enabled": True, "webhook_url": webhook_url}
        self._save_config()
        return True

    def send_ntfy(self, message, title="OmniSec Alert"):
        """Send ntfy notification."""
        cfg = self.config.get("ntfy", {})
        if not cfg.get("enabled"):
            return False, "ntfy not enabled"
        import urllib.request
        try:
            url = f"{cfg['server']}/{cfg['topic']}"
            data = message.encode()
            req = urllib.request.Request(url, data=data, headers={
                "Title": title,
                "Priority": "high",
            })
            urllib.request.urlopen(req, timeout=10)
            return True, "Sent"
        except Exception as e:
            return False, str(e)

    def send_telegram(self, message):
        """Send Telegram notification."""
        cfg = self.config.get("telegram", {})
        if not cfg.get("enabled"):
            return False, "telegram not enabled"
        import urllib.request
        try:
            url = f"https://api.telegram.org/bot{cfg['bot_token']}/sendMessage"
            data = urllib.parse.urlencode({
                "chat_id": cfg["chat_id"],
                "text": message,
            }).encode()
            req = urllib.request.Request(url, data=data)
            urllib.request.urlopen(req, timeout=10)
            return True, "Sent"
        except Exception as e:
            return False, str(e)

    def send_discord(self, message, title="OmniSec Alert"):
        """Send Discord webhook notification."""
        cfg = self.config.get("discord", {})
        if not cfg.get("enabled"):
            return False, "discord not enabled"
        import urllib.request
        try:
            payload = json.dumps({
                "embeds": [{
                    "title": title,
                    "description": message,
                    "color": 0xFF6D00,
                    "timestamp": datetime.now().isoformat(),
                }]
            }).encode()
            req = urllib.request.Request(
                cfg["webhook_url"],
                data=payload,
                headers={"Content-Type": "application/json"},
            )
            urllib.request.urlopen(req, timeout=10)
            return True, "Sent"
        except Exception as e:
            return False, str(e)

    def send_desktop(self, message, title="OmniSec Alert"):
        """Send local desktop notification."""
        try:
            import subprocess
            subprocess.run(
                ["notify-send", title, message, "-u", "critical"],
                timeout=5,
            )
            return True, "Sent"
        except Exception as e:
            return False, str(e)

    def notify(self, message, title="OmniSec Alert", channels=None):
        """Send notification to all enabled channels."""
        if channels is None:
            channels = ["desktop"]
            if self.config["ntfy"]["enabled"]:
                channels.append("ntfy")
            if self.config["telegram"]["enabled"]:
                channels.append("telegram")
            if self.config["discord"]["enabled"]:
                channels.append("discord")

        results = {}
        for ch in channels:
            if ch == "ntfy":
                ok, msg = self.send_ntfy(message, title)
            elif ch == "telegram":
                ok, msg = self.send_telegram(message)
            elif ch == "discord":
                ok, msg = self.send_discord(message, title)
            elif ch == "desktop":
                ok, msg = self.send_desktop(message, title)
            else:
                continue
            results[ch] = {"success": ok, "message": msg}
            self.history.append({
                "channel": ch,
                "message": message,
                "success": ok,
                "timestamp": datetime.now().isoformat(),
            })
        return results

    def get_history(self, limit=50):
        """Get notification history."""
        return self.history[-limit:]

    def get_status(self):
        """Get notification engine status."""
        return {
            "ntfy_enabled": self.config["ntfy"]["enabled"],
            "telegram_enabled": self.config["telegram"]["enabled"],
            "discord_enabled": self.config["discord"]["enabled"],
            "desktop_enabled": self.config["desktop"]["enabled"],
            "history_count": len(self.history),
        }
