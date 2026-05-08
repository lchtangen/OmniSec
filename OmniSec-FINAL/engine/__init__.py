"""
OmniSec ULTIMATE — Engine Modules
Complete Security Operations Platform
"""

# Original engines
from .hids import HIDSEngine
from .playbooks import PlaybookEngine
from .canary import CanaryEngine
from .notify import NotificationEngine
from .topo import TopologyEngine

# New Phase 1-5 engines
from .siem import SIEMEngine
from .threat_intel import ThreatIntelEngine
from .vuln_scanner import VulnScanner
from .asset_discovery import AssetDiscovery
from .ueba import UEBAEngine
from .compliance import ComplianceEngine
from .api_security import APISecurityScanner
from .auto_pentest import AutoPentestEngine
from .zero_trust import ZeroTrustEngine

__all__ = [
    # Original engines
    "HIDSEngine",
    "PlaybookEngine",
    "CanaryEngine",
    "NotificationEngine",
    "TopologyEngine",
    # New engines
    "SIEMEngine",
    "ThreatIntelEngine",
    "VulnScanner",
    "AssetDiscovery",
    "UEBAEngine",
    "ComplianceEngine",
    "APISecurityScanner",
    "AutoPentestEngine",
    "ZeroTrustEngine",
]
