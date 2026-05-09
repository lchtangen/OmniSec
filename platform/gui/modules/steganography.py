"""Steganography — Hide/extract data in images, audio, video"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QComboBox, QCheckBox, QFileDialog)

class SteganographyModule(OmniSecModule):
    name = "Steganography"
    description = "Hide and extract data in images, audio, and video files"
    category = "Crypto"
    version = "2.0.0"
    icon = "🖼️"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        encode = QFrame()
        el = QVBoxLayout(encode)
        el.addWidget(QLabel("Encode (Hide Data)"))
        carrier = QComboBox()
        carrier.addItems(["Image (PNG/JPEG)", "Audio (WAV/MP3)", "Video (MP4)",
                         "BMP", "GIF"])
        el.addWidget(carrier)
        el.addWidget(QLabel("Message to hide:"))
        msg = QTextEdit()
        msg.setPlaceholderText("Enter secret message or select file...")
        msg.setMaximumHeight(80)
        el.addWidget(msg)
        password = QLineEdit("Optional password")
        el.addWidget(password)
        method = QComboBox()
        method.addItems(["LSB (Least Significant Bit)", "DCT (JPEG)", "Phase Coding",
                        "Spread Spectrum", "Echo Hiding"])
        el.addWidget(method)
        encode_btn = QPushButton("Encode & Save")
        encode_btn.setObjectName("success")
        el.addWidget(encode_btn)
        tabs.addTab(encode, "Encode")

        decode_b = QFrame()
        dl = QVBoxLayout(decode_b)
        dl.addWidget(QLabel("Decode (Extract Data)"))
        dl.addWidget(QLabel("Select file with hidden data:"))
        load_btn = QPushButton("Load File")
        dl.addWidget(load_btn)
        dl.addWidget(QLabel("Password:"))
        pw = QLineEdit()
        dl.addWidget(pw)
        detect = QComboBox()
        detect.addItems(["Auto-detect", "LSB", "DCT", "Phase", "Spread Spectrum"])
        dl.addWidget(detect)
        decode_btn = QPushButton("Extract Hidden Data")
        decode_btn.setObjectName("danger")
        dl.addWidget(decode_btn)
        extracted = QTextEdit()
        extracted.setReadOnly(True)
        extracted.append("[STEGO] Analyzing image.png...")
        extracted.append("[STEGO] Hidden data detected (LSB method)")
        extracted.append("[STEGO] Extracted: 1,024 bytes")
        extracted.append("[STEGO] Content: Encrypted message + ZIP archive")
        dl.addWidget(extracted)
        tabs.addTab(decode_b, "Decode")

        analysis = QFrame()
        al = QVBoxLayout(analysis)
        al.addWidget(QLabel("Steganalysis"))
        al.addWidget(QLabel("Analyze file for hidden data:"))
        analyze_btn = QPushButton("Analyze File")
        al.addWidget(analyze_btn)
        a_out = QTextEdit()
        a_out.setReadOnly(True)
        a_out.append("[ANALYZE] File: suspicious_image.png")
        a_out.append("[ANALYZE] Entropy: 7.8 (HIGH - likely stego)")
        a_out.append("[ANALYZE] LSB analysis: Non-random pattern detected")
        a_out.append("[ANALYZE] Chi-square test: P=0.003 (hidden data)")
        al.addWidget(a_out)
        tabs.addTab(analysis, "Steganalysis")

        layout.addWidget(tabs)
        return w
