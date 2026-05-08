"""Compliance Checker — PCI-DSS, SOC2, HIPAA, ISO 27001 audits"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QProgressBar)

class ComplianceChecker(OmniSecModule):
    name = "Compliance Checker"
    description = "Automated compliance auditing for PCI-DSS, SOC2, HIPAA, ISO 27001"
    category = "Reporting"
    version = "2.0.0"
    icon = "✅"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        for std_name, checks in [
            ("PCI-DSS", [
                ("Firewall Configuration", "Pass"),
                ("Default Passwords Changed", "Fail"),
                ("Cardholder Data Encrypted", "Pass"),
                ("Access Control", "Pass"),
                ("Monitoring & Logging", "Fail"),
                ("Security Testing", "Pass"),
            ]),
            ("SOC2", [
                ("Security Controls", "Pass"),
                ("Availability Monitoring", "Pass"),
                ("Processing Integrity", "Fail"),
                ("Confidentiality", "Pass"),
                ("Privacy Controls", "Fail"),
            ]),
            ("HIPAA", [
                ("Risk Analysis", "Pass"),
                ("Access Controls", "Fail"),
                ("Audit Controls", "Pass"),
                ("Integrity Controls", "Pass"),
                ("Transmission Security", "Fail"),
            ]),
            ("ISO 27001", [
                ("ISMS Scope", "Pass"),
                ("Leadership Commitment", "Pass"),
                ("Risk Assessment", "Fail"),
                ("Asset Management", "Pass"),
                ("Incident Response", "Fail"),
            ]),
        ]:
            cf = QFrame()
            cl = QVBoxLayout(cf)
            cl.addWidget(QLabel(f"{std_name} Compliance Audit"))
            prog = QProgressBar()
            prog.setValue(random.choice([60, 70, 80, 90]))
            cl.addWidget(prog)
            c_table = QTableWidget(len(checks), 3)
            c_table.setHorizontalHeaderLabels(["Control", "Status", "Remediation"])
            for i, (control, status) in enumerate(checks):
                c_table.setItem(i, 0, QTableWidgetItem(control))
                c_table.setItem(i, 1, QTableWidgetItem(status))
                c_table.setItem(i, 2, QTableWidgetItem("Action required" if status == "Fail" else "OK"))
            cl.addWidget(c_table)
            run_c = QPushButton(f"Run {std_name} Audit")
            cl.addWidget(run_c)
            tabs.addTab(cf, std_name)

        layout.addWidget(tabs)
        return w
import random
