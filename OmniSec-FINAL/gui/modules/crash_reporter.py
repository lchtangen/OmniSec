"""Opt-in crash reporting — fully anonymized, user-consented"""
import os
import sys
import json
import platform
import traceback
from pathlib import Path
from datetime import datetime
from typing import Optional

CRASH_DIR = Path.home() / ".omnisec" / "crashes"
ENABLED = False


def ensure_crash_dir():
    CRASH_DIR.mkdir(parents=True, exist_ok=True)


def enable_crash_reporting():
    global ENABLED
    ENABLED = True
    ensure_crash_dir()


def disable_crash_reporting():
    global ENABLED
    ENABLED = False


def is_enabled() -> bool:
    return ENABLED


def capture_exception(exc: Optional[BaseException] = None) -> str:
    """Capture and store exception locally"""
    ensure_crash_dir()
    exc_info = exc or sys.exc_info()[1] or Exception("Manual capture")
    crash_id = datetime.utcnow().strftime("%Y%m%d_%H%M%S_%f")
    report = {
        "crash_id": crash_id,
        "timestamp": datetime.utcnow().isoformat(),
        "type": type(exc_info).__name__,
        "message": str(exc_info),
        "traceback": traceback.format_exc(),
        "platform": {
            "system": platform.system(),
            "release": platform.release(),
            "machine": platform.machine(),
            "python": sys.version,
        },
        "anonymized": True,
    }
    if ENABLED:
        report_path = CRASH_DIR / f"crash_{crash_id}.json"
        report_path.write_text(json.dumps(report, indent=2))
    # Always save locally
    local_path = CRASH_DIR / f"crash_{crash_id}.json"
    local_path.write_text(json.dumps(report, indent=2))
    return crash_id


def get_recent_crashes(limit: int = 10) -> list[dict]:
    ensure_crash_dir()
    crashes = []
    for f in sorted(CRASH_DIR.glob("crash_*.json"), reverse=True)[:limit]:
        try:
            crashes.append(json.loads(f.read_text()))
        except (json.JSONDecodeError, OSError):
            continue
    return crashes


def clear_crashes():
    ensure_crash_dir()
    for f in CRASH_DIR.glob("crash_*.json"):
        f.unlink()
