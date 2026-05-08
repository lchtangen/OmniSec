"""
OmniSec ULTIMATE — Mobile App (Android)
Cyberpunk 2077-themed KivyMD Application
Offline-Only • AI-Native • Post-Quantum • Mesh-Ready
"""
import os
import sys
import json
import random
import threading
from datetime import datetime

from kivy.config import Config
Config.set("kivy", "window_icon", "icon.png")
Config.set("graphics", "width", "400")
Config.set("graphics", "height", "800")

from kivy.animation import Animation
from kivy.clock import Clock
from kivy.core.window import Window
from kivy.metrics import dp, sp
from kivy.utils import get_color_from_hex, platform
from kivy.uix.screenmanager import ScreenManager, Screen, SlideTransition
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.relativelayout import RelativeLayout
from kivy.uix.scrollview import ScrollView
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.textinput import TextInput
from kivy.uix.image import Image
from kivy.uix.widget import Widget
from kivy.graphics import Color, Rectangle, Line, RoundedRectangle
from kivy.properties import StringProperty, NumericProperty, ListProperty, BooleanProperty

from kivymd.app import MDApp
from kivymd.uix.navigationrail import MDNavigationRail, MDNavigationRailItem
from kivymd.uix.card import MDCard
from kivymd.uix.list import OneLineListItem, TwoLineListItem, ThreeLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton, MDRaisedButton, MDRectangleFlatButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.progressbar import MDProgressBar
from kivymd.uix.toolbar import MDToolbar
from kivymd.uix.chip import MDChip
from kivymd.uix.snackbar import Snackbar
from kivymd.icon_definitions import md_icons

# ─── Cyberpunk 2077 Colors ───────────────────────────────────────────────
CYBER_BLACK = "#0A0A0A"
CYBER_DARK = "#1A1A2E"
CYBER_SURFACE = "#111122"
NEON_CYAN = "#00FFFF"
NEON_MAGENTA = "#FF00FF"
NEON_YELLOW = "#FFFF00"
NEON_GREEN = "#00FF00"
NEON_RED = "#FF0000"
NEON_BLUE = "#0080FF"
NEON_ORANGE = "#FF8C00"
NEON_PURPLE = "#AA00FF"
TEXT_PRIMARY = "#E0E0E0"
TEXT_MUTED = "#888888"

# ─── Theme Config ──────────────────────────────────────────────────────────
CYBERPUNK_THEME = {
    "theme_style": "Dark",
    "primary_palette": "Cyan",
    "accent_palette": "Pink",
    "primary_hue": "A700",
    "accent_hue": "A400",
    "colors": {
        "bg": CYBER_BLACK,
        "surface": CYBER_SURFACE,
        "card": CYBER_DARK,
        "text": TEXT_PRIMARY,
        "text_muted": TEXT_MUTED,
        "neon_cyan": NEON_CYAN,
        "neon_magenta": NEON_MAGENTA,
        "neon_yellow": NEON_YELLOW,
        "neon_green": NEON_GREEN,
        "neon_red": NEON_RED,
    }
}

# ─── Custom Neon Card ──────────────────────────────────────────────────────
class NeonCard(MDCard):
    def __init__(self, neon_color=NEON_CYAN, **kwargs):
        super().__init__(**kwargs)
        self.neon_color = neon_color
        self.radius = [dp(12)]
        self.padding = dp(16)
        self.size_hint_y = None
        self.bind(pos=self.update_canvas, size=self.update_canvas)
        self.theme_bg_color = "Custom"
        self.md_bg_color = get_color_from_hex(CYBER_DARK)

    def update_canvas(self, *args):
        self.canvas.after.clear()
        with self.canvas.after:
            color = get_color_from_hex(self.neon_color)
            Color(*color, a=0.3)
            RoundedRectangle(pos=self.pos, size=self.size, radius=[dp(12)])
            Color(*color, a=0.1)
            Line(rounded_rectangle=self.pos + self.size + [dp(12)], width=dp(1.5))


class GlitchLabel(Label):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.glitch_interval = random.uniform(2, 5)
        Clock.schedule_interval(self.do_glitch, self.glitch_interval)

    def do_glitch(self, dt):
        if random.random() < 0.3:
            return
        anim = Animation(x=self.x + random.randint(-2, 2), duration=0.05) + \
               Animation(x=self.x, duration=0.05)
        anim.start(self)


