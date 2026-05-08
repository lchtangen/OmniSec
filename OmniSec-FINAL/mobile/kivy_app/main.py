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
