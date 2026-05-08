"""Backup Manager — Configuration backup/restore, snapshot management"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QCheckBox, QGroupBox)

class BackupManager(OmniSecModule):
    name = "Backup Manager"
    description = "Configuration backup/restore, snapshot management, export/import"
    category = "Core"
    version = "2.0.0"
    icon = "💾"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        backup = QFrame()
        bl = QVBoxLayout(backup)
        bl.addWidget(QLabel("Backup Configuration"))
        items = QGroupBox("Include in Backup:")
        il = QVBoxLayout(items)
        for item in ["Tool configurations", "Custom playbooks", "AI model settings",
                     "Network profiles", "Credential store (encrypted)",
                     "Report templates", "SSL certificates", "Extension/modules"]:
            il.addWidget(QCheckBox(item))
        bl.addWidget(items)
        dest = QLineEdit("/home/user/omnisec-backups/")
        bl.addWidget(dest)
        btn_row = QHBoxLayout()
        create_b = QPushButton("Create Backup")
        create_b.setObjectName("success")
        btn_row.addWidget(create_b)
        schedule_b = QPushButton("Schedule Daily Backup")
        btn_row.addWidget(schedule_b)
        bl.addLayout(btn_row)
        tabs.addTab(backup, "Backup")

        restore = QFrame()
        rl = QVBoxLayout(restore)
        rl.addWidget(QLabel("Restore from Backup"))
        snapshots = QListWidget()
        snapshots.addItem("2026-05-08 04:00 - Pre-audit snapshot")
        snapshots.addItem("2026-05-07 04:00 - Daily backup")
        snapshots.addItem("2026-05-06 04:00 - Daily backup")
        snapshots.addItem("2026-05-05 04:00 - Post-config change")
        snapshots.addItem("2026-05-01 00:00 - Clean baseline")
        rl.addWidget(snapshots)
        restore_btn = QPushButton("Restore Selected Snapshot")
        restore_btn.setObjectName("danger")
        rl.addWidget(restore_btn)
        tabs.addTab(restore, "Restore")

        export_t = QFrame()
        el = QVBoxLayout(export_t)
        el.addWidget(QLabel("Export / Import"))
        el.addWidget(QLabel("Export configurations for transfer to another machine:"))
        export_btn = QPushButton("Export Configuration")
        el.addWidget(export_btn)
        el.addWidget(QLabel("Import configurations:"))
        import_btn = QPushButton("Import Configuration")
        el.addWidget(import_btn)
        tabs.addTab(export_t, "Export/Import")

        layout.addWidget(tabs)
        return w
