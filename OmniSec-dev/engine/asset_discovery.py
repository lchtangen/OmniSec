"""Asset Discovery & Inventory"""
import subprocess
from datetime import datetime

from .database import assets_db, init_assets_schema
from .config import NMAP_TIMEOUT

class AssetDiscovery:
    def __init__(self):
        # Initialize database schema
        init_assets_schema()
        self.db = assets_db
        
    def discover(self, network):
        try:
            result = subprocess.run(
                ['nmap', '-sn', network],
                capture_output=True,
                text=True,
                timeout=NMAP_TIMEOUT
            )
            return self.parse_hosts(result.stdout)
        except Exception as e:
            print(f"Discovery error: {e}")
            return []
            
    def parse_hosts(self, output):
        hosts = []
        for line in output.split('\n'):
            if 'Nmap scan report for' in line:
                ip = line.split()[-1].strip('()')
                self.add_asset(ip, '', '', '')
                hosts.append(ip)
        return hosts
        
    def add_asset(self, ip, hostname, os, services):
        now = datetime.now().isoformat()
        
        # Check if asset exists
        existing = self.db.fetchone("SELECT id FROM assets WHERE ip = ?", (ip,))
        
        if existing:
            # Update last_seen
            self.db.update(
                "assets",
                {"last_seen": now, "hostname": hostname, "os": os, "services": services},
                "ip = ?",
                (ip,)
            )
        else:
            # Insert new asset
            self.db.insert("assets", {
                "ip": ip,
                "hostname": hostname,
                "os": os,
                "services": services,
                "first_seen": now,
                "last_seen": now,
                "status": "active"
            })
