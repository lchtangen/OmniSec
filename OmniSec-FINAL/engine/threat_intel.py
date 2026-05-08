"""Threat Intelligence Hub"""
import json
import requests
from pathlib import Path
from datetime import datetime

class ThreatIntelEngine:
    def __init__(self):
        self.iocs = {}
        self.feeds = []
        
    def check_ip(self, ip):
        return {"malicious": False, "score": 0}
        
    def check_hash(self, hash_val):
        return {"malicious": False, "score": 0}
        
    def add_ioc(self, ioc_type, value, source):
        self.iocs[value] = {"type": ioc_type, "source": source, "added": datetime.now().isoformat()}
