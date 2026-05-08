"""Asset Discovery & Inventory"""
import subprocess
import sqlite3
from pathlib import Path
from datetime import datetime

class AssetDiscovery:
    def __init__(self):
        self.db = str(Path.home() / ".omnisec" / "assets.db")
        Path(self.db).parent.mkdir(parents=True, exist_ok=True)
        self.conn = sqlite3.connect(self.db)
        self.init_db()
        
    def init_db(self):
        c = self.conn.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS assets (
            id INTEGER PRIMARY KEY, ip TEXT, hostname TEXT, 
            os TEXT, services TEXT, first_seen TEXT, last_seen TEXT)''')
        self.conn.commit()
        
    def discover(self, network):
        try:
            result = subprocess.run(['nmap', '-sn', network], capture_output=True, text=True, timeout=300)
            return self.parse_hosts(result.stdout)
        except:
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
        c = self.conn.cursor()
        now = datetime.now().isoformat()
        c.execute("INSERT OR REPLACE INTO assets VALUES (NULL,?,?,?,?,?,?)",
            (ip, hostname, os, services, now, now))
        self.conn.commit()
