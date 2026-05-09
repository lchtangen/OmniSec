"""OmniSec ULTIMATE — Desktop GUI (imported from PyQT6)"""
import sys
import os

GUI_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "gui", "omnisec-gui.py")

def main():
    if os.path.exists(GUI_PATH):
        sys.path.insert(0, os.path.dirname(GUI_PATH))
        exec(open(GUI_PATH).read())
    else:
        print(f"GUI file not found at: {GUI_PATH}")
        print("Please ensure the gui/main.py file exists.")
        sys.exit(1)

if __name__ == "__main__":
    main()
