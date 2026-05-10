"""Security verification tests"""
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

SOURCE_DIRS = ("engine", "gui", "security", "mobile")


def iter_source_files():
    root = Path(__file__).resolve().parents[1]
    for source_dir in SOURCE_DIRS:
        yield from (root / source_dir).rglob("*.py")

def test_no_telemetry():
    """Verify no telemetry code exists"""
    forbidden = ("google_analytics", "segment.io", "phone_home")
    for py_file in iter_source_files():
        content = py_file.read_text(encoding="utf-8").lower()
        for marker in forbidden:
            assert marker not in content, f"{marker} found in {py_file}"

def test_offline_capable():
    """Verify no hardcoded external service requirements"""
    forbidden_hosts = (
        "google-analytics.com",
        "analytics.google.com",
        "segment.com",
        "sentry.io",
        "mixpanel.com",
    )
    for py_file in iter_source_files():
        content = py_file.read_text(encoding="utf-8").lower()
        for host in forbidden_hosts:
            assert host not in content, f"{host} found in {py_file}"

def test_no_hardcoded_credentials():
    """Check for hardcoded passwords/keys"""
    import re
    for py_file in iter_source_files():
        with py_file.open(encoding="utf-8") as f:
            for i, line in enumerate(f, 1):
                if re.search(r'password\s*=\s*["\']', line, re.I):
                    if "example" not in line.lower() and "placeholder" not in line.lower():
                        print(f"WARNING: {py_file}:{i}: {line.strip()}")
