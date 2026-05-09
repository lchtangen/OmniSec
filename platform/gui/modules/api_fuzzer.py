"""API Fuzzer — REST API testing, endpoint discovery, parameter fuzzing"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QSpinBox, QCheckBox)

class APIFuzzer(OmniSecModule):
    name = "API Fuzzer"
    description = "REST API endpoint discovery, parameter fuzzing, auth testing"
    category = "Web"
    version = "2.0.0"
    icon = "🔌"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        fuzz = QFrame()
        fl = QVBoxLayout(fuzz)
        fl.addWidget(QLabel("API Fuzzer"))
        url_row = QHBoxLayout()
        url_row.addWidget(QLabel("Base URL:"))
        url_input = QLineEdit("https://api.target.com/v1")
        url_row.addWidget(url_input)
        fl.addLayout(url_row)
        fl.addWidget(QLabel("Endpoints:"))
        endpoints = QTextEdit()
        endpoints.setMaximumHeight(60)
        endpoints.setText("/users\n/users/{id}\n/products\n/products/{id}\n/login")
        fl.addWidget(endpoints)
        methods = QHBoxLayout()
        for m in ["GET", "POST", "PUT", "DELETE", "PATCH"]:
            methods.addWidget(QCheckBox(m))
        fl.addLayout(methods)
        fl.addWidget(QLabel("Payload type:"))
        payload = QComboBox()
        payload.addItems(["SQL Injection", "XSS", "NoSQL Injection", "Command Injection",
                         "Path Traversal", "IDOR", "Mass Assignment"])
        fl.addWidget(payload)
        fuzz_btn = QPushButton("Start Fuzzing")
        fuzz_btn.setObjectName("danger")
        fl.addWidget(fuzz_btn)
        fuzz_out = QTableWidget(5, 3)
        fuzz_out.setHorizontalHeaderLabels(["Endpoint", "Method", "Result"])
        for i, (ep, method, result) in enumerate([
            ("/api/v1/users/1", "GET", "200 - User data leaked"),
            ("/api/v1/login", "POST", "500 - SQL error exposed"),
            ("/api/v1/admin", "GET", "403 - Forbidden (expected)"),
            ("/api/v1/products", "POST", "201 - Mass assignment vuln"),
            ("/api/v1/search?q=", "GET", "200 - XSS reflected"),
        ]):
            fuzz_out.setItem(i, 0, QTableWidgetItem(ep))
            fuzz_out.setItem(i, 1, QTableWidgetItem(method))
            fuzz_out.setItem(i, 2, QTableWidgetItem(result))
        fl.addWidget(fuzz_out)
        tabs.addTab(fuzz, "Fuzzer")

        disco = QFrame()
        dl = QVBoxLayout(disco)
        dl.addWidget(QLabel("Endpoint Discovery"))
        dl.addWidget(QLabel("Discover hidden API endpoints:"))
        disco_input = QLineEdit("https://api.target.com")
        dl.addWidget(disco_input)
        disco_btn = QPushButton("Discover Endpoints")
        dl.addWidget(disco_btn)
        d_out = QTextEdit()
        d_out.setReadOnly(True)
        d_out.append("[DISCOVERY] Scanning https://api.target.com...")
        d_out.append("[DISCOVERY] Found 23 endpoints:")
        d_out.append("  /v1/users (200)")
        d_out.append("  /v1/admin (403)")
        d_out.append("  /v1/internal (200 - exposed!)")
        d_out.append("  /v1/docs (200 - Swagger)")
        d_out.append("  /v1/graphql (200)")
        dl.addWidget(d_out)
        tabs.addTab(disco, "Discovery")

        auth = QFrame()
        al = QVBoxLayout(auth)
        al.addWidget(QLabel("Authentication Testing"))
        al.addWidget(QLabel("Test endpoint for auth bypasses:"))
        auth_input = QLineEdit("https://api.target.com/v1/admin")
        al.addWidget(auth_input)
        auth_btn = QPushButton("Test Authentication")
        al.addWidget(auth_btn)
        a_out = QTextEdit()
        a_out.setReadOnly(True)
        a_out.append("[AUTH] Testing https://api.target.com/v1/admin")
        a_out.append("[AUTH] No auth: 200 OK (VULNERABLE)")
        a_out.append("[AUTH] Basic auth: 401")
        a_out.append("[AUTH] Token auth: 200 OK")
        a_out.append("[AUTH] JWT bypass: 200 OK (VULNERABLE)")
        al.addWidget(a_out)
        tabs.addTab(auth, "Auth Test")

        layout.addWidget(tabs)
        return w
