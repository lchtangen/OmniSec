"""Internationalization loader"""
import os
import json
from pathlib import Path


class LocaleLoader:
    def __init__(self, translations_dir: str = None):
        self.translations_dir = translations_dir or str(
            Path(__file__).parent / "translations"
        )
        self.cache = {}
        self.fallback = self._load_fallback()

    def _load_fallback(self) -> dict:
        fb = Path(self.translations_dir) / "en.json"
        if fb.exists():
            return json.loads(fb.read_text())
        return {}

    def load(self, locale: str = "en") -> dict:
        locale = locale.split("_")[0]
        if locale in self.cache:
            return self.cache[locale]
        path = Path(self.translations_dir) / f"{locale}.json"
        if not path.exists():
            path = Path(self.translations_dir) / "en.json"
            if not path.exists():
                return {}
        data = json.loads(path.read_text())
        self.cache[locale] = data
        return data

    def get(self, key: str, locale: str = "en", default: str = None) -> str:
        data = self.load(locale)
        parts = key.split(".")
        for part in parts:
            if isinstance(data, dict):
                data = data.get(part, {})
            else:
                return default or key
        return data if isinstance(data, str) else default or key

    def available_locales(self) -> list[str]:
        dir_path = Path(self.translations_dir)
        if not dir_path.exists():
            return ["en"]
        return sorted(
            f.stem for f in dir_path.glob("*.json")
            if f.stem != "template"
        )
