"""OSINT Toolkit — Reconnaissance, data gathering, social analysis"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QProgressBar, QComboBox)

class OSINTTools(OmniSecModule):
    name = "OSINT Toolkit"
    description = "Open-source intelligence gathering, recon, social analysis"
    category = "OSINT"
    version = "2.0.0"
    icon = "🕵️"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Domain recon
        domain = QFrame()
        dl = QVBoxLayout(domain)
        dl.addWidget(QLabel("Domain Reconnaissance"))
        d_row = QHBoxLayout()
        d_row.addWidget(QLabel("Domain:"))
        d_input = QLineEdit("target-company.com")
        d_row.addWidget(d_input)
        enum_btn = QPushButton("Enumerate")
        d_row.addWidget(enum_btn)
        dl.addLayout(d_row)

        d_table = QTableWidget(6, 3)
        d_table.setHorizontalHeaderLabels(["Type", "Value", "Source"])
        for i, (t, v, s) in enumerate([
            ("A", "192.168.1.10", "DNS"),
            ("MX", "mail.target-company.com", "DNS"),
            ("NS", "ns1.cloudflare.com", "DNS"),
            ("TXT", "v=spf1 include:_spf...", "DNS"),
            ("SOA", "admin.target-company.com", "DNS"),
            ("Subdomain", "dev.target-company.com", "Certificate Transparency"),
        ]):
            d_table.setItem(i, 0, QTableWidgetItem(t))
            d_table.setItem(i, 1, QTableWidgetItem(v))
            d_table.setItem(i, 2, QTableWidgetItem(s))
        dl.addWidget(d_table)
        tabs.addTab(domain, "Domain Recon")

        # Social search
        social = QFrame()
        sl = QVBoxLayout(social)
        sl.addWidget(QLabel("Social Media Analysis"))
        s_row = QHBoxLayout()
        s_row.addWidget(QLabel("Username:"))
        s_input = QLineEdit("target_user")
        s_row.addWidget(s_input)
        search_btn = QPushButton("Search")
        s_row.addWidget(search_btn)
        sl.addLayout(s_row)
        s_results = QListWidget()
        for site in ["GitHub: target_user (3 repos)",
                     "Twitter: @target_user (1,247 tweets)",
                     "LinkedIn: Target User (Software Engineer)",
                     "Reddit: u/target_user (2 years)",
                     "HackerNews: target_user (142 karma)",
                     "StackOverflow: target_user (5,678 reputation)"]:
            s_results.addItem(site)
        sl.addWidget(s_results)
        tabs.addTab(social, "Social Search")

        # Data leaks
        leaks = QFrame()
        ll = QVBoxLayout(leaks)
        ll.addWidget(QLabel("Data Leak Detection"))
        ll.addWidget(QLabel("Checking known breach databases..."))
        leak_table = QTableWidget(4, 3)
        leak_table.setHorizontalHeaderLabels(["Email/Domain", "Leak Source", "Data Exposed"])
        for i, (e, src, data) in enumerate([
            ("@target-company.com", "LinkedIn 2021", "Emails, passwords"),
            ("@target-company.com", "Adobe 2013", "Emails, password hints"),
            ("admin@target.com", "Collection #1", "Email, password"),
            ("dev@target.com", "HaveIBeenPwned", "Email only"),
        ]):
            leak_table.setItem(i, 0, QTableWidgetItem(e))
            leak_table.setItem(i, 1, QTableWidgetItem(src))
            leak_table.setItem(i, 2, QTableWidgetItem(data))
        ll.addWidget(leak_table)
        tabs.addTab(leaks, "Data Leaks")

        layout.addWidget(tabs)
        return w
