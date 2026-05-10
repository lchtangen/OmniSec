"""Granular permission model for tool execution"""
from enum import Enum
from dataclasses import dataclass, field
from typing import Optional


class Permission(Enum):
    NETWORK_SCAN = "network_scan"
    PACKET_CAPTURE = "packet_capture"
    FILE_READ = "file_read"
    FILE_WRITE = "file_write"
    PROCESS_INJECT = "process_inject"
    KEYSTROKE_CAPTURE = "keystroke_capture"
    USB_ACCESS = "usb_access"
    BLUETOOTH_SCAN = "bluetooth_scan"
    GPS_ACCESS = "gps_access"
    CAMERA_ACCESS = "camera_access"
    MICROPHONE_ACCESS = "microphone_access"
    ROOT_EXECUTION = "root_execution"
    INSTALL_PACKAGES = "install_packages"
    MODIFY_NETWORK = "modify_network"
    EXECUTE_CODE = "execute_code"
    ACCESS_KEYRING = "access_keyring"


@dataclass
class ToolPermission:
    tool_name: str
    permissions: list[Permission] = field(default_factory=list)
    requires_root: bool = False
    sandbox_level: int = 1  # 0=none, 1=basic, 2=container, 3=VM
    timeout_seconds: int = 300
    memory_limit_mb: int = 512
    network_allowed: bool = False
    audit_logging: bool = True


@dataclass
class PermissionRequest:
    tool: str
    permission: Permission
    reason: str
    allow_once: bool = True


TOOL_PERMISSIONS: dict[str, ToolPermission] = {
    "nmap": ToolPermission("nmap", [Permission.NETWORK_SCAN], sandbox_level=1, network_allowed=True),
    "wireshark": ToolPermission("wireshark", [Permission.PACKET_CAPTURE], requires_root=True, sandbox_level=2),
    "aircrack": ToolPermission("aircrack", [Permission.NETWORK_SCAN, Permission.PACKET_CAPTURE],
                                requires_root=True, sandbox_level=2, network_allowed=True),
    "hashcat": ToolPermission("hashcat", [], sandbox_level=1, timeout_seconds=86400),
    "metasploit": ToolPermission("metasploit", [Permission.NETWORK_SCAN, Permission.EXECUTE_CODE],
                                  sandbox_level=2, network_allowed=True),
}


class PermissionManager:
    def __init__(self):
        self.grants: dict[str, list[Permission]] = {}
        self.session_grants: set[str] = set()

    def check_permission(self, tool: str, permission: Permission) -> bool:
        key = f"{tool}:{permission.value}"
        return key in self.session_grants or permission in self.grants.get(tool, [])

    def grant_permission(self, tool: str, permission: Permission, session_only: bool = True):
        key = f"{tool}:{permission.value}"
        if session_only:
            self.session_grants.add(key)
        else:
            self.grants.setdefault(tool, []).append(permission)

    def revoke_all(self):
        self.session_grants.clear()
        self.grants.clear()

    def get_tool_info(self, tool_name: str) -> Optional[ToolPermission]:
        return TOOL_PERMISSIONS.get(tool_name)

    def get_required_permissions(self, tool_name: str) -> list[Permission]:
        tp = self.get_tool_info(tool_name)
        return tp.permissions if tp else []

    def requires_root(self, tool_name: str) -> bool:
        tp = self.get_tool_info(tool_name)
        return tp.requires_root if tp else False
