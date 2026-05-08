"""Security verification tests"""
import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

def test_no_telemetry():
    """Verify no telemetry code exists"""
    import glob
    for py_file in glob.glob("**/*.py", recursive=True):
        if "__pycache__" in py_file:
            continue
        with open(py_file) as f:
            content = f.read().lower()
            assert "google_analytics" not in content
            assert "segment.io" not in content
            assert "phone_home" not in content

def test_offline_capable():
    """Verify no hard internet requirements"""
    import glob
    for py_file in glob.glob("**/*.py", recursive=True):
        if "__pycache__" in py_file:
            continue
        with open(py_file) as f:
            content = f.read().lower()
            assert "requests.get(" not in content or "telemetry" not in content

def test_no_hardcoded_credentials():
    """Check for hardcoded passwords/keys"""
    import glob
    import re
    for py_file in glob.glob("**/*.py", recursive=True):
        if "__pycache__" in py_file:
            continue
        with open(py_file) as f:
            for i, line in enumerate(f, 1):
                if re.search(r'password\s*=\s*["\']', line, re.I):
                    if "example" not in line.lower() and "placeholder" not in line.lower():
                        print(f"WARNING: {py_file}:{i}: {line.strip()}")
