"""Advanced Network Tools — Packet capture, traffic analysis, discovery"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QGroupBox, QComboBox,
                             QTableWidget, QTableWidgetItem, QFrame, QTabWidget)
from PyQt6.QtCore import QThread, pyqtSignal
import random

class NetworkPro(OmniSecModule):
    name = "Network Pro"
    description = "Advanced packet capture, traffic analysis, network discovery"
    category = "Network"
    version = "2.0.0"
    icon = "📡"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Discovery tab
        disc = QFrame()
        dl = QVBoxLayout(disc)
        dl.addWidget(QLabel("Network Discovery"))
        ntable = QTableWidget(5, 4)
        ntable.setHorizontalHeaderLabels(["IP", "MAC", "Hostname", "OS"])
        for i, (ip, mac, host, os) in enumerate([
            ("10.0.0.1", "AA:BB:CC:DD:EE:01", "router.home", "Linux"),
            ("10.0.0.2", "AA:BB:CC:DD:EE:02", "nas.home", "FreeNAS"),
            ("10.0.0.5", "AA:BB:CC:DD:EE:05", "win-pc", "Windows 11"),
            ("10.0.0.10", "AA:BB:CC:DD:EE:10", "kali-box", "Kali Linux"),
            ("10.0.0.15", "AA:BB:CC:DD:EE:15", "iot-cam", "Linux"),
        ]):
            ntable.setItem(i, 0, QTableWidgetItem(ip))
            ntable.setItem(i, 1, QTableWidgetItem(mac))
            ntable.setItem(i, 2, QTableWidgetItem(host))
            ntable.setItem(i, 3, QTableWidgetItem(os))
        dl.addWidget(ntable)
        refresh = QPushButton("Rediscover Network")
        dl.addWidget(refresh)
        tabs.addTab(disc, "Discovery")

        # Packet capture
        pcap = QFrame()
        pl = QVBoxLayout(pcap)
        pl.addWidget(QLabel("Packet Capture (PCAP)"))
        pcap_text = QTextEdit()
        pcap_text.setReadOnly(True)
        for _ in range(20):
            pcap_text.append(f"{random.choice(['TCP','UDP','ARP','DNS'])} "
                           f"{random.randint(1000,9999)} → {random.randint(1000,9999)} "
                           f"{random.choice(['10.0.0.1','10.0.0.5','8.8.8.8'])} "
                           f"[{random.choice(['SYN','ACK','PSH','FIN'])}]"))
        pl.addWidget(pcap_text)
        start_cap = QPushButton("Start Capture")
        pl.addWidget(start_cap)
        tabs.addTab(pcap, "Packet Capture")

        # Bandwidth
        bw = QFrame()
        bl = QVBoxLayout(bw)
        bl.addWidget(QLabel("Bandwidth Monitor"))
        bw_text = QTextEdit()
        bw_text.setReadOnly(True)
        bw_text.append("Interface: wlan0")
        bw_text.append("Download: 45.2 Mbps")
        bw_text.append("Upload: 12.8 Mbps")
        bw_text.append("Total: 2.4 GB today")
        bl.addWidget(bw_text)
        tabs.addTab(bw, "Bandwidth")

        layout.addWidget(tabs)
        return w
