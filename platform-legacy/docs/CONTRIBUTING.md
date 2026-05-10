# Contributing to OmniSec ULTIMATE

## Getting Started
1. Fork the repository
2. Clone your fork
3. Install dev dependencies: `pip install -r requirements-dev.txt`
4. Install pre-commit hooks: `pre-commit install`
5. Create a feature branch: `git checkout -b feature/amazing`

## Development Workflow
1. Make your changes
2. Run linters: `ruff check . && black .`
3. Run type checker: `mypy .`
4. Run tests: `python -m pytest tests/ -v`
5. Commit: `git commit -m "feat: add amazing feature"`
6. Push: `git push origin feature/amazing`
7. Open a Pull Request

## Code Standards
- Python 3.11+ typing annotations on all functions
- Docstrings for all public APIs
- 100 char line limit (black default)
- Cyberpunk 2077 UI theme (#0A0A0A background, neon colors)
- No hardcoded secrets or credentials
- 100% offline capability (no cloud dependencies)

## Module Development
```python
from modules import OmniSecModule

class MyModule(OmniSecModule):
    name = "My Tool"
    category = "Network"
    icon = "🛠️"
    version = "1.0.0"

    def get_widget(self):
        return QWidget()  # Your PyQt6 widget
```

## Commit Convention
We use conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `perf:` Performance
- `security:` Security fix
- `refactor:` Code restructuring

## Code of Conduct
See CODE_OF_CONDUCT.md. Be excellent to each other.
