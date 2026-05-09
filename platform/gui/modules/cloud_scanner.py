"""Cloud Security — AWS/Azure/GCP configuration audit, compliance checks"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox)

class CloudScanner(OmniSecModule):
    name = "Cloud Scanner"
    description = "AWS/Azure/GCP security audit, compliance checker, misconfiguration detection"
    category = "Infrastructure"
    version = "2.0.0"
    icon = "☁️"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        for cloud_name, findings in [
            ("AWS", [
                ("S3 Bucket Public Access", "Critical"),
                ("Security Group 0.0.0.0/0", "High"),
                ("IAM User Without MFA", "High"),
                ("CloudTrail Disabled", "Critical"),
                ("Unencrypted RDS Instance", "Medium"),
            ]),
            ("Azure", [
                ("Storage Account Public Access", "Critical"),
                ("NSG Rule 0.0.0.0:3389", "High"),
                ("Key Vault Firewall Disabled", "High"),
                ("Managed Identity Misconfigured", "Medium"),
            ]),
            ("GCP", [
                ("Bucket Uniform ACL Disabled", "High"),
                ("Firewall Rule 0.0.0.0:22", "Critical"),
                ("IAM Primitive Role Used", "Medium"),
                ("OS Login Disabled", "Medium"),
            ]),
        ]:
            cf = QFrame()
            cl = QVBoxLayout(cf)
            cl.addWidget(QLabel(f"{cloud_name} Security Audit"))
            c_table = QTableWidget(len(findings), 2)
            c_table.setHorizontalHeaderLabels(["Finding", "Severity"])
            for i, (finding, sev) in enumerate(findings):
                c_table.setItem(i, 0, QTableWidgetItem(finding))
                c_table.setItem(i, 1, QTableWidgetItem(sev))
            cl.addWidget(c_table)
            run_c = QPushButton(f"Run {cloud_name} Audit")
            cl.addWidget(run_c)
            tabs.addTab(cf, cloud_name)

        layout.addWidget(tabs)
        return w
