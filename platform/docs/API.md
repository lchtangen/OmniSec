# OmniSec ULTIMATE — API Documentation

## Module API
```python
from gui.modules import discover_modules, get_module

# List all available modules
modules = discover_modules()

# Get specific module by name
module = get_module("network_scanner")

# Get module info
print(module.name)
print(module.category)
print(module.version)

# Get GUI widget
widget = module.get_widget()
```

## CLI API
```bash
# Launch GUI
omnisec gui

# Run CLI tool
omnisec scan 192.168.1.0/24

# List modules
omnisec modules list

# Show module info
omnisec modules info network_scanner
```

## Security API
```python
from security.permissions import PermissionManager
pm = PermissionManager()
pm.check_permission("nmap", Permission.NETWORK_SCAN)
pm.grant_permission("nmap", Permission.NETWORK_SCAN)

from security.sandbox import run_sandboxed
result = run_sandboxed(["nmap", "-sn", "192.168.1.0/24"])
```

## i18n API
```python
from i18n import LocaleLoader
ll = LocaleLoader()
strings = ll.load("es")
print(ll.get("app.name", "es"))
```
