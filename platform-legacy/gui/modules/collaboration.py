"""Collaboration — Team chat, shared sessions, cooperative operations"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox)

class CollaborationModule(OmniSecModule):
    name = "Collaboration"
    description = "Team chat, shared sessions, cooperative operations, mesh communication"
    category = "Core"
    version = "2.0.0"
    icon = "👥"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        chat = QFrame()
        cl = QVBoxLayout(chat)
        cl.addWidget(QLabel("Mesh Chat (Encrypted)"))
        chat_display = QTextEdit()
        chat_display.setReadOnly(True)
        chat_display.append("[10:23:45] <ghost> Starting scan on target")
        chat_display.append("[10:24:12] <ne0n> Port 445 open on 10.0.0.5")
        chat_display.append("[10:24:30] <ghost> Exploiting MS17-010...")
        chat_display.append("[10:25:01] <system> ghost gained SYSTEM on 10.0.0.5")
        cl.addWidget(chat_display)
        chat_input = QHBoxLayout()
        msg_input = QLineEdit()
        msg_input.setPlaceholderText("Type a message...")
        chat_input.addWidget(msg_input)
        send = QPushButton("Send")
        chat_input.addWidget(send)
        cl.addLayout(chat_input)
        tabs.addTab(chat, "Team Chat")

        sessions_t = QFrame()
        sl = QVBoxLayout(sessions_t)
        sl.addWidget(QLabel("Shared Sessions"))
        s_table = QTableWidget(4, 4)
        s_table.setHorizontalHeaderLabels(["Operator", "Target", "Tool", "Status"])
        for i, (op, target, tool, status) in enumerate([
            ("ghost", "10.0.0.5", "Metasploit", "Active"),
            ("ne0n", "10.0.0.10", "Nmap", "Scanning"),
            ("cyph3r", "web.target.com", "SQLMap", "Idle"),
            ("zer0day", "mail.target.com", "Burp Suite", "Active"),
        ]):
            s_table.setItem(i, 0, QTableWidgetItem(op))
            s_table.setItem(i, 1, QTableWidgetItem(target))
            s_table.setItem(i, 2, QTableWidgetItem(tool))
            s_table.setItem(i, 3, QTableWidgetItem(status))
        sl.addWidget(s_table)
        sl.addWidget(QLabel("Team Members Online: 4"))
        tabs.addTab(sessions_t, "Sessions")

        whiteboard = QFrame()
        wl = QVBoxLayout(whiteboard)
        wl.addWidget(QLabel("Collaborative Whiteboard"))
        wl.addWidget(QLabel("Network map, notes, shared findings"))
        wboard = QTextEdit()
        wboard.setPlaceholderText("Share notes, diagrams, or findings with your team...")
        wl.addWidget(wboard)
        tabs.addTab(whiteboard, "Whiteboard")

        layout.addWidget(tabs)
        return w
