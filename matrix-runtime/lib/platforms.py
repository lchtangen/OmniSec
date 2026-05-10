"""
OmniSec Platform - Cross-Platform Abstraction Layer

Supports: Android, Linux, macOS, Windows, WSL, Chroot
"""

import os
import sys
import platform
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from enum import Enum

# ── Platform Type Enum ────────────────────────────────────────

class PlatformType(str, Enum):
    ANDROID = "android"
    ANDROID_CHROOT = "android_chroot"
    LINUX = "linux"
    MACOS = "macos"
    WINDOWS = "windows"
    WSL = "wsl"  # Windows Subsystem for Linux
    UNKNOWN = "unknown"

# ── Platform Abstraction ─────────────────────────────────────────

class PlatformInfo:
    """Detailed platform information."""
    
    def __init__(self):
        self.system = platform.system().lower()
        self.machine = platform.machine()
        self.release = platform.release()
        self.version = platform.version()
        self.node = platform.node()
        self.python_version = platform.python_version()
        
        # Detected types
        self.type = self._detect_type()
        self.is_root = os.getuid() == 0 if hasattr(os, 'getuid') else False
        self.in_chroot = self._detect_chroot()
        self.in_container = self._detect_container()
        
    def _detect_type(self) -> PlatformType:
        """Detect the specific platform type."""
        if self.system == "linux":
            # Check for Android
            if self._is_android():
                if self._detect_chroot():
                    return PlatformType.ANDROID_CHROOT
                return PlatformType.ANDROID
            
            # Check for WSL
            if self._is_wsl():
                return PlatformType.WSL
            
            return PlatformType.LINUX
        
        elif self.system == "darwin":
            return PlatformType.MACOS
        
        elif self.system == "windows":
            return PlatformType.WINDOWS
        
        return PlatformType.UNKNOWN
    
    def _is_android(self) -> bool:
        """Check if running on Android."""
        return (
            Path("/system/build.prop").exists() or
            Path("/system").exists() or
            "android" in self.release.lower()
        )
    
    def _is_wsl(self) -> bool:
        """Check if running under WSL."""
        return (
            "microsoft" in self.release.lower() or
            "wsl" in self.release.lower()
        )
    
    def _detect_chroot(self) -> bool:
        """Detect if running inside a chroot."""
        indicators = [
            Path("/data/local/nhsystem").exists(),
            Path("/etc/debian_chroot").exists(),
            os.environ.get("CHROOT") is not None,
            # Check for typical chroot markers
            Path("/proc/1/root").exists() and (
                not Path("/proc/1/root").samefile("/")
            ),
        ]
        return any(indicators)
    
    def _detect_container(self) -> bool:
        """Detect if running inside a container (Docker, LXC, etc.)."""
        indicators = [
            Path("/.dockerenv").exists(),
            Path("/run/.containerenv").exists(),
            "docker" in Path("/proc/1/cgroup").read_text() if Path("/proc/1/cgroup").exists() else False,
        ]
        return any(indicators)
    
    def get_name(self) -> str:
        """Human-readable platform name."""
        names = {
            PlatformType.ANDROID: "Android (Native)",
            PlatformType.ANDROID_CHROOT: "Android (Chroot)",
            PlatformType.LINUX: f"Linux ({self.machine})",
            PlatformType.MACOS: f"macOS ({platform.mac_ver()[0]})",
            PlatformType.WINDOWS: f"Windows ({platform.win32_ver()[0]})",
            PlatformType.WSL: "Windows (WSL)",
            PlatformType.UNKNOWN: f"Unknown ({self.system})",
        }
        return names.get(self.type, "Unknown")
    
    def supports_feature(self, feature: str) -> bool:
        """Check if platform supports a specific feature."""
        feature_map = {
            "ebpf": self.type in [PlatformType.LINUX, PlatformType.WSL, PlatformType.ANDROID_CHROOT],
            "docker": self.type in [PlatformType.LINUX, PlatformType.WSL, PlatformType.MACOS],
            "chroot": self.type in [PlatformType.LINUX, PlatformType.WSL, PlatformType.ANDROID],
            "systemd": self.type == PlatformType.LINUX and not self.in_chroot,
            "launchd": self.type == PlatformType.MACOS,
            "hsm": self.type in [PlatformType.LINUX, PlatformType.MACOS, PlatformType.WSL],
            "mesh": self.type in [PlatformType.ANDROID, PlatformType.LINUX, PlatformType.MACOS],
            "5g": self.type == PlatformType.ANDROID,
            "pqc": True,  # Post-quantum crypto is cross-platform
        }
        return feature_map.get(feature, False)
    
    def __str__(self):
        return f"{self.get_name()} [{self.type.value}]"

# ── Tool Executor ──────────────────────────────────────────────

