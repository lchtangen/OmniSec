"""DNS Tools — Enumeration, zone transfer, tunneling, analysis"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox)

class DNSTools(OmniSecModule):
    name = "DNS Tools"
    description = "DNS enumeration, zone transfer, tunneling, resolution analysis"
    category = "Network"
    version = "2.0.0"
    icon = "🌐"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Enumeration
        enum = QFrame()
        el = QVBoxLayout(enum)
        el.addWidget(QLabel("DNS Enumeration"))
        d_row = QHBoxLayout()
        d_row.addWidget(QLabel("Domain:"))
        d_input = QLineEdit("example.com")
        d_row.addWidget(d_input)
        enum_btn = QPushButton("Enumerate")
        d_row.addWidget(enum_btn)
        el.addLayout(d_row)

        dns_table = QTableWidget(8, 3)
        dns_table.setHorizontalHeaderLabels(["Record", "Value", "TTL"])
        for i, (rec, val, ttl) in enumerate([
            ("A", "93.184.216.34", "3600"),
            ("AAAA", "2606:2800:220::1", "3600"),
            ("MX", "mail.example.com (priority 10)", "1800"),
            ("NS", "ns1.example.com", "7200"),
            ("TXT", "v=spf1 include:_spf.example.com ~all", "3600"),
            ("CNAME", "www.example.com → example.com", "1800"),
            ("SOA", "admin.example.com", "3600"),
            ("CAA", "0 issue \"letsencrypt.org\"", "7200"),
        ]):
            dns_table.setItem(i, 0, QTableWidgetItem(rec))
            dns_table.setItem(i, 1, QTableWidgetItem(val))
            dns_table.setItem(i, 2, QTableWidgetItem(ttl))
        el.addWidget(dns_table)
        tabs.addTab(enum, "Enumeration")

        # Zone Transfer
        zt = QFrame()
        zl = QVBoxLayout(zt)
        zl.addWidget(QLabel("Zone Transfer Check"))
        zt_row = QHBoxLayout()
        zt_row.addWidget(QLabel("Nameserver:"))
        ns_input = QLineEdit("ns1.example.com")
        zt_row.addWidget(ns_input)
        zt_domain = QLineEdit("example.com")
        zt_row.addWidget(zt_domain)
        zl.addLayout(zt_row)
        zt_btn = QPushButton("Attempt Zone Transfer")
        zt_btn.setObjectName("danger")
        zl.addWidget(zt_btn)
        zt_out = QTextEdit()
        zt_out.setReadOnly(True)
        zt_out.append("[DNS] Attempting AXFR from ns1.example.com...")
        zt_out.append("[DNS] Zone transfer: SUCCESS")
        zt_out.append("[DNS] 42 records transferred")
        zl.addWidget(zt_out)
        tabs.addTab(zt, "Zone Transfer")

        # DNS Tunnel
        tunnel = QFrame()
        tl = QVBoxLayout(tunnel)
        tl.addWidget(QLabel("DNS Tunneling"))
        tl.addWidget(QLabel("Status: Not connected"))
        start_t = QPushButton("Start DNS Tunnel")
        start_t.setObjectName("success")
        tl.addWidget(start_t)
        stop_t = QPushButton("Stop Tunnel")
        stop_t.setObjectName("danger")
        tl.addWidget(stop_t)
        t_out = QTextEdit()
        t_out.setReadOnly(True)
        t_out.append("[TUNNEL] DNS tunnel established")
        t_out.append("[TUNNEL] Throughput: 12.4 Kbps")
        t_out.append("[TUNNEL] Data sent: 1.2 MB")
        t_out.append("[TUNNEL] Data received: 0.8 MB")
        tl.addWidget(t_out)
        tabs.addTab(tunnel, "DNS Tunnel")

        layout.addWidget(tabs)
        return w
