# OmniSec ULTIMATE — Flatpak Distribution

## Flathub Publishing

### Prerequisites
- Flatpak SDK installed
- Flathub account for publishing
- App ID: `io.omnisec.OmniSec`

### Build Locally
```bash
./store/flatpak/build-flatpak.sh
```

### Install Built Bundle
```bash
flatpak install --user ./dist/omnisec-ultimate-3.0.0.flatpak
flatpak run io.omnisec.OmniSec
```

### Submit to Flathub
1. Fork https://github.com/flathub/flathub
2. Create `io.omnisec.OmniSec.yml` in root
3. Copy content from `store/flatpak/io.omnisec.OmniSec.yml`
4. Submit PR to flathub

### Flathub Review Checklist
- [ ] AppData XML validates (`appstreamcli validate`)
- [ ] Desktop file validates (`desktop-file-validate`)
- [ ] No bundled libraries (use Flatpak SDK)
- [ ] All network access justified (--share=network)
- [ ] No proprietary dependencies
- [ ] Icon is 256x256 or scalable SVG

### Update Process
```bash
# Update version in manifest
./store/flatpak/build-flatpak.sh
# Test locally, then submit updated YAML to flathub
```

## Sandbox Permissions
| Permission | Reason |
|------------|--------|
| `--share=ipc` | X11 shared memory |
| `--socket=x11` | GUI display |
| `--socket=wayland` | Modern display server |
| `--device=dri` | GPU acceleration for AI |
| `--share=network` | Network scanning tools |
| `--filesystem=home` | Access scan results |
| `--filesystem=/media` | USB devices |
| `--filesystem=/mnt` | Mounted drives |
