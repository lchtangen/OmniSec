.PHONY: install run test lint clean build-all

install:
	pip install -r requirements.txt
	pip install -r requirements-dev.txt
	pre-commit install

run:
	python3 gui/omnisec-gui.py

test:
	python3 -m pytest tests/ -v --cov=.

lint:
	ruff check .
	black --check .
	mypy . --ignore-missing-imports

format:
	ruff check --fix .
	black .

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	rm -rf dist/ build/ *.egg-info

build-all:
	scripts/build-all.sh all

build-flatpak:
	scripts/build-all.sh flatpak

build-snap:
	scripts/build-all.sh snap

build-deb:
	scripts/build-all.sh deb

build-appimage:
	scripts/build-all.sh appimage

docker-build:
	docker build -t omnisec/ultimate:latest .

docker-run:
	docker-compose up

sbom:
	pip install cyclonedx-bom
	cyclonedx-py -e --output dist/omnisec-sbom.json

security-scan:
	pip-audit
	safety check
	ruff check .
	mypy . --ignore-missing-imports

release: clean test build-all sbom
	@echo "Release v$$(python3 -c 'import tomllib; print(tomllib.load(open("pyproject.toml","rb"))["project"]["version"])') ready!"
