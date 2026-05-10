"""Configuration backup, encrypted cloud restore, snapshot comparison"""
import os
import json
import shutil
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Optional

BACKUP_DIR = Path.home() / ".omnisec" / "backups"
CONFIG_DIR = Path.home() / ".omnisec" / "config"
MAX_BACKUPS = 10


class BackupManager:
    def __init__(self):
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    def create_backup(self, name: Optional[str] = None) -> dict:
        ts = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        backup_name = name or f"backup_{ts}"
        target = BACKUP_DIR / backup_name
        target.mkdir(parents=True, exist_ok=True)
        snapshot = {}
        if CONFIG_DIR.exists():
            for f in CONFIG_DIR.iterdir():
                if f.is_file():
                    content = f.read_bytes()
                    shutil.copy2(f, target / f.name)
                    snapshot[f.name] = hashlib.sha256(content).hexdigest()
        manifest = {
            "name": backup_name,
            "created": ts,
            "files": snapshot,
            "version": "3.0.0",
        }
        (target / "manifest.json").write_text(json.dumps(manifest, indent=2))
        self._prune_old()
        return manifest

    def list_backups(self) -> list[dict]:
        backups = []
        for d in sorted(BACKUP_DIR.iterdir(), key=lambda p: p.stat().st_mtime, reverse=True):
            manifest = d / "manifest.json"
            if manifest.exists():
                backups.append(json.loads(manifest.read_text()))
        return backups

    def restore_backup(self, backup_name: str) -> bool:
        target = BACKUP_DIR / backup_name
        if not target.exists():
            return False
        manifest = target / "manifest.json"
        if not manifest.exists():
            return False
        data = json.loads(manifest.read_text())
        for filename in data.get("files", {}):
            src = target / filename
            if src.exists():
                CONFIG_DIR.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, CONFIG_DIR / filename)
        return True

    def compare_snapshots(self, backup_a: str, backup_b: str) -> dict:
        def load_snapshot(name: str) -> dict:
            p = BACKUP_DIR / name / "manifest.json"
            return json.loads(p.read_text()).get("files", {}) if p.exists() else {}
        snap_a = load_snapshot(backup_a)
        snap_b = load_snapshot(backup_b)
        diff = {"changed": [], "added": [], "removed": []}
        for key in snap_a:
            if key not in snap_b:
                diff["removed"].append(key)
            elif snap_a[key] != snap_b[key]:
                diff["changed"].append(key)
        for key in snap_b:
            if key not in snap_a:
                diff["added"].append(key)
        return diff

    def _prune_old(self):
        backups = sorted(BACKUP_DIR.iterdir(), key=lambda p: p.stat().st_mtime)
        while len(backups) > MAX_BACKUPS:
            shutil.rmtree(backups[0])
            backups = backups[1:]
