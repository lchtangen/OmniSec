"""Social Engineering Toolkit — Phishing, credential harvesting, awareness"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QComboBox, QCheckBox, QSpinBox, QGroupBox)

class SocialEngineer(OmniSecModule):
    name = "Social Engineer"
    description = "Phishing campaigns, credential harvesting, awareness training"
    category = "Social"
    version = "2.0.0"
    icon = "🎭"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Phishing builder
        phish = QFrame()
        pl = QVBoxLayout(phish)
        pl.addWidget(QLabel("Phishing Campaign Builder"))
        template = QComboBox()
        template.addItems(["Office 365 Login", "Google Sign-In", "Dropbox Notification",
                          "LinkedIn Alert", "Amazon Security Alert", "Custom Template"])
        pl.addWidget(template)
        pl.addWidget(QLabel("Target List:"))
        targets = QTextEdit()
        targets.setPlaceholderText("Paste targets (one per line or CSV)...")
        targets.setMaximumHeight(60)
        pl.addWidget(targets)
        landing = QLineEdit("https://your-server.com/login")
        pl.addWidget(landing)
        opts = QGroupBox("Options")
        ol = QVBoxLayout(opts)
        ol.addWidget(QCheckBox("Track opens"))
        ol.addWidget(QCheckBox("Track clicks"))
        ol.addWidget(QCheckBox("Capture credentials"))
        ol.addWidget(QCheckBox("Auto-redirect after capture"))
        ol.addWidget(QCheckBox("2FA bypass page"))
        pl.addWidget(opts)
        launch = QPushButton("Launch Campaign")
        launch.setObjectName("danger")
        pl.addWidget(launch)
        tabs.addTab(phish, "Phishing")

        # Tracker
        track = QFrame()
        tl = QVBoxLayout(track)
        tl.addWidget(QLabel("Campaign Tracker"))
        t_table = QTableWidget(4, 5)
        t_table.setHorizontalHeaderLabels(["Campaign", "Sent", "Opened", "Clicked", "Credentials"])
        for i, (name, sent, opened, clicked, creds) in enumerate([
            ("O365 Login Test", "100", "47", "23", "18"),
            ("Google Alert", "50", "28", "15", "12"),
            ("LinkedIn Scrape", "200", "89", "45", "34"),
            ("Amazon Notice", "75", "42", "21", "16"),
        ]):
            t_table.setItem(i, 0, QTableWidgetItem(name))
            t_table.setItem(i, 1, QTableWidgetItem(sent))
            t_table.setItem(i, 2, QTableWidgetItem(opened))
            t_table.setItem(i, 3, QTableWidgetItem(clicked))
            t_table.setItem(i, 4, QTableWidgetItem(creds))
        tl.addWidget(t_table)
        tabs.addTab(track, "Tracker")

        # Awareness
        aware = QFrame()
        al = QVBoxLayout(aware)
        al.addWidget(QLabel("Security Awareness Training"))
        modules = QListWidget()
        for mod in ["Phishing Recognition", "Password Hygiene", "Social Engineering Basics",
                    "Physical Security", "Tailgating Prevention", "Clean Desk Policy",
                    "USB Drop Attacks", "Vishing Detection"]:
            modules.addItem(mod)
        al.addWidget(modules)
        start_train = QPushButton("Start Training Module")
        al.addWidget(start_train)
        tabs.addTab(aware, "Training")

        layout.addWidget(tabs)
        return w
