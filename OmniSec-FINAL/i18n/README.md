# OmniSec i18n — Internationalization Framework

## Supported Languages
| Code | Language | Status |
|------|----------|--------|
| en   | English  | ✅ Core |
| es   | Spanish  | 🔄 Community |
| fr   | French   | 🔄 Community |
| de   | German   | 🔄 Community |
| zh   | Chinese  | 🔄 Community |
| ja   | Japanese | 🔄 Community |
| ru   | Russian  | 🔄 Community |
| ar   | Arabic   | 🔄 Community |
| pt   | Portuguese| 🔄 Community |
| ko   | Korean   | 🔄 Community |
| it   | Italian  | 🔄 Community |
| hi   | Hindi    | 🔄 Community |

## How to Add a Translation
1. Create `i18n/translations/{code}.json`
2. Copy `i18n/template.json` structure
3. Translate all strings
4. Submit PR

## Implementation
```python
from i18n import LocaleLoader

loader = LocaleLoader("i18n/translations")
strings = loader.load("es")  # Returns dict with ES strings
print(strings["welcome"])    # "Bienvenido a OmniSec"
```
