"""
Playbooks — Security Playbook Engine
Reusable automation chains for penetration testing and incident response.
Offline-only, local execution.
"""

import os
import json
import subprocess
import threading
import time
from pathlib import Path
from datetime import datetime


class PlaybookEngine:
    """Security Playbook executor engine."""

    def __init__(self, config_dir=None):
        self.config_dir = Path(config_dir or (Path.home() / ".omnisec" / "playbooks"))
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.playbooks_file = self.config_dir / "playbooks.json"
        self.playbooks = self._load_playbooks()
        self.running = None  # currently running playbook name
        self.progress = 0
        self.output = []
        self.status = "idle"  # idle, running, completed, error

    def _load_playbooks(self):
        """Load saved playbooks."""
        if self.playbooks_file.exists():
            try:
                return json.loads(self.playbooks_file.read_text())
            except Exception:
                pass
        return self._default_playbooks()

    def _save_playbooks(self):
        """Save playbooks to disk."""
        self.playbooks_file.write_text(json.dumps(self.playbooks, indent=2))

    def _default_playbooks(self):
        """Built-in default playbooks."""
        return {
            "quick_scan": {
                "name": "Quick Network Scan",
                "description": "Fast port scan + vulnerability check",
                "steps": [
                    {"tool": "nmap", "args": ["-sV", "--open", "$TARGET"]},
                    {"tool": "nmap", "args": ["--script", "vuln", "$TARGET"]},
                ],
                "timeout": 300,
            },
            "full_audit": {
                "name": "Full Security Audit",
                "description": "Comprehensive audit: recon + scan + exploit check",
                "steps": [
                    {"tool": "nmap", "args": ["-sS", "-A", "-T4", "$TARGET"]},
                    {"tool": "nikto", "args": ["-h", "$TARGET"]},
                    {"tool": "testssl", "args": ["$TARGET:443"]},
                    {"tool": "sqlmap", "args": ["-u", "$TARGET", "--batch"]},
                ],
                "timeout": 1800,
            },
            "wifi_audit": {
                "name": "WiFi Security Audit",
                "description": "Scan WiFi networks and check for common vulns",
                "steps": [
                    {"tool": "airmon-ng", "args": ["start", "wlan0"]},
                    {"tool": "airodump-ng", "args": ["wlan0mon", "--write", "/tmp/wifi_scan"]},
                ],
                "timeout": 600,
            },
            "forensic_capture": {
                "name": "Forensic Memory Capture",
                "description": "Capture system memory and disk image",
                "steps": [
                    {"tool": "dd", "args": ["if=/dev/mem", "of=/tmp/mem_dump.img"]},
                    {"tool": "dd", "args": ["if=/dev/sda", "of=/tmp/disk_image.img", "bs=4M"]},
                ],
                "timeout": 3600,
            },
            "incident_response": {
                "name": "Incident Response",
                "description": "Automated incident containment + analysis",
                "steps": [
                    {"tool": "pkill", "args": ["-f", "suspicious_process"]},
                    {"tool": "iptables", "args": ["-A", "INPUT", "-s", "$THREAT_IP", "-j", "DROP"]},
                    {"tool": "tar", "args": ["-czf", "/tmp/incident_logs.tar.gz", "/var/log/"]},
                ],
                "timeout": 600,
            },
        }

    def list_playbooks(self):
        """List all available playbooks."""
        return [
            {"id": pid, "name": pb["name"], "description": pb["description"], "steps": len(pb["steps"])}
            for pid, pb in self.playbooks.items()
        ]

    def get_playbook(self, playbook_id):
        """Get a specific playbook."""
        return self.playbooks.get(playbook_id)

    def add_playbook(self, playbook_id, name, description, steps, timeout=600):
        """Add a new playbook."""
        self.playbooks[playbook_id] = {
            "name": name,
            "description": description,
            "steps": steps,
            "timeout": timeout,
        }
        self._save_playbooks()

    def delete_playbook(self, playbook_id):
        """Delete a playbook."""
        if playbook_id in self.playbooks:
            del self.playbooks[playbook_id]
            self._save_playbooks()
            return True
        return False

    def run_playbook(self, playbook_id, target="", callback=None):
        """Run a playbook in a background thread."""
        pb = self.playbooks.get(playbook_id)
        if not pb:
            return False

        def run():
            self.running = playbook_id
            self.status = "running"
            self.progress = 0
            self.output = [f"[+] Starting playbook: {pb['name']}"]
            total_steps = len(pb["steps"])

            for i, step in enumerate(pb["steps"]):
                tool = step.get("tool", "")
                args = [a.replace("$TARGET", target) for a in step.get("args", [])]
                self.output.append(f"[*] Step {i+1}/{total_steps}: {tool} {' '.join(args)}")
                try:
                    result = subprocess.run(
                        [tool] + args,
                        capture_output=True,
                        text=True,
                        timeout=pb.get("timeout", 300),
                    )
                    if result.stdout:
                        self.output.append(result.stdout[:500])
                    if result.stderr:
                        self.output.append(f"[stderr] {result.stderr[:300]}")
                    self.output.append(f"[+] Step {i+1} completed")
                except subprocess.TimeoutExpired:
                    self.output.append(f"[-] Step {i+1} timed out")
                except FileNotFoundError:
                    self.output.append(f"[-] Tool not found: {tool}")
                except Exception as e:
                    self.output.append(f"[-] Error: {e}")
                self.progress = int((i + 1) / total_steps * 100)
                if callback:
                    callback(self.progress, self.output[-1])

            self.output.append(f"[+] Playbook '{pb['name']}' completed")
            self.status = "completed"
            self.running = None

        t = threading.Thread(target=run, daemon=True)
        t.start()
        return True

    def stop_playbook(self):
        """Stop the currently running playbook."""
        self.running = None
        self.status = "stopped"
        return True

    def get_status(self):
        """Get current playbook engine status."""
        return {
            "status": self.status,
            "running": self.running,
            "progress": self.progress,
            "output_lines": len(self.output),
            "playbooks_count": len(self.playbooks),
        }