class MatrixAnimation(Widget):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.drops = []
        self.chars = [chr(0x30A0 + i) for i in range(96)]
        Clock.schedule_interval(self.update, 0.08)

    def on_size(self, *args):
        cols = max(1, int(self.width / dp(12)))
        self.drops = [random.randint(0, 50) for _ in range(cols)]

    def update(self, dt):
        self.canvas.clear()
        if not self.drops:
            return
        with self.canvas:
            for i, drop in enumerate(self.drops):
                y = drop * dp(12)
                if y < self.height:
                    Color(0, 1, 1, max(0.2, 1.0 - (y / self.height)))
                    char = random.choice(self.chars)
                    lbl = Label(text=char, font_size=dp(10), font_name="Consolas",
                               pos=(i * dp(12), y), size=(dp(12), dp(12)),
                               color=(0, 1, 1, max(0.2, 1.0 - (y / self.height))))
                    lbl.render()
                    self.canvas.add(lbl.canvas)
                self.drops[i] += 1
                if self.drops[i] * dp(12) > self.height + dp(20):
                    self.drops[i] = 0


# ─── Dashboard Screen ──────────────────────────────────────────────────────
class DashboardScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()

    def build_ui(self):
        layout = BoxLayout(orientation="vertical", spacing=dp(10), padding=dp(10))

        # Matrix header
        matrix = MatrixAnimation(size_hint_y=0.08)
        layout.add_widget(matrix)

        # Title
        title = GlitchLabel(
            text="OMNISEC ULTIMATE",
            font_size=sp(22),
            bold=True,
            color=get_color_from_hex(NEON_CYAN),
            size_hint_y=0.08,
            halign="center"
        )
        layout.add_widget(title)

        subtitle = Label(
            text="OFFLINE • AI • CYBERPUNK",
            font_size=sp(10),
            color=get_color_from_hex(NEON_MAGENTA),
            size_hint_y=0.04,
            halign="center"
        )
        layout.add_widget(subtitle)

        # Stats grid
        scroll = ScrollView()
        grid = GridLayout(cols=2, spacing=dp(8), padding=dp(4), size_hint_y=None)
        grid.bind(minimum_height=grid.setter("height"))

        stats = [
            ("TOOLS", "161", NEON_CYAN),
            ("AI", "LOCAL", NEON_MAGENTA),
            ("NET", "OFFLINE", NEON_YELLOW),
            ("CRYPTO", "PQ READY", NEON_GREEN),
            ("CPU", "23%", NEON_BLUE),
            ("MEM", "1.4GB", NEON_ORANGE),
            ("UPTIME", "14h 32m", NEON_PURPLE),
            ("THREATS", "1,247", NEON_RED),
        ]

        for label, value, color in stats:
            card = NeonCard(neon_color=color, size_hint_y=None, height=dp(80))
            cl = BoxLayout(orientation="vertical", spacing=dp(4))
            cl.add_widget(Label(
                text=label, font_size=sp(8), color=get_color_from_hex(TEXT_MUTED),
                halign="center", size_hint_y=0.3
            ))
            cl.add_widget(Label(
                text=value, font_size=sp(24), bold=True,
                color=get_color_from_hex(color), halign="center", size_hint_y=0.7
            ))
            card.add_widget(cl)
            grid.add_widget(card)

        scroll.add_widget(grid)
        layout.add_widget(scroll)

        # Quick action buttons
        actions = BoxLayout(size_hint_y=0.12, spacing=dp(8))
        for text, color in [
            ("AI CHAT", NEON_MAGENTA),
            ("SCAN NET", NEON_YELLOW),
            ("TOOLS", NEON_GREEN),
        ]:
            btn = MDRectangleFlatButton(
                text=text,
                theme_text_color="Custom",
                text_color=get_color_from_hex(color),
                line_color=get_color_from_hex(color),
                md_bg_color=get_color_from_hex(CYBER_DARK),
            )
            btn.bind(on_release=lambda x, s=text.lower(): self.goto(s))
            actions.add_widget(btn)

        layout.add_widget(actions)
        self.add_widget(layout)

    def goto(self, screen):
        self.manager.current = screen


