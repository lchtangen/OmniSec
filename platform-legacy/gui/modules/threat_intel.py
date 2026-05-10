"""Threat Intelligence — IOC feeds, threat scoring, intelligence aggregation"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QLineEdit)

class ThreatIntel(OmniSecModule):
    name = "Threat Intelligence"
    description = "IOC management, threat scoring, feed aggregation, indicator lookup"
    category = "Intelligence"
    version = "2.0.0"
    icon = "🛡️"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        ioc = QFrame()
        il = QVBoxLayout(ioc)
        il.addWidget(QLabel("IOC Lookup"))
        ioc_row = QHBoxLayout()
        ioc_row.addWidget(QLabel("Indicator:"))
        ioc_input = QLineEdit("185.220.101.0/24")
        ioc_row.addWidget(ioc_input)
        ioc_btn = QPushButton("Lookup")
        ioc_row.addWidget(ioc_btn)
        il.addLayout(ioc_row)
        ioc_table = QTableWidget(5, 4)
        ioc_table.setHorizontalHeaderLabels(["Indicator", "Type", "Confidence", "Source"])
        for i, (ind, typ, conf, src) in enumerate([
            ("185.220.101.23", "IP", "High", "AlienVault OTX"),
            ("malware.example.com", "Domain", "Very High", "VirusTotal"),
            ("a1b2c3d4e5...", "Hash (SHA256)", "High", "MITRE ATT&CK"),
            ("evil-botnet", "Malware Name", "Medium", "Recorded Future"),
            ("45.33.32.156", "IP", "Very High", "AbuseIPDB"),
        ]):
            ioc_table.setItem(i, 0, QTableWidgetItem(ind))
            ioc_table.setItem(i, 1, QTableWidgetItem(typ))
            ioc_table.setItem(i, 2, QTableWidgetItem(conf))
            ioc_table.setItem(i, 3, QTableWidgetItem(src))
        il.addWidget(ioc_table)
        tabs.addTab(ioc, "IOC Lookup")

        feeds = QFrame()
        fl = QVBoxLayout(feeds)
        fl.addWidget(QLabel("Threat Feeds"))
        feed_list = QListWidget()
        for feed in ["AlienVault OTX - Connected (12,345 IOCs)",
                     "VirusTotal - Connected",
                     "AbuseIPDB - Connected (45,678 entries)",
                     "MITRE ATT&CK v14 - Loaded",
                     "CISA Known Exploits - Updated",
                     "Feodo Tracker - Connected",
                     "URLhaus - Connected"]:
            feed_list.addItem(feed)
        fl.addWidget(feed_list)
        refresh_f = QPushButton("Refresh All Feeds")
        fl.addWidget(refresh_f)
        tabs.addTab(feeds, "Feeds")

        score_t = QFrame()
        sl = QVBoxLayout(score_t)
        sl.addWidget(QLabel("Threat Scoring Engine"))
        sl.addWidget(QLabel("Score an indicator based on multiple feeds:"))
        score_input = QLineEdit("Enter IP/hash/domain...")
        sl.addWidget(score_input)
        score_btn = QPushButton("Calculate Threat Score")
        sl.addWidget(score_btn)
        score_out = QTextEdit()
        score_out.setReadOnly(True)
        score_out.append("[THREAT] Analyzing 185.220.101.23...")
        score_out.append("[THREAT] Threat Score: 87/100 (VERY HIGH)")
        score_out.append("[THREAT] Sources: 4 feeds agree on malicious")
        score_out.append("[THREAT] First seen: 2024-03-15")
        score_out.append("[THREAT] Category: C2 / Botnet")
        sl.addWidget(score_out)
        tabs.addTab(score_t, "Threat Scoring")

        layout.addWidget(tabs)
        return w
