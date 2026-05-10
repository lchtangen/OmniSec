"""Password Auditor — Hash cracking, policy audit, breach checking"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QComboBox, QFrame,
                             QTabWidget, QProgressBar, QTableWidget, QTableWidgetItem)

class PasswordAuditor(OmniSecModule):
    name = "Password Auditor"
    description = "Password cracking, hash analysis, policy auditing, breach lookup"
    category = "Crypto"
    version = "2.0.0"
    icon = "🔑"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Hash cracker
        crack = QFrame()
        cl = QVBoxLayout(crack)
        cl.addWidget(QLabel("Hash Cracker"))
        hash_input = QTextEdit()
        hash_input.setPlaceholderText("Paste hashes here (one per line)...")
        hash_input.setMaximumHeight(80)
        cl.addWidget(hash_input)
        mode = QComboBox()
        mode.addItems(["Auto-detect", "MD5", "SHA1", "SHA256", "bcrypt",
                      "NTLM", "LM", "MySQL", "SHA512"])
        cl.addWidget(mode)
        wordlist = QComboBox()
        wordlist.addItems(["rockyou.txt", "common-passwords.txt", "SecLists",
                          "Custom wordlist"])
        cl.addWidget(wordlist)
        crack_btn = QPushButton("Start Cracking")
        crack_btn.setObjectName("danger")
        cl.addWidget(crack_btn)
        prog = QProgressBar()
        cl.addWidget(prog)
        results = QTextEdit()
        results.setReadOnly(True)
        results.append("[CRACK] Loaded 14,000,000 passwords")
        results.append("[CRACK] Testing hash: $2y$10$...")
        results.append("[FOUND] password123 (0.2s)")
        results.append("[FOUND] admin2024 (1.4s)")
        results.append("[FOUND] letmein! (3.7s)")
        cl.addWidget(results)
        tabs.addTab(crack, "Hash Cracker")

        # Policy audit
        policy = QFrame()
        pl = QVBoxLayout(policy)
        pl.addWidget(QLabel("Password Policy Audit"))
        pa_table = QTableWidget(5, 3)
        pa_table.setHorizontalHeaderLabels(["User", "Password Strength", "Action"])
        for i, (user, strength, action) in enumerate([
            ("admin", "Weak", "Change Required"),
            ("jsmith", "Medium", "Recommended"),
            ("alice", "Strong", "OK"),
            ("bob", "Weak", "Change Required"),
            ("root", "Critical", "Immediate Change"),
        ]):
            pa_table.setItem(i, 0, QTableWidgetItem(user))
            pa_table.setItem(i, 1, QTableWidgetItem(strength))
            pa_table.setItem(i, 2, QTableWidgetItem(action))
        pl.addWidget(pa_table)
        run_audit = QPushButton("Run Full Audit")
        pl.addWidget(run_audit)
        tabs.addTab(policy, "Policy Audit")

        # Breach check
        breach = QFrame()
        bl = QVBoxLayout(breach)
        bl.addWidget(QLabel("Breach Check (Local Database)"))
        email_input = QTextEdit()
        email_input.setPlaceholderText("Enter emails to check...")
        email_input.setMaximumHeight(60)
        bl.addWidget(email_input)
        check_btn = QPushButton("Check Breaches")
        bl.addWidget(check_btn)
        breach_out = QTextEdit()
        breach_out.setReadOnly(True)
        breach_out.append("[BREACH] Checking against local database...")
        breach_out.append("  admin@company.com: Found in 3 breaches")
        breach_out.append("  john@company.com: Found in 1 breach")
        breach_out.append("  sarah@company.com: Clean")
        bl.addWidget(breach_out)
        tabs.addTab(breach, "Breach Check")

        layout.addWidget(tabs)
        return w
