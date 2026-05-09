"""OmniSec ULTIMATE — Module System"""
import os
import importlib
import inspect
import pkgutil
from pathlib import Path

MODULE_REGISTRY = {}

class OmniSecModule:
    """Base class for all OmniSec modules"""
    name = ""
    description = ""
    category = ""
    version = "1.0.0"
    icon = ""
    author = "OmniSec"

    def __init__(self):
        self.active = False
        self.config = {}

    def initialize(self):
        self.active = True

    def shutdown(self):
        self.active = False

    def get_widget(self, parent=None):
        raise NotImplementedError

    def get_status(self):
        return {"active": self.active, "config": self.config}


def discover_modules():
    modules_dir = Path(__file__).parent
    for importer, modname, ispkg in pkgutil.iter_modules([str(modules_dir)]):
        if modname == "__init__" or modname.startswith("_"):
            continue
        try:
            module = importlib.import_module(f"gui.modules.{modname}")
            for name, obj in inspect.getmembers(module):
                if (inspect.isclass(obj) and issubclass(obj, OmniSecModule)
                        and obj != OmniSecModule):
                    instance = obj()
                    MODULE_REGISTRY[instance.name] = instance
        except Exception as e:
            print(f"  [MODULE] Failed to load {modname}: {e}")

    return MODULE_REGISTRY


def get_module(name):
    return MODULE_REGISTRY.get(name)


def get_modules_by_category(category):
    return {k: v for k, v in MODULE_REGISTRY.items() if v.category == category}


def get_all_categories():
    cats = set()
    for m in MODULE_REGISTRY.values():
        cats.add(m.category)
    return sorted(cats)


def get_module_count():
    return len(MODULE_REGISTRY)
