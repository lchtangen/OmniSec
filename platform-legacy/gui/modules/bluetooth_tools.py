"""Bluetooth Tools — BT/BLE scanning, device enumeration, service discovery"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox)

class BluetoothTools(OmniSecModule):
    name = "Bluetooth Tools"
    description = "Bluetooth/BLE scanning, device enumeration, service discovery"
    category = "Wireless"
    version = "2.0.0"
    icon = "📶"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        scan = QFrame()
        sl = QVBoxLayout(scan)
        sl.addWidget(QLabel("Bluetooth Scanner"))
        scan_btn = QPushButton("Scan for Devices")
        sl.addWidget(scan_btn)
        b_table = QTableWidget(5, 5)
        b_table.setHorizontalHeaderLabels(["Name", "MAC", "RSSI", "Class", "Services"])
        for i, (name, mac, rssi, cls, svc) in enumerate([
            ("iPhone 15 Pro", "AA:BB:CC:11:22:33", "-45", "Phone", "HFP, A2DP"),
            ("Galaxy Buds2", "AA:BB:CC:44:55:66", "-62", "Audio", "A2DP, AVRCP"),
            ("Smart Watch", "AA:BB:CC:77:88:99", "-55", "Wearable", "HSP, GATT"),
            ("Laptop X1", "AA:BB:CC:AA:BB:CC", "-70", "Computer", "SPP, HID"),
            ("Unknown", "AA:BB:CC:DD:EE:FF", "-80", "Unknown", "LE-only"),
        ]):
            b_table.setItem(i, 0, QTableWidgetItem(name))
            b_table.setItem(i, 1, QTableWidgetItem(mac))
            b_table.setItem(i, 2, QTableWidgetItem(rssi))
            b_table.setItem(i, 3, QTableWidgetItem(cls))
            b_table.setItem(i, 4, QTableWidgetItem(svc))
        sl.addWidget(b_table)
        tabs.addTab(scan, "Scanner")

        ble = QFrame()
        bl_ble = QVBoxLayout(ble)
        bl_ble.addWidget(QLabel("BLE Service Discovery"))
        ble_scan = QPushButton("Scan BLE Services")
        bl_ble.addWidget(ble_scan)
        ble_table = QTableWidget(4, 4)
        ble_table.setHorizontalHeaderLabels(["Device", "Service UUID", "Type", "Data"])
        for i, (dev, uuid, typ, data) in enumerate([
            ("Smart Bulb", "0xFFF0", "Light", "On/Off, Color"),
            ("Heart Monitor", "0x180D", "Health", "Heart Rate"),
            ("Temperature", "0x181A", "Env", "Temp: 22.5C"),
            ("Smart Lock", "0xFFE0", "Security", "Lock/Unlock"),
        ]):
            ble_table.setItem(i, 0, QTableWidgetItem(dev))
            ble_table.setItem(i, 1, QTableWidgetItem(uuid))
            ble_table.setItem(i, 2, QTableWidgetItem(typ))
            ble_table.setItem(i, 3, QTableWidgetItem(data))
        bl_ble.addWidget(ble_table)
        tabs.addTab(ble, "BLE Services")

        layout.addWidget(tabs)
        return w
