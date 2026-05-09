"""Resource usage dashboard, performance metrics, error tracking"""
import os
import json
import time
import threading
from pathlib import Path
from datetime import datetime
from collections import deque

METRICS_DIR = Path.home() / ".omnisec" / "metrics"
MAX_HISTORY = 1000


class MetricsCollector:
    def __init__(self):
        METRICS_DIR.mkdir(parents=True, exist_ok=True)
        self.history = deque(maxlen=MAX_HISTORY)
        self._running = False
        self._thread = None

    def start(self, interval: float = 5.0):
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._collect_loop, args=(interval,), daemon=True)
        self._thread.start()

    def stop(self):
        self._running = False

    def _collect_loop(self, interval: float):
        import psutil
        while self._running:
            try:
                cpu = psutil.cpu_percent(interval=0)
                mem = psutil.virtual_memory()
                disk = psutil.disk_usage("/")
                entry = {
                    "timestamp": datetime.utcnow().isoformat(),
                    "cpu_percent": cpu,
                    "memory_percent": mem.percent,
                    "memory_used_gb": round(mem.used / (1024**3), 2),
                    "disk_percent": disk.percent,
                    "disk_free_gb": round(disk.free / (1024**3), 2),
                    "processes": len(psutil.pids()),
                    "network_sent": psutil.net_io_counters().bytes_sent,
                    "network_recv": psutil.net_io_counters().bytes_recv,
                }
                self.history.append(entry)
                self._save_entry(entry)
            except Exception:
                pass
            time.sleep(interval)

    def _save_entry(self, entry: dict):
        date = entry["timestamp"][:10]
        log_file = METRICS_DIR / f"metrics_{date}.jsonl"
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")

    def get_statistics(self) -> dict:
        if not self.history:
            return {"error": "No data collected"}
        cpu_vals = [e["cpu_percent"] for e in self.history]
        mem_vals = [e["memory_percent"] for e in self.history]
        return {
            "avg_cpu": round(sum(cpu_vals) / len(cpu_vals), 1),
            "max_cpu": max(cpu_vals),
            "avg_memory": round(sum(mem_vals) / len(mem_vals), 1),
            "max_memory": max(mem_vals),
            "samples": len(self.history),
        }

    def get_current(self) -> dict:
        import psutil
        return {
            "cpu": psutil.cpu_percent(interval=0),
            "memory": psutil.virtual_memory().percent,
            "disk": psutil.disk_usage("/").percent,
            "processes": len(psutil.pids()),
        }
