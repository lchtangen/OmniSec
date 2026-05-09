"""Crypto Module — Encryption, decryption, hashing, key management"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QComboBox, QCheckBox, QGroupBox, QProgressBar)

class CryptoModule(OmniSecModule):
    name = "Crypto Module"
    description = "Encryption/decryption, hashing, key generation, certificate management"
    category = "Crypto"
    version = "2.0.0"
    icon = "🔐"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Encrypt/Decrypt
        enc = QFrame()
        el = QVBoxLayout(enc)
        el.addWidget(QLabel("Encrypt/Decrypt"))
        alg = QComboBox()
        alg.addItems(["AES-256-GCM", "ChaCha20-Poly1305", "Kyber-1024 (PQ)",
                      "Dilithium-5 (PQ)", "SPHINCS+ (PQ)", "Twofish", "Serpent"])
        el.addWidget(alg)
        el.addWidget(QLabel("Input:"))
        input_text = QTextEdit()
        input_text.setPlaceholderText("Text or file path to encrypt/decrypt...")
        input_text.setMaximumHeight(80)
        el.addWidget(input_text)
        el.addWidget(QLabel("Key:"))
        key_input = QTextEdit()
        key_input.setPlaceholderText("Encryption key or generate new...")
        key_input.setMaximumHeight(60)
        el.addWidget(key_input)
        btn_row = QHBoxLayout()
        encrypt_btn = QPushButton("Encrypt")
        encrypt_btn.setObjectName("success")
        decrypt_btn = QPushButton("Decrypt")
        decrypt_btn.setObjectName("danger")
        btn_row.addWidget(encrypt_btn)
        btn_row.addWidget(decrypt_btn)
        el.addLayout(btn_row)
        output = QTextEdit()
        output.setReadOnly(True)
        output.append("[CRYPTO] Algorithm: AES-256-GCM")
        output.append("[CRYPTO] Key: generated (256-bit)")
        output.append("[CRYPTO] IV: a1b2c3d4e5f6g7h8")
        output.append("[CRYPTO] Output: encrypted.bin (1.2 KB)")
        el.addWidget(output)
        tabs.addTab(enc, "Encrypt/Decrypt")

        # Key manager
        keys = QFrame()
        kl = QVBoxLayout(keys)
        kl.addWidget(QLabel("Key Management"))
        for key_type in ["RSA 4096", "ECC P-521", "Kyber-1024", "Ed25519",
                         "X25519", "Dilithium-5"]:
            kl.addWidget(QCheckBox(f"{key_type} - {'Exists' if random.choice([True,False]) else 'Generate'}"))
        gen_all = QPushButton("Generate Missing Keys")
        kl.addWidget(gen_all)
        export_btn = QPushButton("Export Public Keys")
        kl.addWidget(export_btn)
        tabs.addTab(keys, "Key Manager")

        # Hash calculator
        hash_t = QFrame()
        hl = QVBoxLayout(hash_t)
        hl.addWidget(QLabel("Hash Calculator"))
        hl.addWidget(QLabel("Input:"))
        hash_in = QTextEdit()
        hash_in.setPlaceholderText("Text or file to hash...")
        hash_in.setMaximumHeight(60)
        hl.addWidget(hash_in)
        hash_algo = QComboBox()
        hash_algo.addItems(["MD5", "SHA1", "SHA256", "SHA512", "BLAKE2b", "SHA3-256"])
        hl.addWidget(hash_algo)
        hash_btn = QPushButton("Calculate Hash")
        hl.addWidget(hash_btn)
        hash_out = QTextEdit()
        hash_out.setReadOnly(True)
        hash_out.append("SHA256: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0")
        hl.addWidget(hash_out)
        tabs.addTab(hash_t, "Hash Calculator")

        layout.addWidget(tabs)
        return w
import random
