from __future__ import annotations

import dataclasses
from collections.abc import Callable
from pathlib import Path

from .variables import CYBER_DARK, CYBER_GREEN, CYBER_NEON, CYBER_PURPLE, ThemePalette

_THEMES_DIR = Path(__file__).parent

THEMES: dict[str, ThemePalette] = {
    "cyber_dark": CYBER_DARK,
    "cyber_green": CYBER_GREEN,
    "cyber_neon": CYBER_NEON,
    "cyber_purple": CYBER_PURPLE,
}


class ThemeEngine:
    current_theme: str = "cyber_dark"
    _callbacks: list[Callable[[], None]] = []

    @classmethod
    def register_on_change(cls, cb: Callable[[], None]) -> None:
        if cb not in cls._callbacks:
            cls._callbacks.append(cb)

    @classmethod
    def unregister_on_change(cls, cb: Callable[[], None]) -> None:
        cls._callbacks = [c for c in cls._callbacks if c is not cb]

    @classmethod
    def apply_theme(cls, name: str, app=None) -> None:
        palette = cls.get_palette(name)
        qss_path = _THEMES_DIR / f"{name}.qss"

        if not qss_path.exists():
            qss_path = _THEMES_DIR / "cyber_dark.qss"

        template = qss_path.read_text(encoding="utf-8")
        stylesheet = cls._substitute_tokens(template, palette)

        if app is not None:
            app.setStyleSheet(stylesheet)

        cls.current_theme = name

        for cb in list(cls._callbacks):
            try:
                cb()
            except RuntimeError:
                cls._callbacks = [c for c in cls._callbacks if c is not cb]

    @classmethod
    def get_palette(cls, name: str) -> ThemePalette:
        if name not in THEMES:
            raise ValueError(f"Unknown theme: {name!r}. Available: {list(THEMES)}")
        return THEMES[name]

    @staticmethod
    def _substitute_tokens(template: str, palette: ThemePalette) -> str:
        result = template
        for field in dataclasses.fields(palette):
            token = f"{{{field.name}}}"
            value = getattr(palette, field.name)
            result = result.replace(token, value)
        result = result.replace("{{", "{").replace("}}", "}")
        return result
