"""
HIDS — Host Intrusion Detection System
Monitors file integrity, process anomalies, and filesystem changes.
Offline-only, no cloud dependencies.
"""

import os
import hashlib
import json
import time
from pathlib import Path
from datetime import datetime


class HIDSEngine:
    """Host Intrusion Detection System engine."""

    def __init__(self, config_dir=None):
        self.config_dir = Path(config_dir or (Path.home() / ".omnisec" / "hids"))
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.baseline_file = self.config_dir / "baseline.json"
        self.log_file = self.config_dir / "alerts.log"
        self.monitoring = False
        self.baseline = self._load_baseline()
        self.alerts = []

    def _load_baseline(self):
        """Load baseline checksums."""
        if self.baseline_file.exists():
            try:
                return json.loads(self.baseline_file.read_text())
            except Exception:
                pass
        return {}

    def _save_baseline(self):
        """Save baseline checksums."""
        self.baseline_file.write_text(json.dumps(self.baseline, indent=2))

    def _hash_file(self, filepath):
        """Calculate SHA-256 hash of a file."""
        try:
            h = hashlib.sha256()
            with open(filepath, "rb") as f:
                for chunk in iter(lambda: f.read(8192), b""):
                    h.update(chunk)
            return h.hexdigest()
        except Exception:
            return None

    def create_baseline(self, paths=None):
        """Create integrity baseline from monitored paths."""
        if paths is None:
            paths = [
                "/usr/bin", "/usr/sbin",
                "/etc", "/boot",
            ]
        self.baseline = {}
        for p in paths:
            path = Path(p)
            if not path.exists():
                continue
            for f in path.rglob("*"):
                if f.is_file():
                    h = self._hash_file(f)
                    if h:
                        self.baseline[str(f)] = h
        self._save_baseline()
        return len(self.baseline)

    def check_integrity(self):
        """Check current files against baseline."""
        alerts = []
        for filepath, expected_hash in self.baseline.items():
            current_hash = self._hash_file(Path(filepath))
            if current_hash is None:
                alerts.append(("MISSING", filepath))
            elif current_hash != expected_hash:
                alerts.append(("MODIFIED", filepath))
        # Check for new files
        for filepath in list(self.baseline.keys()):
            if not Path(filepath).exists():
                alerts.append(("DELETED", filepath))
        self.alerts = alerts
        self._log_alerts(alerts)
        return alerts

    def _log_alerts(self, alerts):
        """Log alerts to file."""
        if not alerts:
            return
        with open(self.log_file, "a") as f:
            ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            for atype, afile in alerts:
                f.write(f"[{ts}] {atype}: {afile}\n")

    def scan_processes(self):
        """Scan for suspicious processes."""
        suspicious = []
        try:
            for pid_dir in Path("/proc").iterdir():
                if not pid_dir.name.isdigit():
                    continue
                try:
                    cmdline = (pid_dir / "cmdline").read_text().replace("\x00", " ")
                    if any(x in cmdline.lower() for x in ["nc -l", "tcpdump", "wireshark", "keylogger"]):
                        suspicious.append((pid_dir.name, cmdline.strip()))
                except Exception:
                    continue
        except Exception:
            pass
        return suspicious

    def get_status(self):
        """Return current HIDS status."""
        return {
            "monitoring": self.monitoring,
            "baseline_size": len(self.baseline),
            "alerts_count": len(self.alerts),
            "last_check": datetime.now().isoformat(),
        }

    def start_monitoring(self, interval=60):
        """Start continuous monitoring (non-blocking, use in thread)."""
        self.monitoring = True
        import threading
        def monitor_loop():
            while self.monitoring:
                self.check_integrity()
                time.sleep(interval)
        t = threading.Thread(target=monitor_loop, daemon=True)
        t.start()
        return t

    def stop_monitoring(self):
        """Stop continuous monitoring."""
        self.monitoring = False
