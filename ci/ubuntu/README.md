# NetHunter Matrix - Ubuntu/Debian Package

## Quick Install

```bash
# Ubuntu/Debian
curl -fsSL https://nethunter-matrix.com/install.sh | bash -s ubuntu

# Or manual
sudo apt-get install -y bash git make gcc python3 openssl nmap curl wget tcpdump
git clone https://github.com/lchtangen/OmniSec.git
cd OmniSec
./install.sh
```

## Package Building

```bash
cd platforms/ubuntu
./build.sh deb
```

Creates: `nethunter-matrix_3.0.0.deb`
