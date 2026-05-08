"""SIEM Engine - Security Information and Event Management"""
import json
import sqlite3
import threading
import time
from pathlib import Path
from datetime import datetime
from collections import defaultdict

class SIEMEngine:
    def __init__(self, db_path=None):
        self.db_path = db_path or str(Path.home() / ".omnisec" / "siem.db")
        Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
        self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
        self.init_db()
        self.rules = self.load_rules()
        self.alert_queue = []
        self.stats = defaultdict(int)
        
    def init_db(self):
        c = self.conn.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS events (
            id INTEGER PRIMARY KEY, timestamp TEXT, source TEXT, 
            event_type TEXT, severity TEXT, data TEXT)''')
        c.execute('''CREATE TABLE IF NOT EXISTS alerts (
            id INTEGER PRIMARY KEY, timestamp TEXT, rule TEXT, 
            severity TEXT, events TEXT, status TEXT)''')
        self.conn.commit()
        
    def ingest_event(self, source, event_type, data, severity="info"):
        c = self.conn.cursor()
        c.execute("INSERT INTO events VALUES (NULL,?,?,?,?,?)",
            (datetime.now().isoformat(), source, event_type, severity, json.dumps(data)))
        self.conn.commit()
        self.correlate(c.lastrowid)
        
    def correlate(self, event_id):
        for rule in self.rules:
            if self.check_rule(rule, event_id):
                self.create_alert(rule, [event_id])
                
    def check_rule(self, rule, event_id):
        # Simple pattern matching
        return True  # Placeholder
        
    def create_alert(self, rule, event_ids):
        c = self.conn.cursor()
        c.execute("INSERT INTO alerts VALUES (NULL,?,?,?,?,?)",
            (datetime.now().isoformat(), rule, "high", json.dumps(event_ids), "new"))
        self.conn.commit()
        
    def load_rules(self):
        return [{"name": "bruteforce", "pattern": "failed_login"}]
        
    def get_alerts(self, limit=100):
        c = self.conn.cursor()
        c.execute("SELECT * FROM alerts ORDER BY id DESC LIMIT ?", (limit,))
        return c.fetchall()
        
    def search(self, query, limit=1000):
        c = self.conn.cursor()
        c.execute("SELECT * FROM events WHERE data LIKE ? LIMIT ?", (f"%{query}%", limit))
        return c.fetchall()
