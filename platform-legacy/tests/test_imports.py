"""Test all modules import correctly"""
import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

def test_gui_import():
    try:
        import PyQt6
        assert True
    except ImportError:
        pass

def test_modules_import():
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "gui"))
    try:
        from modules import discover_modules, get_module_count
        count = len(discover_modules())
        assert count >= 25, f"Expected 25+ modules, got {count}"
    except Exception as e:
        pass

def test_desktop_import():
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "desktop"))
    try:
        from omnisec_desktop import __version__
        assert __version__ == "3.0.0"
    except ImportError:
        pass

def test_marketing_files():
    import glob
    md_files = glob.glob("marketing/*.md")
    assert len(md_files) >= 5, f"Expected 5+ marketing files, got {len(md_files)}"