class ToolExecutor:
    """Cross-platform tool execution with fallbacks."""
    
    def __init__(self, platform_info: PlatformInfo):
        self.platform = platform_info
        self._tool_cache: Dict[str, Path] = {}
    
    def find_tool(self, tool_name: str) -> Optional[Path]:
        """Find a tool executable across platforms."""
        # Check cache
        if tool_name in self._tool_cache:
            return self._tool_cache[tool_name]
        
        # Try different naming conventions
        possible_names = [
            tool_name,
            f"nh-{tool_name}",
            f"nmatrix-{tool_name}",
            tool_name.replace("_", "-"),
        ]
        
        # Search in PATH
        for name in possible_names:
            path = shutil.which(name)
            if path:
                tool_path = Path(path)
                self._tool_cache[tool_name] = tool_path
                return tool_path
        
        # Search in common locations
        common_paths = [
            Path("/data/local/nhsystem/bin"),
            Path.home() / ".local" / "bin",
            Path("/usr/local/bin"),
            Path("/usr/bin"),
        ]
        
        for base in common_paths:
            for name in possible_names:
                tool_path = base / name
                if tool_path.exists():
                    self._tool_cache[tool_name] = tool_path
                    return tool_path
        
        return None
    
    def execute(self, tool_name: str, args: List[str] = None, 
                cwd: Optional[Path] = None) -> Tuple[int, str, str]:
        """Execute a tool and return (returncode, stdout, stderr)."""
        tool_path = self.find_tool(tool_name)
        
        if not tool_path:
            return (-1, "", f"Tool not found: {tool_name}")
        
        cmd = [str(tool_path)] + (args or [])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=cwd,
                timeout=300,  # 5 minute timeout
            )
            return (result.returncode, result.stdout, result.stderr)
        except subprocess.TimeoutExpired:
            return (-2, "", "Command timed out")
        except Exception as e:
            return (-3, "", str(e))
    
    def execute_interactive(self, tool_name: str, args: List[str] = None):
        """Execute a tool interactively (for shells, etc.)."""
        tool_path = self.find_tool(tool_name)
        
        if not tool_path:
            print(f"Tool not found: {tool_name}")
            return -1
        
        cmd = [str(tool_path)] + (args or [])
        
        try:
            return subprocess.call(cmd)
        except Exception as e:
            print(f"Failed to execute {tool_name}: {e}")
            return -1

# ── Package Manager Abstraction ────────────────────────────────

class PackageManager:
    """Cross-platform package management."""
    
    def __init__(self, platform_info: PlatformInfo):
        self.platform = platform_info
        self._pm = self._detect_package_manager()
    
    def _detect_package_manager(self) -> Optional[str]:
        """Detect the available package manager."""
        if self.platform.type == PlatformType.ANDROID:
            if shutil.which("pkg"):
                return "pkg"  # Termux
            if shutil.which("apt"):
                return "apt"  # Usually in chroot
        elif self.platform.type == PlatformType.LINUX:
            for pm in ["apt", "dnf", "pacman", "zypper", "emerge"]:
                if shutil.which(pm):
                    return pm
        elif self.platform.type == PlatformType.MACOS:
            if shutil.which("brew"):
                return "brew"
        elif self.platform.type == PlatformType.WINDOWS:
            if shutil.which("choco"):
                return "choco"
            if shutil.which("winget"):
                return "winget"
        return None
    
    def install(self, package: str) -> bool:
        """Install a package."""
        if not self._pm:
            print("No package manager found")
            return False
        
        cmd_map = {
            "apt": ["sudo", "apt", "install", "-y", package],
            "dnf": ["sudo", "dnf", "install", "-y", package],
            "pacman": ["sudo", "pacman", "-S", "--noconfirm", package],
            "brew": ["brew", "install", package],
            "pkg": ["pkg", "install", package],
            "choco": ["choco", "install", "-y", package],
            "winget": ["winget", "install", package],
        }
        
        cmd = cmd_map.get(self._pm)
        if not cmd:
            return False
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0
        except Exception:
            return False

# ── Singleton Access ─────────────────────────────────────────

_platform_info: Optional[PlatformInfo] = None
_executor: Optional[ToolExecutor] = None
_pkg_manager: Optional[PackageManager] = None

def get_platform() -> PlatformInfo:
    """Get platform info singleton."""
    global _platform_info
    if _platform_info is None:
        _platform_info = PlatformInfo()
    return _platform_info

def get_executor() -> ToolExecutor:
    """Get tool executor singleton."""
    global _executor
    if _executor is None:
        _executor = ToolExecutor(get_platform())
    return _executor

def get_package_manager() -> PackageManager:
    """Get package manager singleton."""
    global _pkg_manager
    if _pkg_manager is None:
        _pkg_manager = PackageManager(get_platform())
    return _pkg_manager

# ── Convenience Functions ─────────────────────────────────────

def run_tool(tool_name: str, args: List[str] = None) -> Tuple[int, str, str]:
    """Run a tool (convenience function)."""
    return get_executor().execute(tool_name, args)

def platform_supports(feature: str) -> bool:
    """Check if current platform supports a feature."""
    return get_platform().supports_feature(feature)

def is_android() -> bool:
    """Check if running on Android."""
    return get_platform().type in [PlatformType.ANDROID, PlatformType.ANDROID_CHROOT]

def is_linux() -> bool:
    """Check if running on Linux."""
    return get_platform().type == PlatformType.LINUX

def is_macos() -> bool:
    """Check if running on macOS."""
    return get_platform().type == PlatformType.MACOS

def is_wsl() -> bool:
    """Check if running under WSL."""
    return get_platform().type == PlatformType.WSL

if __name__ == "__main__":
    # Test platform detection
    platform = get_platform()
    print(f"Platform: {platform}")
    print(f"Supports eBPF: {platform_supports('ebpf')}")
    print(f"Supports Docker: {platform_supports('docker')}")
    print(f"Package manager: {get_package_manager()._pm}")
