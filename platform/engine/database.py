"""
OmniSec ULTIMATE — Database Management
Centralized SQLite database manager with connection pooling
"""
import sqlite3
import threading
import json
from pathlib import Path
from typing import Optional, List, Tuple, Any, Dict
from contextlib import contextmanager
from datetime import datetime

from .config import DB_DIR, get_db_path

class DatabaseManager:
    """Centralized database manager with connection pooling"""
    
    _instances = {}
    _lock = threading.Lock()
    
    def __new__(cls, db_name: str):
        """Singleton per database name"""
        with cls._lock:
            if db_name not in cls._instances:
                instance = super().__new__(cls)
                cls._instances[db_name] = instance
                instance._initialized = False
            return cls._instances[db_name]
    
    def __init__(self, db_name: str):
        """Initialize database manager"""
        if self._initialized:
            return
            
        self.db_name = db_name
        self.db_path = get_db_path(db_name)
        self._local = threading.local()
        self._initialized = True
        
        # Ensure database directory exists
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
    
    def get_connection(self) -> sqlite3.Connection:
        """Get thread-local database connection"""
        if not hasattr(self._local, 'conn'):
            self._local.conn = sqlite3.connect(
                str(self.db_path),
                check_same_thread=False,
                timeout=30.0
            )
            self._local.conn.row_factory = sqlite3.Row
            # Enable WAL mode for better concurrency
            self._local.conn.execute("PRAGMA journal_mode=WAL")
            self._local.conn.execute("PRAGMA synchronous=NORMAL")
            self._local.conn.execute("PRAGMA foreign_keys=ON")
        return self._local.conn
    
    @contextmanager
    def transaction(self):
        """Context manager for database transactions"""
        conn = self.get_connection()
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
    
    def execute(self, query: str, params: Tuple = ()) -> sqlite3.Cursor:
        """Execute a query and return cursor"""
        conn = self.get_connection()
        return conn.execute(query, params)
    
    def executemany(self, query: str, params_list: List[Tuple]) -> sqlite3.Cursor:
        """Execute query with multiple parameter sets"""
        conn = self.get_connection()
        cursor = conn.executemany(query, params_list)
        conn.commit()
        return cursor
    
    def fetchone(self, query: str, params: Tuple = ()) -> Optional[sqlite3.Row]:
        """Execute query and fetch one result"""
        cursor = self.execute(query, params)
        return cursor.fetchone()
    
    def fetchall(self, query: str, params: Tuple = ()) -> List[sqlite3.Row]:
        """Execute query and fetch all results"""
        cursor = self.execute(query, params)
        return cursor.fetchall()
    
    def insert(self, table: str, data: Dict[str, Any]) -> int:
        """Insert row and return last row id"""
        columns = ", ".join(data.keys())
        placeholders = ", ".join(["?" for _ in data])
        query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders})"
        
        with self.transaction() as conn:
            cursor = conn.execute(query, tuple(data.values()))
            return cursor.lastrowid
    
    def update(self, table: str, data: Dict[str, Any], where: str, where_params: Tuple = ()) -> int:
        """Update rows and return number of affected rows"""
        set_clause = ", ".join([f"{k} = ?" for k in data.keys()])
        query = f"UPDATE {table} SET {set_clause} WHERE {where}"
        
        with self.transaction() as conn:
            cursor = conn.execute(query, tuple(data.values()) + where_params)
            return cursor.rowcount
    
    def delete(self, table: str, where: str, where_params: Tuple = ()) -> int:
        """Delete rows and return number of affected rows"""
        query = f"DELETE FROM {table} WHERE {where}"
        
        with self.transaction() as conn:
            cursor = conn.execute(query, where_params)
            return cursor.rowcount
    
    def table_exists(self, table_name: str) -> bool:
        """Check if table exists"""
        result = self.fetchone(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            (table_name,)
        )
        return result is not None
    
    def create_table(self, table_name: str, schema: str):
        """Create table if it doesn't exist"""
        query = f"CREATE TABLE IF NOT EXISTS {table_name} ({schema})"
        with self.transaction() as conn:
            conn.execute(query)
    
    def vacuum(self):
        """Optimize database (reclaim space)"""
        conn = self.get_connection()
        conn.execute("VACUUM")
    
    def backup(self, backup_path: Path):
        """Backup database to file"""
        import shutil
        shutil.copy2(self.db_path, backup_path)
    
    def close(self):
        """Close connection for current thread"""
        if hasattr(self._local, 'conn'):
            self._local.conn.close()
            delattr(self._local, 'conn')
    
    @classmethod
    def close_all(cls):
        """Close all connections in all threads"""
        with cls._lock:
            for instance in cls._instances.values():
                instance.close()

# Pre-configured database managers
siem_db = DatabaseManager("siem")
assets_db = DatabaseManager("assets")
threat_intel_db = DatabaseManager("threat_intel")
compliance_db = DatabaseManager("compliance")
ueba_db = DatabaseManager("ueba")

def init_siem_schema():
    """Initialize SIEM database schema"""
    siem_db.create_table("events", """
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        source TEXT NOT NULL,
        event_type TEXT NOT NULL,
        severity TEXT NOT NULL,
        data TEXT NOT NULL,
        indexed INTEGER DEFAULT 0
    """)
    
    siem_db.create_table("alerts", """
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        rule TEXT NOT NULL,
        severity TEXT NOT NULL,
        events TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'new',
        assigned_to TEXT,
        notes TEXT
    """)
    
    # Create indexes
    siem_db.execute("CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp)")
    siem_db.execute("CREATE INDEX IF NOT EXISTS idx_events_severity ON events(severity)")
    siem_db.execute("CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status)")

def init_assets_schema():
    """Initialize Assets database schema"""
    assets_db.create_table("assets", """
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ip TEXT UNIQUE NOT NULL,
        hostname TEXT,
        os TEXT,
        services TEXT,
        first_seen TEXT NOT NULL,
        last_seen TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        risk_score INTEGER DEFAULT 0
    """)
    
    assets_db.create_table("services", """
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        asset_id INTEGER NOT NULL,
        port INTEGER NOT NULL,
        protocol TEXT NOT NULL,
        service TEXT,
        version TEXT,
        banner TEXT,
        FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE
    """)
    
    assets_db.execute("CREATE INDEX IF NOT EXISTS idx_assets_ip ON assets(ip)")
    assets_db.execute("CREATE INDEX IF NOT EXISTS idx_services_asset ON services(asset_id)")

def init_threat_intel_schema():
    """Initialize Threat Intelligence database schema"""
    threat_intel_db.create_table("iocs", """
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ioc_type TEXT NOT NULL,
        value TEXT UNIQUE NOT NULL,
        source TEXT NOT NULL,
        confidence INTEGER DEFAULT 50,
        first_seen TEXT NOT NULL,
        last_seen TEXT NOT NULL,
        tags TEXT,
        metadata TEXT
    """)
    
    threat_intel_db.create_table("feeds", """
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        url TEXT NOT NULL,
        feed_type TEXT NOT NULL,
        enabled INTEGER DEFAULT 1,
        last_update TEXT,
        update_interval INTEGER DEFAULT 3600
    """)
    
    threat_intel_db.execute("CREATE INDEX IF NOT EXISTS idx_iocs_value ON iocs(value)")
    threat_intel_db.execute("CREATE INDEX IF NOT EXISTS idx_iocs_type ON iocs(ioc_type)")

def init_all_schemas():
    """Initialize all database schemas"""
    init_siem_schema()
    init_assets_schema()
    init_threat_intel_schema()
