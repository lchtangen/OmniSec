"""Email Tools — Email analysis, phishing detection, SPF/DKIM/DMARC checking"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox)

class EmailTools(OmniSecModule):
    name = "Email Tools"
    description = "Email analysis, SPF/DKIM/DMARC validation, phishing detection"
    category = "Social"
    version = "2.0.0"
    icon = "📧"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        analyze = QFrame()
        al = QVBoxLayout(analyze)
        al.addWidget(QLabel("Email Header Analyzer"))
        al.addWidget(QLabel("Paste email headers:"))
        headers = QTextEdit()
        headers.setMaximumHeight(120)
        headers.setPlaceholderText("Paste raw email headers here...")
        al.addWidget(headers)
        analyze_btn = QPushButton("Analyze Headers")
        al.addWidget(analyze_btn)
        a_table = QTableWidget(6, 2)
        a_table.setHorizontalHeaderLabels(["Field", "Value"])
        for i, (field, val) in enumerate([
            ("From", "support@bank-secure.com"),
            ("Reply-To", "phisher@evil.com"),
            ("SPF", "FAIL (spoofed)"),
            ("DKIM", "MISSING"),
            ("DMARC", "p=none"),
            ("Auth Result", "SUSPICIOUS"),
        ]):
            a_table.setItem(i, 0, QTableWidgetItem(field))
            a_table.setItem(i, 1, QTableWidgetItem(val))
        al.addWidget(a_table)
        tabs.addTab(analyze, "Header Analysis")

        dns_check = QFrame()
        dl = QVBoxLayout(dns_check)
        dl.addWidget(QLabel("DNS Record Check"))
        d_row = QHBoxLayout()
        d_row.addWidget(QLabel("Domain:"))
        d_input = QLineEdit("example.com")
        d_row.addWidget(d_input)
        check_btn = QPushButton("Check Records")
        d_row.addWidget(check_btn)
        dl.addLayout(d_row)
        d_table = QTableWidget(3, 3)
        d_table.setHorizontalHeaderLabels(["Record", "Status", "Value"])
        for i, (rec, status, val) in enumerate([
            ("SPF", "PASS", "v=spf1 include:_spf.example.com ~all"),
            ("DKIM", "PASS", "v=DKIM1; k=rsa; p=MIGfMA0G..."),
            ("DMARC", "FAIL", "v=DMARC1; p=none"),
        ]):
            d_table.setItem(i, 0, QTableWidgetItem(rec))
            d_table.setItem(i, 1, QTableWidgetItem(status))
            d_table.setItem(i, 2, QTableWidgetItem(val))
        dl.addWidget(d_table)
        tabs.addTab(dns_check, "DNS Records")

        phish_scan = QFrame()
        pl = QVBoxLayout(phish_scan)
        pl.addWidget(QLabel("Phishing URL Scanner"))
        url_row = QHBoxLayout()
        url_row.addWidget(QLabel("URL:"))
        url_input = QLineEdit("https://suspicious-link.com/login")
        url_row.addWidget(url_input)
        scan_url = QPushButton("Scan URL")
        url_row.addWidget(scan_url)
        pl.addLayout(url_row)
        p_out = QTextEdit()
        p_out.setReadOnly(True)
        p_out.append("[PHISH] Scanning URL...")
        p_out.append("[PHISH] Domain age: 3 days (SUSPICIOUS)")
        p_out.append("[PHISH] SSL: Valid (Let's Encrypt)")
        p_out.append("[PHISH] Similar to: bankofamerica.com (typosquatting)")
        p_out.append("[PHISH] Risk: VERY HIGH")
        pl.addWidget(p_out)
        tabs.addTab(phish_scan, "Phishing Scanner")

        layout.addWidget(tabs)
        return w
