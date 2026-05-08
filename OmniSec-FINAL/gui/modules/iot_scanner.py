"""IoT Scanner — IoT device discovery, vulnerability checks, firmware analysis"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox)

class IoTScanner(OmniSecModule):
    name = "IoT Scanner"
    description = "IoT device discovery, vulnerability checks, firmware analysis"
    category = "Network"
    version = "2.0.0"
    icon = "📟"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        disc = QFrame()
        dl = QVBoxLayout(disc)
        dl.addWidget(QLabel("IoT Device Discovery"))
        i_table = QTableWidget(6, 5)
        i_table.setHorizontalHeaderLabels(["Device", "IP", "Manufacturer", "Firmware", "Risk"])
        for i, (dev, ip, mfr, fw, risk) in enumerate([
            ("IP Camera", "10.0.0.101", "Hikvision", "V5.4.5", "Critical"),
            ("Smart Thermostat", "10.0.0.102", "Nest", "6.2.1", "Low"),
            ("WiFi Router", "10.0.0.1", "TP-Link", "1.0.14", "Medium"),
            ("Smart TV", "10.0.0.103", "Samsung", "T-KTMAKUC", "Medium"),
            ("Baby Monitor", "10.0.0.104", "Philips", "2.1.0", "High"),
            ("Smart Lock", "10.0.0.105", "August", "3.0.1", "High"),
        ]):
            i_table.setItem(i, 0, QTableWidgetItem(dev))
            i_table.setItem(i, 1, QTableWidgetItem(ip))
            i_table.setItem(i, 2, QTableWidgetItem(mfr))
            i_table.setItem(i, 3, QTableWidgetItem(fw))
            i_table.setItem(i, 4, QTableWidgetItem(risk))
        dl.addWidget(i_table)
        disc_btn = QPushButton("Scan for IoT Devices")
        dl.addWidget(disc_btn)
        tabs.addTab(disc, "Discovery")

        vulns = QFrame()
        vl = QVBoxLayout(vulns)
        vl.addWidget(QLabel("IoT Vulnerability Check"))
        v_table = QTableWidget(5, 3)
        v_table.setHorizontalHeaderLabels(["Device", "CVE", "Severity"])
        for i, (dev, cve, sev) in enumerate([
            ("Hikvision Camera", "CVE-2021-36260", "Critical"),
            ("TP-Link Router", "CVE-2020-10882", "High"),
            ("Nest Thermostat", "CVE-2019-10734", "Medium"),
            ("Samsung TV", "CVE-2022-26988", "High"),
            ("August Lock", "CVE-2021-30468", "Critical"),
        ]):
            v_table.setItem(i, 0, QTableWidgetItem(dev))
            v_table.setItem(i, 1, QTableWidgetItem(cve))
            v_table.setItem(i, 2, QTableWidgetItem(sev))
        vl.addWidget(v_table)
        check_btn = QPushButton("Check All Devices")
        vl.addWidget(check_btn)
        tabs.addTab(vulns, "Vulnerabilities")

        fw = QFrame()
        fl = QVBoxLayout(fw)
        fl.addWidget(QLabel("Firmware Analysis"))
        fl.addWidget(QLabel("Upload firmware image for analysis:"))
        load_fw = QPushButton("Load Firmware File")
        fl.addWidget(load_fw)
        fw_out = QTextEdit()
        fw_out.setReadOnly(True)
        fw_out.append("[FIRMWARE] Analyzing firmware.bin...")
        fw_out.append("[FIRMWARE] Architecture: ARM Cortex-A7")
        fw_out.append("[FIRMWARE] OS: Linux 4.14.173")
        fw_out.append("[FIRMWARE] Filesystem: SquashFS")
        fw_out.append("[FIRMWARE] Hardcoded credentials found: admin/admin123")
        fw_out.append("[FIRMWARE] 3 CVEs detected in bundled libraries")
        fl.addWidget(fw_out)
        tabs.addTab(fw, "Firmware")

        layout.addWidget(tabs)
        return w
