"""Web Application Scanner — Vulnerability detection, crawling, fuzzing"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QProgressBar, QComboBox)

class WebScanner(OmniSecModule):
    name = "Web Scanner"
    description = "Web application vulnerability scanning, crawling, fuzzing"
    category = "Web"
    version = "2.0.0"
    icon = "🌐"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Scanner
        scan = QFrame()
        sl = QVBoxLayout(scan)
        url_row = QHBoxLayout()
        url_row.addWidget(QLabel("Target URL:"))
        url_input = QLineEdit("https://target-site.com")
        url_row.addWidget(url_input)
        scan_btn = QPushButton("Scan")
        scan_btn.setObjectName("danger")
        url_row.addWidget(scan_btn)
        sl.addLayout(url_row)
        prog = QProgressBar()
        sl.addWidget(prog)
        results = QTableWidget(5, 3)
        results.setHorizontalHeaderLabels(["Vulnerability", "Severity", "URL"])
        for i, (vuln, sev, url) in enumerate([
            ("SQL Injection", "Critical", "/products?id=1"),
            ("XSS Reflected", "High", "/search?q="),
            ("CSRF Token Missing", "Medium", "/account/update"),
            ("Directory Listing", "Low", "/backup/"),
            ("CORS Misconfiguration", "Medium", "/api/"),
        ]):
            results.setItem(i, 0, QTableWidgetItem(vuln))
            results.setItem(i, 1, QTableWidgetItem(sev))
            results.setItem(i, 2, QTableWidgetItem(url))
        sl.addWidget(results)
        tabs.addTab(scan, "Scanner")

        # Crawler
        crawl = QFrame()
        cl = QVBoxLayout(crawl)
        cl.addWidget(QLabel("Crawled URLs"))
        c_list = QListWidget()
        for url in ["/", "/login", "/register", "/products", "/products/1",
                    "/products/2", "/cart", "/checkout", "/account", "/api/v1/",
                    "/api/v1/users", "/api/v1/products", "/admin", "/backup"]:
            c_list.addItem(url)
        cl.addWidget(c_list)
        tabs.addTab(crawl, "Crawler")

        # Fuzzer
        fuzz = QFrame()
        fl = QVBoxLayout(fuzz)
        fl.addWidget(QLabel("Fuzzer Engine"))
        fuzz_target = QLineEdit("/api/v1/users?id=FUZZ")
        fl.addWidget(fuzz_target)
        wordlist = QComboBox()
        wordlist.addItems(["SQLi Payloads", "XSS Payloads", "Path Traversal",
                          "Common Paths", "API Endpoints"])
        fl.addWidget(wordlist)
        start_fuzz = QPushButton("Start Fuzzing")
        fuzz_out = QTextEdit()
        fuzz_out.setReadOnly(True)
        fuzz_out.append("Fuzzing /api/v1/users?id=FUZZ")
        fuzz_out.append("200 - admin' OR '1'='1")
        fuzz_out.append("500 - ${7*7}")
        fuzz_out.append("404 - ../../etc/passwd")
        fl.addWidget(fuzz_out)
        fl.addWidget(start_fuzz)
        tabs.addTab(fuzz, "Fuzzer")

        layout.addWidget(tabs)
        return w
