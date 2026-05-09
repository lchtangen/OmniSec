"""Vulnerability Database — CVE browser, exploit search, vulnerability lookup"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QSplitter)

class VulnDatabase(OmniSecModule):
    name = "Vulnerability DB"
    description = "CVE browser, exploit-db search, vulnerability intelligence"
    category = "Intelligence"
    version = "2.0.0"
    icon = "📋"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # CVE Browser
        cve = QFrame()
        cl = QVBoxLayout(cve)
        search_row = QHBoxLayout()
        search_row.addWidget(QLabel("Search CVE:"))
        cve_search = QLineEdit("Apache Log4j")
        search_row.addWidget(cve_search)
        cve_btn = QPushButton("Search")
        search_row.addWidget(cve_btn)
        cl.addLayout(search_row)
        cve_table = QTableWidget(8, 4)
        cve_table.setHorizontalHeaderLabels(["CVE ID", "Score", "Published", "Description"])
        for i, (cve_id, score, pub, desc) in enumerate([
            ("CVE-2021-44228", "10.0", "2021-12-09", "Apache Log4j RCE"),
            ("CVE-2022-22965", "9.8", "2022-03-29", "Spring4Shell RCE"),
            ("CVE-2023-44487", "7.5", "2023-10-10", "HTTP/2 Rapid Reset DDoS"),
            ("CVE-2024-1708", "9.1", "2024-02-15", "ScreenConnect Auth Bypass"),
            ("CVE-2024-21626", "8.6", "2024-01-31", "runc Container Escape"),
            ("CVE-2023-46604", "9.8", "2023-10-27", "Apache ActiveMQ RCE"),
            ("CVE-2022-41082", "8.3", "2022-11-08", "MS Exchange RCE"),
            ("CVE-2024-20656", "7.5", "2024-01-09", "VS Code RCE"),
        ]):
            cve_table.setItem(i, 0, QTableWidgetItem(cve_id))
            cve_table.setItem(i, 1, QTableWidgetItem(score))
            cve_table.setItem(i, 2, QTableWidgetItem(pub))
            cve_table.setItem(i, 3, QTableWidgetItem(desc))
        cl.addWidget(cve_table)
        tabs.addTab(cve, "CVE Browser")

        # Exploit Search
        exp = QFrame()
        el = QVBoxLayout(exp)
        el.addWidget(QLabel("Exploit Database"))
        exp_row = QHBoxLayout()
        exp_row.addWidget(QLabel("Search:"))
        exp_search = QLineEdit("Apache Tomcat")
        exp_row.addWidget(exp_search)
        exp_btn = QPushButton("Search Exploits")
        exp_row.addWidget(exp_btn)
        el.addLayout(exp_row)
        exp_list = QListWidget()
        for exploit in [
            "Apache Tomcat - AJP File Read (CVE-2020-1938)",
            "Apache Tomcat - Manager App Bruteforce",
            "Apache Tomcat - Ghostcat LFI",
            "Apache Tomcat - PUT Method RCE",
            "Apache Tomcat - Deployment RCE",
        ]:
            exp_list.addItem(exploit)
        el.addWidget(exp_list)
        view_exp = QPushButton("View Exploit Details")
        el.addWidget(view_exp)
        tabs.addTab(exp, "Exploit Search")

        # Advisories
        adv = QFrame()
        al = QVBoxLayout(adv)
        al.addWidget(QLabel("Security Advisories"))
        adv_list = QListWidget()
        for a in [
            "[CRITICAL] CVE-2024-0001 - OpenSSH RCE (Patch Now)",
            "[HIGH] CVE-2024-0002 - Windows Kerberos EoP",
            "[MEDIUM] CVE-2024-0003 - Chrome V8 Sandbox Escape",
            "[INFO] CVE-2024-0004 - Python urllib Request Smuggling",
            "[CRITICAL] CVE-2024-0005 - Linux Kernel Privilege Escalation",
        ]:
            adv_list.addItem(a)
        al.addWidget(adv_list)
        refresh_adv = QPushButton("Refresh Advisories")
        al.addWidget(refresh_adv)
        tabs.addTab(adv, "Advisories")

        layout.addWidget(tabs)
        return w
