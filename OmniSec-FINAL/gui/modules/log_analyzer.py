"""Log Analyzer — Log parsing, pattern detection, anomaly identification"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QSplitter, QTreeWidget, QTreeWidgetItem)

class LogAnalyzer(OmniSecModule):
    name = "Log Analyzer"
    description = "Log file parsing, pattern detection, anomaly hunting"
    category = "Forensics"
    version = "2.0.0"
    icon = "📊"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Log viewer
        viewer = QFrame()
        vl = QVBoxLayout(viewer)
        source = QComboBox()
        source.addItems(["/var/log/auth.log", "/var/log/syslog", "/var/log/apache2/access.log",
                        "/var/log/nginx/error.log", "Windows Event Log", "Custom File"])
        vl.addWidget(source)
        load_btn = QPushButton("Load Log File")
        vl.addWidget(load_btn)
        log_view = QTextEdit()
        log_view.setReadOnly(True)
        log_view.setStyleSheet("font-family: 'Consolas', monospace; font-size: 10px;")
        for _ in range(30):
            log_view.append(f"May  8 {random.randint(0,23):02d}:{random.randint(0,59):02d}:{random.randint(0,59):02d} "
                          f"{random.choice(['server'])} "
                          f"{random.choice(['sshd','nginx','cron','sudo','kernel'])}: "
                          f"{random.choice(['Accepted password for root','Failed password for admin',
                          'Connection closed by 10.0.0.'+str(random.randint(1,255)),
                          'Session opened for user','New USB device found','Firewall rule added'])}")
        vl.addWidget(log_view)
        tabs.addTab(viewer, "Log Viewer")

        # Anomaly detection
        anomaly = QFrame()
        al = QVBoxLayout(anomaly)
        al.addWidget(QLabel("Anomaly Detection"))
        scan_logs = QPushButton("Scan for Anomalies")
        al.addWidget(scan_logs)
        a_table = QTableWidget(6, 3)
        a_table.setHorizontalHeaderLabels(["Timestamp", "Event", "Risk"])
        for i, (ts, event, risk) in enumerate([
            ("02:14:23", "SSH brute force (1,247 attempts)", "Critical"),
            ("03:45:12", "Privilege escalation (sudo su)", "High"),
            ("04:02:55", "Unknown USB device connected", "Medium"),
            ("05:30:01", "Outbound connection to unknown IP", "High"),
            ("06:15:44", "Cron job modified by non-root", "Critical"),
            ("07:00:12", "Large file transfer (500MB)", "Low"),
        ]):
            a_table.setItem(i, 0, QTableWidgetItem(ts))
            a_table.setItem(i, 1, QTableWidgetItem(event))
            a_table.setItem(i, 2, QTableWidgetItem(risk))
        al.addWidget(a_table)
        tabs.addTab(anomaly, "Anomalies")

        # Patterns
        pat = QFrame()
        pl = QVBoxLayout(pat)
        pl.addWidget(QLabel("Pattern Recognition"))

        pattern_tree = QTreeWidget()
        pattern_tree.setHeaderLabels(["Pattern", "Count", "Severity"])
        patterns = [
            ("SSH Brute Force", "1,247", "Critical"),
            ("Failed Logins", "3,456", "High"),
            ("Port Scans", "892", "Medium"),
            ("SQL Injection Attempts", "156", "Critical"),
            ("XSS Attempts", "89", "High"),
            ("Directory Traversal", "45", "Medium"),
            ("File Upload Attempts", "23", "Low"),
        ]
        for name, count, sev in patterns:
            item = QTreeWidgetItem([name, count, sev])
            if sev == "Critical":
                item.setForeground(2, __import__('PyQt6.QtGui').QColor("#FF0000"))
            elif sev == "High":
                item.setForeground(2, __import__('PyQt6.QtGui').QColor("#FF8C00"))
            pattern_tree.addTopLevelItem(item)
        pl.addWidget(pattern_tree)
        tabs.addTab(pat, "Patterns")

        layout.addWidget(tabs)
        return w
import random
