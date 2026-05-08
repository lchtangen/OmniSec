"""OmniSec ULTIMATE — Desktop Entry Point"""
import sys
import os

def run_gui():
    from omnisec_desktop.gui import main as gui_main
    gui_main()

def run_cli():
    print("OmniSec ULTIMATE v3.0 — CLI Mode")
    print("161 tools available. Use 'omnisec-gui' for the graphical interface.")
    print("Type 'omnisec help' for commands.")

def main():
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd in ("gui", "--gui", "-g"):
            run_gui()
        elif cmd in ("help", "--help", "-h"):
            print("OmniSec ULTIMATE v3.0")
            print("  omnisec           — CLI mode")
            print("  omnisec gui       — Launch GUI")
            print("  omnisec version   — Show version")
            sys.exit(0)
        elif cmd in ("version", "--version", "-v"):
            print("OmniSec ULTIMATE v3.0")
            sys.exit(0)
        else:
            print(f"Unknown command: {cmd}")
            sys.exit(1)
    else:
        run_gui()

if __name__ == "__main__":
    main()
