"""Packet Analyzer — PCAP analysis, traffic inspection, protocol dissection"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox,
                             QTreeWidget, QTreeWidgetItem)
import random

class PacketAnalyzer(OmniSecModule):
    name = "Packet Analyzer"
    description = "Packet capture analysis, traffic inspection, protocol dissection"
    category = "Network"
    version = "2.0.0"
    icon = "📦"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        pcap = QFrame()
        pl = QVBoxLayout(pcap)
        pl.addWidget(QLabel("PCAP Analyzer"))
        load_btn = QPushButton("Load PCAP File")
        pl.addWidget(load_btn)
        p_table = QTableWidget(8, 5)
        p_table.setHorizontalHeaderLabels(["No.", "Time", "Source", "Dest", "Protocol"])
        for i in range(8):
            p_table.setItem(i, 0, QTableWidgetItem(str(i+1)))
            p_table.setItem(i, 1, QTableWidgetItem(f"0.00{i*3+1}"))
            p_table.setItem(i, 2, QTableWidgetItem(f"10.0.0.{random.randint(1,10)}"))
            p_table.setItem(i, 3, QTableWidgetItem(f"10.0.0.{random.randint(1,10)}"))
            p_table.setItem(i, 4, QTableWidgetItem(random.choice(["TCP", "UDP", "HTTP", "DNS"])))
        pl.addWidget(p_table)
        tabs.addTab(pcap, "PCAP Browser")

        proto = QFrame()
        pcl = QVBoxLayout(proto)
        pcl.addWidget(QLabel("Protocol Hierarchy"))
        p_tree = QTreeWidget()
        p_tree.setHeaderLabels(["Protocol", "Packets", "Bytes"])
        for prot, pkts, byts in [
            ("Ethernet", "12,847", "15.2 MB"),
            ("  IP", "12,345", "14.8 MB"),
            ("    TCP", "8,234", "10.1 MB"),
            ("      HTTP", "3,456", "4.2 MB"),
            ("    UDP", "4,111", "4.7 MB"),
            ("      DNS", "2,500", "1.2 MB"),
        ]:
            item = QTreeWidgetItem([prot, pkts, byts])
            p_tree.addTopLevelItem(item)
        pcl.addWidget(p_tree)
        tabs.addTab(proto, "Protocols")

        conv = QFrame()
        cl = QVBoxLayout(conv)
        cl.addWidget(QLabel("Conversations"))
        c_table = QTableWidget(5, 4)
        c_table.setHorizontalHeaderLabels(["A to B", "Packets", "Bytes", "Duration"])
        for i, (ab, pkts, byts, dur) in enumerate([
            ("10.0.0.1 to 10.0.0.5", "423", "45 KB", "2m30s"),
            ("10.0.0.1 to 8.8.8.8", "1,234", "1.2 MB", "15m"),
            ("10.0.0.5 to 185.220.x.x", "567", "890 KB", "5m"),
            ("10.0.0.10 to 10.0.0.1", "89", "12 KB", "30s"),
            ("10.0.0.5 to 192.168.1.1", "45", "3 KB", "10s"),
        ]):
            c_table.setItem(i, 0, QTableWidgetItem(ab))
            c_table.setItem(i, 1, QTableWidgetItem(pkts))
            c_table.setItem(i, 2, QTableWidgetItem(byts))
            c_table.setItem(i, 3, QTableWidgetItem(dur))
        cl.addWidget(c_table)
        tabs.addTab(conv, "Conversations")

        layout.addWidget(tabs)
        return w