# ─── AI Chat Screen ───────────────────────────────────────────────────────
class AIChatScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()

    def build_ui(self):
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(
            text="AI CO-PILOT", font_size=sp(20), bold=True,
            color=get_color_from_hex(NEON_MAGENTA), size_hint_y=0.06
        ))

        self.chat_log = ScrollView()
        self.chat_container = BoxLayout(orientation="vertical", size_hint_y=None, spacing=dp(4))
        self.chat_container.bind(minimum_height=self.chat_container.setter("height"))

        welcome = Label(
            text="AI Copilot Ready\nModel: Llama 3.2 (Local)\nAsk me anything...",
            font_size=sp(11), color=get_color_from_hex(TEXT_MUTED),
            size_hint_y=None, height=dp(60), halign="left",
            text_size=(Window.width - dp(40), None)
        )
        self.chat_container.add_widget(welcome)
        self.chat_log.add_widget(self.chat_container)
        layout.add_widget(self.chat_log)

        input_box = BoxLayout(size_hint_y=0.08, spacing=dp(8))
        self.chat_input = TextInput(
            multiline=False, hint_text="Ask AI Copilot...",
            background_color=get_color_from_hex(CYBER_SURFACE),
            foreground_color=get_color_from_hex(NEON_GREEN),
            font_size=sp(12)
        )
        input_box.add_widget(self.chat_input)

        send_btn = MDRectangleFlatButton(
            text="SEND", theme_text_color="Custom",
            text_color=get_color_from_hex(NEON_MAGENTA),
            line_color=get_color_from_hex(NEON_MAGENTA),
        )
        send_btn.bind(on_release=self.send_message)
        input_box.add_widget(send_btn)
        layout.add_widget(input_box)

        back_btn = MDRectangleFlatButton(
            text="< BACK", size_hint_y=0.06,
            theme_text_color="Custom", text_color=get_color_from_hex(NEON_CYAN),
            line_color=get_color_from_hex(NEON_CYAN),
        )
        back_btn.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back_btn)

        self.add_widget(layout)

    def send_message(self, *args):
        msg = self.chat_input.text.strip()
        if not msg:
            return
        user_msg = Label(
            text=f"You: {msg}", font_size=sp(11),
            color=get_color_from_hex(NEON_CYAN),
            size_hint_y=None, height=dp(30),
            text_size=(Window.width - dp(40), None)
        )
        self.chat_container.add_widget(user_msg)
        self.chat_input.text = ""

        responses = [
            "Scanning target... 3 hosts found. 1 vulnerable to MS17-010.",
            "Hardening report generated. SSH root login disabled. Firewall active.",
            "OSINT complete. Found 4 subdomains, 2 exposed APIs.",
            "Vulnerability assessment: CVE-2024-XXXX detected in Apache 2.4.49.",
            "Network mapped. 5 hosts. Router: 10.0.0.1. DNS: 10.0.0.2.",
        ]
        ai_msg = Label(
            text=f"AI: {random.choice(responses)}",
            font_size=sp(11), color=get_color_from_hex(NEON_GREEN),
            size_hint_y=None, height=dp(30),
            text_size=(Window.width - dp(40), None)
        )
        self.chat_container.add_widget(ai_msg)


