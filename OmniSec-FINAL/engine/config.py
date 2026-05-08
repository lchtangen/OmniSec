"""
OmniSec ULTIMATE — Configuration Management
Centralized configuration with XDG Base Directory support
"""
import os
import sys
from pathlib import Path
from typing import Optional

def get_data_dir() -> Path:
    """Get platform-appropriate data directory following XDG standards"""
    if sys.platform == "linux":
        # XDG Base Directory Specification
        xdg_data = os.environ.get("XDG_DATA_HOME")
        if xdg_data:
            base = Path(xdg_data)
        else:
            base = Path.home() / ".local" / "share"
    elif sys.platform == "darwin":
        # macOS Application Support
        base = Path.home() / "Library" / "Application Support"
    elif sys.platform == "win32":
        # Windows AppData
        appdata = os.environ.get("APPDATA")
        base = Path(appdata) if appdata else Path.home() / "AppData" / "Roaming"
    else:
        # Fallback for unknown platforms
        base = Path.home() / ".omnisec"
    
    data_dir = base / "omnisec"
    data_dir.mkdir(parents=True, exist_ok=True)
    return data_dir

def get_config_dir() -> Path:
    """Get platform-appropriate config directory"""
    if sys.platform == "linux":
        xdg_config = os.environ.get("XDG_CONFIG_HOME")
        if xdg_config:
            base = Path(xdg_config)
        else:
            base = Path.home() / ".config"
    elif sys.platform == "darwin":
        base = Path.home() / "Library" / "Preferences"
    elif sys.platform == "win32":
        appdata = os.environ.get("APPDATA")
        base = Path(appdata) if appdata else Path.home() / "AppData" / "Roaming"
    else:
        base = Path.home() / ".config"
    
    config_dir = base / "omnisec"
    config_dir.mkdir(parents=True, exist_ok=True)
    return config_dir

def get_cache_dir() -> Path:
    """Get platform-appropriate cache directory"""
    if sys.platform == "linux":
        xdg_cache = os.environ.get("XDG_CACHE_HOME")
        if xdg_cache:
            base = Path(xdg_cache)
        else:
            base = Path.home() / ".cache"
    elif sys.platform == "darwin":
        base = Path.home() / "Library" / "Caches"
    elif sys.platform == "win32":
        localappdata = os.environ.get("LOCALAPPDATA")
        base = Path(localappdata) if localappdata else Path.home() / "AppData" / "Local"
    else:
        base = Path.home() / ".cache"
    
    cache_dir = base / "omnisec"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir

def get_log_dir() -> Path:
    """Get platform-appropriate log directory"""
    if sys.platform == "linux":
        # XDG state directory for logs
        xdg_state = os.environ.get("XDG_STATE_HOME")
        if xdg_state:
            base = Path(xdg_state)
        else:
            base = Path.home() / ".local" / "state"
    elif sys.platform == "darwin":
        base = Path.home() / "Library" / "Logs"
    elif sys.platform == "win32":
        localappdata = os.environ.get("LOCALAPPDATA")
        base = Path(localappdata) if localappdata else Path.home() / "AppData" / "Local"
    else:
        base = Path.home() / ".local" / "state"
    
    log_dir = base / "omnisec"
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir

# Global paths
DATA_DIR = get_data_dir()
CONFIG_DIR = get_config_dir()
CACHE_DIR = get_cache_dir()
LOG_DIR = get_log_dir()

# Database paths
DB_DIR = DATA_DIR / "databases"
DB_DIR.mkdir(exist_ok=True)

SIEM_DB = DB_DIR / "siem.db"
ASSETS_DB = DB_DIR / "assets.db"
THREAT_INTEL_DB = DB_DIR / "threat_intel.db"
COMPLIANCE_DB = DB_DIR / "compliance.db"
UEBA_DB = DB_DIR / "ueba.db"

# Configuration
DEFAULT_TIMEOUT = 300  # 5 minutes for long operations
HTTP_TIMEOUT = 10  # 10 seconds for HTTP requests
NMAP_TIMEOUT = 300  # 5 minutes for nmap scans
MAX_RETRIES = 3
RETRY_DELAY = 1  # seconds

# Android/Termux detection
IS_ANDROID = os.path.exists("/data/data/com.termux") or sys.platform == "android"
IS_ROOTED = os.path.exists("/system/xbin/su") or os.path.exists("/system/bin/su")

# Feature flags
ENABLE_NETWORK_SCANNING = True
ENABLE_AUTO_PENTEST = IS_ROOTED  # Only on rooted devices
ENABLE_PACKET_CAPTURE = IS_ROOTED
ENABLE_SYSTEM_MONITORING = True

def get_db_path(db_name: str) -> Path:
    """Get database path by name"""
    return DB_DIR / f"{db_name}.db"

def is_android() -> bool:
    """Check if running on Android"""
    return IS_ANDROID

def is_rooted() -> bool:
    """Check if device is rooted"""
    return IS_ROOTED

def get_platform_info() -> dict:
    """Get platform information"""
    return {
        "platform": sys.platform,
        "is_android": IS_ANDROID,
        "is_rooted": IS_ROOTED,
        "data_dir": str(DATA_DIR),
        "config_dir": str(CONFIG_DIR),
        "cache_dir": str(CACHE_DIR),
        "log_dir": str(LOG_DIR),
    }
