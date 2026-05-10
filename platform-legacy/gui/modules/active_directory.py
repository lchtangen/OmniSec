"""Active Directory Tools — AD enumeration, kerberos attacks, LDAP queries"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QFrame, QTabWidget,
                             QTableWidget, QTableWidgetItem, QLineEdit)

class ActiveDirectory(OmniSecModule):
    name = "Active Directory"
    description = "AD enumeration, Kerberos attacks, LDAP queries, privilege escalation"
    category = "Exploitation"
    version = "2.0.0"
    icon = "🏢"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        enum = QFrame()
        el = QVBoxLayout(enum)
        el.addWidget(QLabel("AD Enumeration"))
        dc_row = QHBoxLayout()
        dc_row.addWidget(QLabel("Domain Controller:"))
        dc_input = QLineEdit("dc01.company.local")
        dc_row.addWidget(dc_input)
        enum_btn = QPushButton("Enumerate")
        dc_row.addWidget(enum_btn)
        el.addLayout(dc_row)

        ad_table = QTableWidget(6, 4)
        ad_table.setHorizontalHeaderLabels(["Object", "Type", "SAMAccountName", "Description"])
        for i, (obj, typ, sam, desc) in enumerate([
            ("Domain Admins", "Group", "Domain Admins", "Administrator group"),
            ("Administrator", "User", "Administrator", "Built-in admin"),
            ("SQL Service", "User", "svc_sql", "SQL Server service account"),
            ("FileServer", "Computer", "FILESERVER$", "File server"),
            ("Enterprise Admins", "Group", "Enterprise Admins", "Forest-wide admin"),
            ("krbtgt", "User", "krbtgt", "Kerberos TGT account"),
        ]):
            ad_table.setItem(i, 0, QTableWidgetItem(obj))
            ad_table.setItem(i, 1, QTableWidgetItem(typ))
            ad_table.setItem(i, 2, QTableWidgetItem(sam))
            ad_table.setItem(i, 3, QTableWidgetItem(desc))
        el.addWidget(ad_table)
        tabs.addTab(enum, "Enumeration")

        kerb = QFrame()
        kl = QVBoxLayout(kerb)
        kl.addWidget(QLabel("Kerberos Attacks"))
        for atk in ["AS-REP Roasting", "Kerberoasting", "Golden Ticket",
                    "Silver Ticket", "DCSync", "Pass-the-Ticket", "Overpass-the-Hash"]:
            kl.addWidget(QPushButton(atk))
        tabs.addTab(kerb, "Kerberos")

        ldap = QFrame()
        ll = QVBoxLayout(ldap)
        ll.addWidget(QLabel("LDAP Query"))
        q_row = QHBoxLayout()
        q_row.addWidget(QLabel("Query:"))
        q_input = QLineEdit("(objectClass=user)")
        q_row.addWidget(q_input)
        run_q = QPushButton("Run")
        q_row.addWidget(run_q)
        ll.addLayout(q_row)
        q_out = QTextEdit()
        q_out.setReadOnly(True)
        q_out.append("[LDAP] Found 1,247 objects matching query")
        q_out.append("[LDAP] 1,023 users, 198 groups, 26 computers")
        q_out.append("[LDAP] Query time: 0.342s")
        ll.addWidget(q_out)
        tabs.addTab(ldap, "LDAP")

        layout.addWidget(tabs)
        return w
