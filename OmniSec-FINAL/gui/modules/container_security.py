"""Container Security — Docker/K8s audit, image scanning, runtime security"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QCheckBox)

class ContainerSecurity(OmniSecModule):
    name = "Container Security"
    description = "Docker/K8s audit, image scanning, runtime security checks"
    category = "Infrastructure"
    version = "2.0.0"
    icon = "🐳"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        img = QFrame()
        il = QVBoxLayout(img)
        il.addWidget(QLabel("Image Scanner"))
        i_row = QHBoxLayout()
        i_row.addWidget(QLabel("Image:"))
        img_input = QLineEdit("nginx:latest")
        i_row.addWidget(img_input)
        scan_btn = QPushButton("Scan Image")
        i_row.addWidget(scan_btn)
        il.addLayout(i_row)
        i_table = QTableWidget(5, 3)
        i_table.setHorizontalHeaderLabels(["Vulnerability", "Severity", "Fix Version"])
        for i, (vuln, sev, fix) in enumerate([
            ("CVE-2024-0001", "Critical", "1.25.3"),
            ("CVE-2024-0002", "High", "1.25.2"),
            ("CVE-2024-0003", "Medium", "1.24.1"),
            ("CVE-2024-0004", "Low", "N/A"),
            ("CVE-2024-0005", "High", "1.25.0"),
        ]):
            i_table.setItem(i, 0, QTableWidgetItem(vuln))
            i_table.setItem(i, 1, QTableWidgetItem(sev))
            i_table.setItem(i, 2, QTableWidgetItem(fix))
        il.addWidget(i_table)
        tabs.addTab(img, "Image Scanner")

        k8s = QFrame()
        kl = QVBoxLayout(k8s)
        kl.addWidget(QLabel("Kubernetes Audit"))
        k_table = QTableWidget(6, 3)
        k_table.setHorizontalHeaderLabels(["Check", "Status", "Risk"])
        for i, (check, status, risk) in enumerate([
            ("RBAC Enabled", "Pass", "Low"),
            ("Pod Security Policy", "Fail", "Critical"),
            ("Secrets Encryption", "Fail", "High"),
            ("Network Policies", "Pass", "Low"),
            ("Resource Limits", "Fail", "Medium"),
            ("Container Privileges", "Fail", "Critical"),
        ]):
            k_table.setItem(i, 0, QTableWidgetItem(check))
            k_table.setItem(i, 1, QTableWidgetItem(status))
            k_table.setItem(i, 2, QTableWidgetItem(risk))
        kl.addWidget(k_table)
        run_k = QPushButton("Run K8s Audit")
        kl.addWidget(run_k)
        tabs.addTab(k8s, "K8s Audit")

        runtime = QFrame()
        rl = QVBoxLayout(runtime)
        rl.addWidget(QLabel("Runtime Security"))
        r_table = QTableWidget(4, 3)
        r_table.setHorizontalHeaderLabels(["Container", "Process", "Alert"])
        for i, (ctr, proc, alert) in enumerate([
            ("web-app", "bash", "Shell spawned in container"),
            ("api-server", "curl", "Outbound connection blocked"),
            ("db", "mysqld", "Expected behavior"),
            ("cache", "redis-cli", "Interactive session detected"),
        ]):
            r_table.setItem(i, 0, QTableWidgetItem(ctr))
            r_table.setItem(i, 1, QTableWidgetItem(proc))
            r_table.setItem(i, 2, QTableWidgetItem(alert))
        rl.addWidget(r_table)
        tabs.addTab(runtime, "Runtime")

        layout.addWidget(tabs)
        return w
