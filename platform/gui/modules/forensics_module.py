"""Forensics Module — File analysis, memory dump analysis, timeline"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QTreeWidget, QTreeWidgetItem)

class ForensicsModule(OmniSecModule):
    name = "Forensics Module"
    description = "File analysis, memory forensics, timeline reconstruction"
    category = "Forensics"
    version = "2.0.0"
    icon = "🔍"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # File analysis
        files = QFrame()
        fl = QVBoxLayout(files)
        fl.addWidget(QLabel("File Analysis"))
        fl.addWidget(QLabel("Drag & drop files or select directory:"))
        scan_f = QPushButton("Scan Directory")
        fl.addWidget(scan_f)
        f_tree = QTreeWidget()
        f_tree.setHeaderLabels(["File", "Size", "Type", "Entropy", "Suspicious"])
        for name, size, ftype, ent, susp in [
            ("document.pdf", "1.2 MB", "PDF", "4.5", "No"),
            ("image.jpg", "3.4 MB", "JPEG", "7.8", "Yes (stego)"),
            ("script.js", "45 KB", "JavaScript", "5.2", "No"),
            ("dump.bin", "500 MB", "Binary", "7.9", "Yes (encrypted)"),
            ("config.xml", "12 KB", "XML", "3.1", "No"),
        ]:
            item = QTreeWidgetItem([name, size, ftype, ent, susp])
            if susp == "Yes":
                item.setForeground(4, __import__('PyQt6.QtGui').QColor("#FF0000"))
            f_tree.addTopLevelItem(item)
        fl.addWidget(f_tree)
        tabs.addTab(files, "File Analysis")

        # Memory analysis
        mem = QFrame()
        ml = QVBoxLayout(mem)
        ml.addWidget(QLabel("Memory Forensics"))
        ml.addWidget(QLabel("Load memory dump (raw, crash, hibernation):"))
        load_mem = QPushButton("Load Memory Dump")
        ml.addWidget(load_mem)
        m_table = QTableWidget(6, 3)
        m_table.setHorizontalHeaderLabels(["Process", "PID", "Suspicious"])
        for i, (proc, pid, susp) in enumerate([
            ("svchost.exe", "1024", "No"),
            ("lsass.exe", "672", "Yes - credential dump"),
            ("explorer.exe", "3456", "No"),
            ("cmd.exe", "7890", "Yes - unknown parent"),
            ("powershell.exe", "1234", "Yes - encoded command"),
            ("notepad.exe", "5678", "No"),
        ]):
            m_table.setItem(i, 0, QTableWidgetItem(proc))
            m_table.setItem(i, 1, QTableWidgetItem(pid))
            m_table.setItem(i, 2, QTableWidgetItem(susp))
        ml.addWidget(m_table)
        tabs.addTab(mem, "Memory Analysis")

        # Timeline
        tl = QFrame()
        tll = QVBoxLayout(tl)
        tll.addWidget(QLabel("Event Timeline"))
        t_table = QTableWidget(8, 4)
        t_table.setHorizontalHeaderLabels(["Timestamp", "Event", "Source", "Severity"])
        import datetime
        now = datetime.datetime.now()
        for i in range(8):
            ts = now - datetime.timedelta(hours=i*3)
            t_table.setItem(i, 0, QTableWidgetItem(ts.strftime("%Y-%m-%d %H:%M")))
            t_table.setItem(i, 1, QTableWidgetItem(random.choice([
                "File created", "Process started", "Network connection",
                "Registry modified", "User login", "Service installed"])))
            t_table.setItem(i, 2, QTableWidgetItem(random.choice([
                "sysmon", "windows-event", "auditd", "osquery"])))
            t_table.setItem(i, 3, QTableWidgetItem(random.choice([
                "Low", "Medium", "High", "Critical"])))
        tll.addWidget(t_table)
        tabs.addTab(tl, "Timeline")

        layout.addWidget(tabs)
        return w
import random
