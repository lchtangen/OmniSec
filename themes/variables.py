from dataclasses import dataclass


@dataclass
class ThemePalette:
    BACKGROUND: str
    SURFACE: str
    SURFACE_2: str
    PRIMARY: str
    PRIMARY_HOVER: str
    TEXT_PRIMARY: str
    TEXT_SECONDARY: str
    TEXT_DISABLED: str
    BORDER: str
    SUCCESS: str
    WARNING: str
    ERROR: str
    INFO: str
    ACCENT: str = ""
    ACCENT_2: str = ""

    def __post_init__(self):
        if not self.ACCENT:
            object.__setattr__(self, "ACCENT", self.PRIMARY)
        if not self.ACCENT_2:
            object.__setattr__(self, "ACCENT_2", self.PRIMARY_HOVER)


CYBER_DARK = ThemePalette(
    BACKGROUND="#0d1117",
    SURFACE="#161b22",
    SURFACE_2="#21262d",
    PRIMARY="#00d4ff",
    PRIMARY_HOVER="#33ddff",
    TEXT_PRIMARY="#e6edf3",
    TEXT_SECONDARY="#8b949e",
    TEXT_DISABLED="#484f58",
    BORDER="#30363d",
    SUCCESS="#3fb950",
    WARNING="#d29922",
    ERROR="#f85149",
    INFO="#58a6ff",
    ACCENT="#00d4ff",
    ACCENT_2="#ff6d00",
)

CYBER_GREEN = ThemePalette(
    BACKGROUND="#0a0f0a",
    SURFACE="#0d1a0d",
    SURFACE_2="#152315",
    PRIMARY="#00ff41",
    PRIMARY_HOVER="#33ff66",
    TEXT_PRIMARY="#ccffcc",
    TEXT_SECONDARY="#66aa66",
    TEXT_DISABLED="#335533",
    BORDER="#1a3a1a",
    SUCCESS="#00ff41",
    WARNING="#ffaa00",
    ERROR="#ff3333",
    INFO="#00aaff",
    ACCENT="#00ff41",
    ACCENT_2="#ff6d00",
)

CYBER_NEON = ThemePalette(
    BACKGROUND="#0a0a0f",
    SURFACE="#12121a",
    SURFACE_2="#1a1a2e",
    PRIMARY="#ff006e",
    PRIMARY_HOVER="#ff3399",
    TEXT_PRIMARY="#e0e0ff",
    TEXT_SECONDARY="#8888aa",
    TEXT_DISABLED="#444455",
    BORDER="#2a2a3e",
    SUCCESS="#00ff88",
    WARNING="#ffaa00",
    ERROR="#ff3355",
    INFO="#00ccff",
    ACCENT="#ff006e",
    ACCENT_2="#00ccff",
)

CYBER_PURPLE = ThemePalette(
    BACKGROUND="#0d0a1a",
    SURFACE="#1a1530",
    SURFACE_2="#252045",
    PRIMARY="#a855f7",
    PRIMARY_HOVER="#c084fc",
    TEXT_PRIMARY="#e8e0f0",
    TEXT_SECONDARY="#9888b0",
    TEXT_DISABLED="#504868",
    BORDER="#353055",
    SUCCESS="#22c55e",
    WARNING="#eab308",
    ERROR="#ef4444",
    INFO="#3b82f6",
    ACCENT="#a855f7",
    ACCENT_2="#22d3ee",
)
