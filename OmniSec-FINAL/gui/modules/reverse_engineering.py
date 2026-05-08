"""Reverse Engineering — Binary analysis, disassembly, decompilation helpers"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QComboBox, QSplitter)

class ReverseEngineering(OmniSecModule):
    name = "Reverse Engineering"
    description = "Binary analysis, disassembly, decompilation, string extraction"
    category = "Exploitation"
    version = "2.0.0"
    icon = "🔧"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        binary_t = QFrame()
        bl = QVBoxLayout(binary_t)
        bl.addWidget(QLabel("Binary Analyzer"))
        bin_row = QHBoxLayout()
        bin_row.addWidget(QLabel("File:"))
        bin_input = QLineEdit("/path/to/binary")
        bin_row.addWidget(bin_input)
        load_b = QPushButton("Analyze")
        bin_row.addWidget(load_b)
        bl.addLayout(bin_row)
        b_table = QTableWidget(6, 2)
        b_table.setHorizontalHeaderLabels(["Property", "Value"])
        for i, (prop, val) in enumerate([
            ("Architecture", "x86_64"),
            ("Format", "ELF"),
            ("Entry Point", "0x401000"),
            ("Sections", ".text .data .rodata .bss"),
            ("Libraries", "libc.so.6, libssl.so.3"),
            ("Compiler", "GCC 12.2.0"),
        ]):
            b_table.setItem(i, 0, QTableWidgetItem(prop))
            b_table.setItem(i, 1, QTableWidgetItem(val))
        bl.addWidget(b_table)
        tabs.addTab(binary_t, "Binary Analysis")

        disasm = QFrame()
        dl = QVBoxLayout(disasm)
        dl.addWidget(QLabel("Disassembly"))
        func_combo = QComboBox()
        func_combo.addItems(["main", "check_password", "decrypt_flag", "validate_user",
                           "connect_c2", "anti_debug"])
        dl.addWidget(func_combo)
        asm_view = QTextEdit()
        asm_view.setReadOnly(True)
        asm_view.setStyleSheet("font-family: 'Consolas', monospace; font-size: 10px;")
        asm_view.append("0x401000  push    rbp")
        asm_view.append("0x401001  mov     rbp, rsp")
        asm_view.append("0x401004  sub     rsp, 0x20")
        asm_view.append("0x401008  mov     DWORD PTR [rbp-0x4], edi")
        asm_view.append("0x40100b  mov     QWORD PTR [rbp-0x10], rsi")
        asm_view.append("0x40100f  cmp     DWORD PTR [rbp-0x4], 0x2")
        asm_view.append("0x401013  jne     0x40102f")
        asm_view.append("0x401015  mov     rax, QWORD PTR [rbp-0x10]")
        dl.addWidget(asm_view)
        tabs.addTab(disasm, "Disassembly")

        strings = QFrame()
        sl = QVBoxLayout(strings)
        sl.addWidget(QLabel("String Extraction"))
        str_btn = QPushButton("Extract Strings")
        sl.addWidget(str_btn)
        s_list = QListWidget()
        for s in ["/bin/sh", "Password: ", "Flag: ", "http://c2-server.com/beacon",
                  "Decryption key: ", "Anti-debug detected", "Wrong password"]:
            s_list.addItem(s)
        sl.addWidget(s_list)
        tabs.addTab(strings, "Strings")

        layout.addWidget(tabs)
        return w