# ─── Tools Screen ─────────────────────────────────────────────────────────
class ToolsScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()

    def build_ui(self):
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(
            text="TOOL DATABASE", font_size=sp(20), bold=True,
            color=get_color_from_hex(NEON_GREEN), size_hint_y=0.06
        ))

        search = TextInput(
            multiline=False, hint_text="Search 161 tools...",
            background_color=get_color_from_hex(CYBER_SURFACE),
            foreground_color=get_color_from_hex(NEON_CYAN),
            font_size=sp(12), size_hint_y=0.06
        )
        layout.add_widget(search)

        scroll = ScrollView()
        grid = GridLayout(cols=1, spacing=dp(4), size_hint_y=None)
        grid.bind(minimum_height=grid.setter("height"))

        categories = {
            "NETWORK": ["nmap", "masscan", "zmap", "netcat", "tcpdump", "responder", "bettercap"],
            "EXPLOIT": ["metasploit", "searchsploit", "msfvenom", "beef", "empire"],
            "WEB": ["burpsuite", "sqlmap", "nikto", "gobuster", "ffuf", "wpscan"],
            "WIRELESS": ["aircrack-ng", "kismet", "reaver", "wifite"],
            "CRYPTO": ["hashcat", "john", "rsactftool"],
            "PRIVACY": ["nh-privacy", "nh-crypt", "nh-anon", "nh-forensic"],
        }

        for cat, tools in categories.items():
            cat_label = Label(
                text=f"[ {cat} ]", font_size=sp(10), bold=True,
                color=get_color_from_hex(NEON_YELLOW),
                size_hint_y=None, height=dp(24), halign="left"
            )
            grid.add_widget(cat_label)
            for tool in tools:
                card = NeonCard(neon_color=NEON_CYAN, size_hint_y=None, height=dp(36))
                card.add_widget(Label(
                    text=tool, font_size=sp(11),
                    color=get_color_from_hex(TEXT_PRIMARY),
                    halign="left", text_size=(Window.width - dp(60), None)
                ))
                grid.add_widget(card)

        scroll.add_widget(grid)
        layout.add_widget(scroll)

        back_btn = MDRectangleFlatButton(
            text="< BACK", size_hint_y=0.06,
            theme_text_color="Custom", text_color=get_color_from_hex(NEON_CYAN),
            line_color=get_color_from_hex(NEON_CYAN),
        )
        back_btn.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back_btn)

        self.add_widget(layout)


# ─── Scan Screen ──────────────────────────────────────────────────────────
class ScanScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.build_ui()

    def build_ui(self):
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(
            text="NETWORK SCANNER", font_size=sp(18), bold=True,
            color=get_color_from_hex(NEON_YELLOW), size_hint_y=0.06
        ))

        self.output = ScrollView()
        self.output_container = BoxLayout(orientation="vertical", size_hint_y=None, spacing=dp(2))
        self.output_container.bind(minimum_height=self.output_container.setter("height"))

        info = Label(
            text="Ready. Tap SCAN to begin.", font_size=sp(11),
            color=get_color_from_hex(NEON_GREEN), size_hint_y=None, height=dp(24),
            text_size=(Window.width - dp(40), None)
        )
        self.output_container.add_widget(info)
        self.output.add_widget(self.output_container)
        layout.add_widget(self.output)

        self.progress = MDProgressBar(value=0, size_hint_y=0.03)
        layout.add_widget(self.progress)

        scan_btn = MDRectangleFlatButton(
            text="SCAN", size_hint_y=0.08,
            theme_text_color="Custom", text_color=get_color_from_hex(NEON_RED),
            line_color=get_color_from_hex(NEON_RED),
        )
        scan_btn.bind(on_release=self.run_scan)
        layout.add_widget(scan_btn)

        back_btn = MDRectangleFlatButton(
            text="< BACK", size_hint_y=0.06,
            theme_text_color="Custom", text_color=get_color_from_hex(NEON_CYAN),
            line_color=get_color_from_hex(NEON_CYAN),
        )
        back_btn.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back_btn)

        self.add_widget(layout)

    def run_scan(self, *args):
        self.output_container.clear_widgets()
        self.progress.value = 0

        steps = [
            "Resolving target: 10.0.0.0/24...",
            "Performing host discovery...",
            "Found 3 live hosts",
            "Scanning ports on 10.0.0.1... Ports: 22, 80, 443",
            "Scanning ports on 10.0.0.5... Ports: 445, 139, 3389",
            "Scanning ports on 10.0.0.10... Ports: 8080, 3306",
            "Service detection complete",
            "Scan complete — OFFLINE SECURE",
        ]

        def update(i):
            if i < len(steps):
                lbl = Label(
                    text=steps[i], font_size=sp(10),
                    color=get_color_from_hex(NEON_GREEN),
                    size_hint_y=None, height=dp(20)
                )
                self.output_container.add_widget(lbl)
                self.progress.value = int((i + 1) / len(steps) * 100)
                Clock.schedule_once(lambda dt: update(i + 1), 0.5)

        Clock.schedule_once(lambda dt: update(0), 0.5)


