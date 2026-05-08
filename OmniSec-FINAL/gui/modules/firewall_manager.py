"""Firewall Manager — iptables/nftables management, rule builder, traffic filtering"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QSpinBox)

class FirewallManager(OmniSecModule):
    name = "Firewall Manager"
    description = "iptables/nftables management, rule builder, traffic filtering"
    category = "Network"
    version = "2.0.0"
    icon = "🔥"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        rules = QFrame()
        rl = QVBoxLayout(rules)
        rl.addWidget(QLabel("Firewall Rules"))
        r_table = QTableWidget(6, 5)
        r_table.setHorizontalHeaderLabels(["Chain", "Rule", "Action", "Proto", "Active"])
        for i, (chain, rule, action, proto, active) in enumerate([
            ("INPUT", "-s 10.0.0.0/24", "ACCEPT", "ALL", "Yes"),
            ("INPUT", "--dport 22", "ACCEPT", "TCP", "Yes"),
            ("INPUT", "--dport 80", "ACCEPT", "TCP", "Yes"),
            ("INPUT", "--dport 443", "ACCEPT", "TCP", "Yes"),
            ("INPUT", "-s 0.0.0.0/0", "DROP", "ALL", "Yes"),
            ("FORWARD", "-j DROP", "DROP", "ALL", "Yes"),
        ]):
            r_table.setItem(i, 0, QTableWidgetItem(chain))
            r_table.setItem(i, 1, QTableWidgetItem(rule))
            r_table.setItem(i, 2, QTableWidgetItem(action))
            r_table.setItem(i, 3, QTableWidgetItem(proto))
            r_table.setItem(i, 4, QTableWidgetItem(active))
        rl.addWidget(r_table)
        btn_row = QHBoxLayout()
        btn_row.addWidget(QPushButton("Add Rule"))
        btn_row.addWidget(QPushButton("Remove Rule"))
        btn_row.addWidget(QPushButton("Apply"))
        rl.addLayout(btn_row)
        tabs.addTab(rules, "Rules")

        builder = QFrame()
        bl = QVBoxLayout(builder)
        bl.addWidget(QLabel("Rule Builder"))
        chain_combo = QComboBox()
        chain_combo.addItems(["INPUT", "OUTPUT", "FORWARD"])
        bl.addWidget(chain_combo)
        bl.addWidget(QLabel("Source:"))
        src_input = QLineEdit("0.0.0.0/0")
        bl.addWidget(src_input)
        bl.addWidget(QLabel("Port:"))
        port_spin = QSpinBox()
        port_spin.setRange(1, 65535)
        port_spin.setValue(80)
        bl.addWidget(port_spin)
        action_combo = QComboBox()
        action_combo.addItems(["ACCEPT", "DROP", "REJECT", "LOG"])
        bl.addWidget(action_combo)
        add_btn = QPushButton("Create Rule")
        bl.addWidget(add_btn)
        tabs.addTab(builder, "Builder")

        monitor = QFrame()
        ml = QVBoxLayout(monitor)
        ml.addWidget(QLabel("Traffic Monitor"))
        ml.addWidget(QLabel("Blocked today: 12,847 packets"))
        ml.addWidget(QLabel("Active connections: 47"))
        m_table = QTableWidget(4, 3)
        m_table.setHorizontalHeaderLabels(["Source", "Dest", "Action"])
        for i, (src, dst, action) in enumerate([
            ("185.220.101.23", "10.0.0.1:443", "BLOCKED"),
            ("10.0.0.5", "8.8.8.8:53", "ALLOWED"),
            ("45.33.32.156", "10.0.0.1:22", "BLOCKED"),
            ("10.0.0.10", "10.0.0.1:8080", "ALLOWED"),
        ]):
            m_table.setItem(i, 0, QTableWidgetItem(src))
            m_table.setItem(i, 1, QTableWidgetItem(dst))
            m_table.setItem(i, 2, QTableWidgetItem(action))
        ml.addWidget(m_table)
        tabs.addTab(monitor, "Monitor")

        layout.addWidget(tabs)
        return w
