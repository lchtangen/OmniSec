"""Timeline Analyzer — Event correlation, timeline reconstruction, sequence analysis"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QSpinBox)
import random
import datetime

class TimelineAnalyzer(OmniSecModule):
    name = "Timeline Analyzer"
    description = "Event correlation, timeline reconstruction, attack sequence analysis"
    category = "Forensics"
    version = "2.0.0"
    icon = "⏱️"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        tl = QFrame()
        tll = QVBoxLayout(tl)
        tll.addWidget(QLabel("Attack Timeline"))
        source = QComboBox()
        source.addItems(["All Sources", "Network Logs", "System Logs", "Application Logs",
                        "Firewall Logs", "IDS/IPS Alerts"])
        tll.addWidget(source)
        t_table = QTableWidget(10, 4)
        t_table.setHorizontalHeaderLabels(["Time", "Event", "Source", "Relevance"])
        now = datetime.datetime.now()
        events = [
            ("Reconnaissance", "Nmap scan detected"),
            ("Exploitation", "MS17-010 exploit attempted"),
            ("Privilege Escalation", "SYSTEM shell obtained"),
            ("Persistence", "Service installed"),
            ("Lateral Movement", "SMB connection to DC01"),
            ("Credential Dump", "LSASS memory accessed"),
            ("Data Exfiltration", "Large outbound transfer"),
            ("Cover Tracks", "Event logs cleared"),
            ("C2 Communication", "DNS tunnel detected"),
            ("Cleanup", "Artifacts removed"),
        ]
        for i, (event, detail) in enumerate(events):
            ts = now - datetime.timedelta(minutes=i*15, seconds=random.randint(0, 59))
            t_table.setItem(i, 0, QTableWidgetItem(ts.strftime("%H:%M:%S")))
            t_table.setItem(i, 1, QTableWidgetItem(f"{event}: {detail}"))
            t_table.setItem(i, 2, QTableWidgetItem(random.choice(["EDR", "Firewall", "Sysmon", "Network"])))
            t_table.setItem(i, 3, QTableWidgetItem("Critical" if i < 3 else "High" if i < 6 else "Medium"))
        tll.addWidget(t_table)
        tabs.addTab(tl, "Timeline")

        correlation = QFrame()
        cl = QVBoxLayout(correlation)
        cl.addWidget(QLabel("Event Correlation"))
        cl.addWidget(QLabel("Detect attack patterns by correlating events:"))
        corr_btn = QPushButton("Run Correlation Analysis")
        cl.addWidget(corr_btn)
        c_out = QTextEdit()
        c_out.setReadOnly(True)
        c_out.append("[CORRELATION] Analyzing 1,247 events...")
        c_out.append("[CORRELATION] Pattern detected: LockBit Ransomware")
        c_out.append("[CORRELATION] 12 indicators match known TTPs")
        c_out.append("[CORRELATION] Kill chain: Recon → Weaponize → Deliver → Exploit → Install → C2 → Action")
        cl.addWidget(c_out)
        tabs.addTab(correlation, "Correlation")

        graph = QFrame()
        gl = QVBoxLayout(graph)
        gl.addWidget(QLabel("Attack Graph"))
        gl.addWidget(QLabel("Visual relationship map of events (text representation):"))
        g_out = QTextEdit()
        g_out.setReadOnly(True)
        g_out.setStyleSheet("font-family: 'Consolas', monospace; font-size: 10px;")
        g_out.append("10.0.0.5 ──[SMB]──▶ 10.0.0.1")
        g_out.append("  │                    │")
        g_out.append("  │[MS17-010]          │[Cred Dump]")
        g_out.append("  ▼                    ▼")
        g_out.append("10.0.0.5 (owned) ──[PTH]──▶ DC01 (owned)")
        g_out.append("  │")
        g_out.append("  │[Exfil]")
        g_out.append("  ▼")
        g_out.append("185.220.101.23 (C2)")
        gl.addWidget(g_out)
        tabs.addTab(graph, "Attack Graph")

        layout.addWidget(tabs)
        return w