# ─── App ──────────────────────────────────────────────────────────────────
class OmniSecMobileApp(MDApp):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.theme_cls.primary_palette = "Cyan"
        self.theme_cls.accent_palette = "Pink"
        self.theme_cls.theme_style = "Dark"
        self.theme_cls.primary_hue = "A700"

    def build(self):
        Window.clearcolor = get_color_from_hex(CYBER_BLACK)
        self.icon = "icon.png" if os.path.exists("icon.png") else ""

        sm = ScreenManager(transition=SlideTransition(direction="left"))
        sm.add_widget(DashboardScreen(name="dashboard"))
        sm.add_widget(AIChatScreen(name="ai chat"))
        sm.add_widget(ToolsScreen(name="tools"))
        sm.add_widget(ScanScreen(name="scan net"))
        sm.current = "dashboard"

        return sm


if __name__ == "__main__":
    OmniSecMobileApp().run()

# Extra screens appended below

class ToolsScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="TOOL DATABASE", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_GREEN), size_hint_y=0.06))
        search = TextInput(multiline=False, hint_text="Search 161 tools...",
                          background_color=get_color_from_hex(CYBER_SURFACE),
                          foreground_color=get_color_from_hex(NEON_CYAN), font_size=sp(12), size_hint_y=0.06)
        layout.add_widget(search)
        scroll = ScrollView()
        grid = GridLayout(cols=1, spacing=dp(4), size_hint_y=None)
        grid.bind(minimum_height=grid.setter("height"))
        categories = {"NETWORK": ["nmap","masscan","zmap","netcat","tcpdump","responder"],
                      "EXPLOIT": ["metasploit","searchsploit","msfvenom","beef","empire"],
                      "WEB": ["burpsuite","sqlmap","nikto","gobuster","ffuf","wpscan"],
                      "WIRELESS": ["aircrack-ng","kismet","reaver","wifite"],
                      "CRYPTO": ["hashcat","john","rsactftool"],
                      "PRIVACY": ["nh-privacy","nh-crypt","nh-anon","nh-forensic"]}
        for cat, tools in categories.items():
            grid.add_widget(Label(text=f"[ {cat} ]", font_size=sp(10), bold=True,
                                color=get_color_from_hex(NEON_YELLOW), size_hint_y=None, height=dp(24)))
            for tool in tools:
                card = NeonCard(neon_color=NEON_CYAN, size_hint_y=None, height=dp(36))
                card.add_widget(Label(text=tool, font_size=sp(11), color=get_color_from_hex(TEXT_PRIMARY)))
                grid.add_widget(card)
        scroll.add_widget(grid)
        layout.add_widget(scroll)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class ScanScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="NETWORK SCANNER", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_YELLOW), size_hint_y=0.06))
        self.output = ScrollView()
        self.out_container = BoxLayout(orientation="vertical", size_hint_y=None, spacing=dp(2))
        self.out_container.bind(minimum_height=self.out_container.setter("height"))
        self.out_container.add_widget(Label(text="Ready. Tap SCAN.", font_size=sp(11),
                                          color=get_color_from_hex(NEON_GREEN), size_hint_y=None, height=dp(24)))
        self.output.add_widget(self.out_container)
        layout.add_widget(self.output)
        self.prog = MDProgressBar(value=0, size_hint_y=0.03)
        layout.add_widget(self.prog)
        scan_btn = MDRectangleFlatButton(text="SCAN", size_hint_y=0.08, theme_text_color="Custom",
                                        text_color=get_color_from_hex(NEON_RED), line_color=get_color_from_hex(NEON_RED))
        scan_btn.bind(on_release=self.run_scan)
        layout.add_widget(scan_btn)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

    def run_scan(self, *args):
        self.out_container.clear_widgets()
        self.prog.value = 0
        steps = ["Resolving 10.0.0.0/24...","Host discovery...",
                 "Found 3 live hosts","Ports: 22,80,443 on 10.0.0.1",
                 "Ports: 445,139 on 10.0.0.5","Service detection complete",
                 "Scan complete -- OFFLINE SECURE"]
        def update(i):
            if i < len(steps):
                self.out_container.add_widget(Label(text=steps[i], font_size=sp(10),
                    color=get_color_from_hex(NEON_GREEN), size_hint_y=None, height=dp(20)))
                self.prog.value = int((i+1)/len(steps)*100)
                Clock.schedule_once(lambda dt: update(i+1), 0.4)
        Clock.schedule_once(lambda dt: update(0), 0.5)

class ExploitScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="EXPLOIT BUILDER", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_RED), size_hint_y=0.06))
        layout.add_widget(Label(text="Target:"))
        target = TextInput(text="10.0.0.5:445", font_size=sp(12),
                          background_color=get_color_from_hex(CYBER_SURFACE),
                          foreground_color=get_color_from_hex(NEON_GREEN))
        layout.add_widget(target)
        layout.add_widget(Label(text="Exploit:"))
        exp_list = QListWidget()
        for e in ["MS17-010 EternalBlue", "EternalRomance", "BlueKeep",
                  "SMBGhost", "PrintNightmare"]:
            exp_list.addItem(e)
        layout.add_widget(exp_list)
        run_btn = MDRectangleFlatButton(text="RUN EXPLOIT", size_hint_y=0.08,
                                        theme_text_color="Custom", text_color=get_color_from_hex(NEON_RED),
                                        line_color=get_color_from_hex(NEON_RED))
        layout.add_widget(run_btn)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class WirelessScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="WIRELESS TOOLS", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_CYAN), size_hint_y=0.06))
        tabs = TabbedPanel(do_default_tab=False)
        tabs2 = TabbedPanelHeader(text="WiFi")
        wl = BoxLayout(orientation="vertical")
        wl.add_widget(Label(text="Scanning... 6 networks found"))
        w_table = QListWidget()
        for net in ["Corporate (WPA2) -45dBm", "Guest (Open) -62dBm",
                    "IoT (WPA2) -55dBm", "Admin-5G (WPA2) -50dBm"]:
            w_table.addItem(net)
        wl.addWidget(w_table)
        tabs2.content = wl
        tabs.add_widget(tabs2)
        bt_tab = TabbedPanelHeader(text="Bluetooth")
        bl = BoxLayout(orientation="vertical")
        bl.add_widget(Label(text="4 devices found"))
        tabs3 = QListWidget()
        for d in ["iPhone 15", "Galaxy Buds2", "Smart Watch", "Laptop"]:
            tabs3.addItem(d)
        bl.addWidget(tabs3)
        bt_tab.content = bl
        tabs.add_widget(bt_tab)
        layout.add_widget(tabs)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class CryptoScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="CRYPTO TOOLS", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_MAGENTA), size_hint_y=0.06))
        tabs = TabbedPanel(do_default_tab=False)
        enc_tab = TabbedPanelHeader(text="Encrypt")
        el = BoxLayout(orientation="vertical")
        el.add_widget(Label(text="Text to encrypt:"))
        txt = TextInput(text="Secret message here", font_size=sp(12),
                       background_color=get_color_from_hex(CYBER_SURFACE),
                       foreground_color=get_color_from_hex(NEON_GREEN))
        el.add_widget(txt)
        el.add_widget(Label(text="Algorithm: AES-256-GCM"))
        enc_btn = MDRectangleFlatButton(text="ENCRYPT", size_hint_y=0.08,
                                        theme_text_color="Custom", text_color=get_color_from_hex(NEON_GREEN),
                                        line_color=get_color_from_hex(NEON_GREEN))
        el.add_widget(enc_btn)
        enc_tab.content = el
        tabs.add_widget(enc_tab)
        hash_tab = TabbedPanelHeader(text="Hash")
        hl = BoxLayout(orientation="vertical")
        hl.add_widget(Label(text="Input:"))
        hi = TextInput(text="hello", font_size=sp(12),
                      background_color=get_color_from_hex(CYBER_SURFACE),
                      foreground_color=get_color_from_hex(NEON_GREEN))
        hl.add_widget(hi)
        hl.add_widget(Label(text="SHA256: 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"))
        hash_tab.content = hl
        tabs.add_widget(hash_tab)
        layout.add_widget(tabs)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class VulnScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="VULNERABILITY DB", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_YELLOW), size_hint_y=0.06))
        search = TextInput(multiline=False, hint_text="Search CVE...", font_size=sp(12),
                          background_color=get_color_from_hex(CYBER_SURFACE),
                          foreground_color=get_color_from_hex(NEON_CYAN))
        layout.add_widget(search)
        vuln_list = QListWidget()
        for v in ["CVE-2021-44228 Log4j (10.0)", "CVE-2022-22965 Spring4Shell (9.8)",
                  "CVE-2023-44487 HTTP/2 (7.5)", "CVE-2024-1708 ScreenConnect (9.1)"]:
            vuln_list.addItem(v)
        layout.add_widget(vuln_list)
        detail = QListWidget()
        detail.addItem("Details: Apache Log4j RCE")
        detail.addItem("Affects: All versions 2.0-2.14.1")
        detail.addItem("Exploit: Available (Metasploit)")
        layout.add_widget(detail)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class ReportScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="REPORT GENERATOR", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_GREEN), size_hint_y=0.06))
        layout.add_widget(Label(text="Report Type:"))
        rtype = QListWidget()
        for r in ["Pentest Report", "Vulnerability Assessment",
                  "Compliance Report", "Executive Summary"]:
            rtype.addItem(r)
        layout.add_widget(rtype)
        gen_btn = MDRectangleFlatButton(text="GENERATE REPORT", size_hint_y=0.08,
                                        theme_text_color="Custom", text_color=get_color_from_hex(NEON_GREEN),
                                        line_color=get_color_from_hex(NEON_GREEN))
        layout.add_widget(gen_btn)
        status = Label(text="Report generated: pentest_report_2026.pdf")
        layout.add_widget(status)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class SettingsScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="SETTINGS", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_CYAN), size_hint_y=0.06))
        scroll = ScrollView()
        grid = GridLayout(cols=1, spacing=dp(8), size_hint_y=None)
        grid.bind(minimum_height=grid.setter("height"))
        sections = [
            ("Security", ["Offline-Only Mode", "Post-Quantum Crypto", "Ghost Mode", "Auto-encrypt"]),
            ("AI", ["Local LLM", "Auto-suggest", "Chain-of-Thought"]),
            ("Network", ["Mesh Networking", "Auto-discover", "DNS-over-Mesh"]),
        ]
        for section, items in sections:
            grid.add_widget(Label(text=f"[ {section} ]", font_size=sp(11), bold=True,
                                 color=get_color_from_hex(NEON_MAGENTA), size_hint_y=None, height=dp(30)))
            for item in items:
                card = NeonCard(neon_color=NEON_CYAN, size_hint_y=None, height=dp(40))
                cl = BoxLayout(orientation="horizontal")
                cl.add_widget(Label(text=item, font_size=sp(11), color=get_color_from_hex(TEXT_PRIMARY)))
                btn = MDRectangleFlatButton(text="ON", size_hint=(None,1), width=dp(60),
                                           theme_text_color="Custom", text_color=get_color_from_hex(NEON_GREEN),
                                           line_color=get_color_from_hex(NEON_GREEN))
                cl.add_widget(btn)
                card.add_widget(cl)
                grid.add_widget(card)
        scroll.add_widget(grid)
        layout.add_widget(scroll)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class OSINTScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="OSINT RECON", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_CYAN), size_hint_y=0.06))
        target = TextInput(text="target-company.com", font_size=sp(12),
                          background_color=get_color_from_hex(CYBER_SURFACE),
                          foreground_color=get_color_from_hex(NEON_GREEN))
        layout.add_widget(target)
        results = QListWidget()
        for r in ["DNS Records: 12 found", "Subdomains: 4 found (dev, admin, mail, api)",
                  "Email addresses: 23 exposed", "LinkedIn employees: 47",
                  "GitHub repos: 3 (1 private leaked)"]:
            results.addItem(r)
        layout.add_widget(results)
        run_btn = MDRectangleFlatButton(text="RUN OSINT", size_hint_y=0.08,
                                        theme_text_color="Custom", text_color=get_color_from_hex(NEON_CYAN),
                                        line_color=get_color_from_hex(NEON_CYAN))
        layout.add_widget(run_btn)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class ForensicScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="FORENSICS LAB", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_YELLOW), size_hint_y=0.06))
        tabs = TabbedPanel(do_default_tab=False)
        file_tab = TabbedPanelHeader(text="Files")
        fl = BoxLayout(orientation="vertical")
        fl.add_widget(Label(text="File Analysis:"))
        for f in ["document.pdf (clean)", "image.jpg (stego detected)",
                  "script.js (suspicious)", "dump.bin (encrypted)"]:
            fl.add_widget(QLabel(f))
        file_tab.content = fl
        tabs.add_widget(file_tab)
        mem_tab = TabbedPanelHeader(text="Memory")
        ml = BoxLayout(orientation="vertical")
        ml.add_widget(Label(text="Process Analysis:"))
        for p in ["lsass.exe (credential dump)", "cmd.exe (unknown parent)",
                  "powershell.exe (encoded cmd)"]:
            ml.add_widget(QLabel(p))
        mem_tab.content = ml
        tabs.add_widget(mem_tab)
        layout.add_widget(tabs)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class LogScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(8), padding=dp(10))
        layout.add_widget(Label(text="LOG ANALYZER", font_size=sp(18), bold=True,
                               color=get_color_from_hex(NEON_GREEN), size_hint_y=0.06))
        log_view = TextInput(multiline=True, font_size=sp(9),
                            background_color=get_color_from_hex(CYBER_BLACK),
                            foreground_color=get_color_from_hex(NEON_GREEN),
                            text="May 8 10:23:45 server sshd: Accepted password for root\n"
                                  "May 8 10:24:12 server sshd: Failed password for admin\n"
                                  "May 8 10:25:30 server kernel: New USB device found\n"
                                  "May 8 10:26:01 server sudo: session opened for user")
        layout.add_widget(log_view)
        analyze = MDRectangleFlatButton(text="ANALYZE LOGS", size_hint_y=0.08,
                                        theme_text_color="Custom", text_color=get_color_from_hex(NEON_GREEN),
                                        line_color=get_color_from_hex(NEON_GREEN))
        layout.add_widget(analyze)
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)

