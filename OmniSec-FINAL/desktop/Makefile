.PHONY: all clean install uninstall appimage deb pip

VERSION := 3.0.0

all: pip

clean:
	rm -rf build/ dist/ *.egg-info/ __pycache__/ */__pycache__/

pip:
	python3 -m pip install --upgrade pip
	python3 setup.py sdist bdist_wheel

install:
	python3 -m pip install -e .

uninstall:
	python3 -m pip uninstall omnisec-ultimate -y

appimage:
	./build.sh

deb:
	./build.sh

run:
	python3 -m omnisec_desktop.main gui

run-cli:
	python3 -m omnisec_desktop.main

dev:
	python3 -m pip install -e .
	omnisec-gui
