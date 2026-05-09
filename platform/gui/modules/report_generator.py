"""Report Generator — PDF/HTML report creation, findings documentation"""
from gui.modules import OmniSecModule
from PyQt6.QtWidgets import (QVBoxLayout, QHBoxLayout, QPushButton, QLabel,
                             QListWidget, QTextEdit, QLineEdit, QFrame, QTabWidget,
                             QComboBox, QCheckBox, QSpinBox, QGroupBox, QFileDialog)

class ReportGenerator(OmniSecModule):
    name = "Report Generator"
    description = "Automated report generation for pentests, audits, and assessments"
    category = "Reporting"
    version = "2.0.0"
    icon = "📄"

    def get_widget(self, parent=None):
        w = QFrame(parent)
        layout = QVBoxLayout(w)
        tabs = QTabWidget()

        # Report builder
        builder = QFrame()
        bl = QVBoxLayout(builder)
        bl.addWidget(QLabel("Report Builder"))

        report_type = QComboBox()
        report_type.addItems(["Penetration Test Report", "Vulnerability Assessment",
                             "Security Audit", "Compliance Report", "Executive Summary",
                             "Technical Findings", "Red Team Assessment"])
        bl.addWidget(report_type)

        client_name = QLineEdit("Client Name")
        bl.addWidget(client_name)

        assessor = QLineEdit("Assessor Name")
        bl.addWidget(assessor)

        sections = QGroupBox("Include Sections")
        sl = QVBoxLayout(sections)
        for s in ["Executive Summary", "Methodology", "Findings", "Risk Assessment",
                  "Recommendations", "Appendix", "Screenshots", "Timeline"]:
            sl.addWidget(QCheckBox(s))
        bl.addWidget(sections)

        fmt = QGroupBox("Output Format")
        fl = QVBoxLayout(fmt)
        fl.addWidget(QCheckBox("PDF"))
        fl.addWidget(QCheckBox("HTML"))
        fl.addWidget(QCheckBox("DOCX"))
        fl.addWidget(QCheckBox("Markdown"))
        bl.addWidget(fmt)

        gen_btn = QPushButton("Generate Report")
        gen_btn.setObjectName("success")
        bl.addWidget(gen_btn)
        tabs.addTab(builder, "Report Builder")

        # Templates
        tmpl = QFrame()
        tl = QVBoxLayout(tmpl)
        tl.addWidget(QLabel("Report Templates"))
        t_list = QListWidget()
        for t in ["Standard Pentest Template", "Quick Vulnerability Scan",
                  "Full Red Team Assessment", "Compliance Audit (PCI-DSS)",
                  "Web Application Audit", "Network Infrastructure Review"]:
            t_list.addItem(t)
        tl.addWidget(t_list)
        load_t = QPushButton("Load Template")
        tl.addWidget(load_t)
        tabs.addTab(tmpl, "Templates")

        # History
        hist = QFrame()
        hl = QVBoxLayout(hist)
        hl.addWidget(QLabel("Generated Reports"))
        h_list = QListWidget()
        h_list.addItem("2026-05-01 - Acme Corp Pentest (PDF)")
        h_list.addItem("2026-04-28 - Internal Network Audit (HTML)")
        h_list.addItem("2026-04-25 - Web App Assessment (DOCX)")
        h_list.addItem("2026-04-20 - Compliance Check (PDF)")
        hl.addWidget(h_list)
        open_report = QPushButton("Open Report")
        hl.addWidget(open_report)
        tabs.addTab(hist, "History")

        layout.addWidget(tabs)
        return w