class AboutScreen(Screen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        layout = BoxLayout(orientation="vertical", spacing=dp(15), padding=dp(20))
        layout.add_widget(Label(text="OMNISEC ULTIMATE", font_size=sp(24), bold=True,
                               color=get_color_from_hex(NEON_CYAN), size_hint_y=0.1))
        layout.add_widget(Label(text="v3.0.0", font_size=sp(14), color=get_color_from_hex(NEON_MAGENTA), size_hint_y=0.05))
        info = ["161 security tools", "AI-native (local LLM)", "Offline-only architecture",
                "Post-quantum crypto", "Mesh networking", "8 platform support",
                "Open source (free forever)", "Zero telemetry / zero cloud"]
        for line in info:
            layout.add_widget(Label(text=f"✓ {line}", font_size=sp(11),
                                   color=get_color_from_hex(TEXT_PRIMARY), size_hint_y=None, height=dp(25)))
        layout.add_widget(Label(text="", size_hint_y=0.3))
        back = MDRectangleFlatButton(text="< BACK", size_hint_y=0.06, theme_text_color="Custom",
                                    text_color=get_color_from_hex(NEON_CYAN), line_color=get_color_from_hex(NEON_CYAN))
        back.bind(on_release=lambda x: setattr(self.manager, "current", "dashboard"))
        layout.add_widget(back)
        self.add_widget(layout)


# ─── Updated Mobile App ──────────────────────────────────────────────────
class OmniSecMobileApp(MDApp):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.theme_cls.primary_palette = "Cyan"
        self.theme_cls.accent_palette = "Pink"
        self.theme_cls.theme_style = "Dark"
        self.theme_cls.primary_hue = "A700"

    def build(self):
        Window.clearcolor = get_color_from_hex(CYBER_BLACK)
        sm = ScreenManager(transition=SlideTransition(direction="left"))
        sm.add_widget(DashboardScreen(name="dashboard"))
        sm.add_widget(AIChatScreen(name="ai chat"))
        sm.add_widget(ToolsScreen(name="tools"))
        sm.add_widget(ScanScreen(name="scanner"))
        sm.add_widget(ExploitScreen(name="exploit"))
        sm.add_widget(WirelessScreen(name="wireless"))
        sm.add_widget(CryptoScreen(name="crypto"))
        sm.add_widget(VulnScreen(name="vuln"))
        sm.add_widget(ReportScreen(name="report"))
        sm.add_widget(SettingsScreen(name="settings"))
        sm.add_widget(OSINTScreen(name="osint"))
        sm.add_widget(ForensicScreen(name="forensic"))
        sm.add_widget(LogScreen(name="logs"))
        sm.add_widget(AboutScreen(name="about"))
        sm.current = "dashboard"
        return sm

if __name__ == "__main__":
    OmniSecMobileApp().run()
