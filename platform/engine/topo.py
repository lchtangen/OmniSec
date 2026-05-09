"""
Topology Engine — Network Topology Discovery
Discovers network topology, maps devices, and visualizes network structure.
Offline-only, local network scanning.
"""

import os
import json
import subprocess
import threading
import time
from pathlib import Path
from datetime import datetime


class TopologyEngine:
    """Network topology discovery and mapping engine."""

    def __init__(self, config_dir=None):
        self.config_dir = Path(config_dir or (Path.home() / ".omnisec" / "topo"))
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.topo_file = self.config_dir / "topology.json"
        self.topology = self._load_topology()
        self.scanning = False

    def _load_topology(self):
        """Load saved topology."""
        if self.topo_file.exists():
            try:
                return json.loads(self.topo_file.read_text())
            except Exception:
                pass
        return {"nodes": [], "edges": [], "last_scan": None}

    def _save_topology(self):
        """Save topology to disk."""
        self.topo_file.write_text(json.dumps(self.topology, indent=2))

    def _run_cmd(self, cmd):
        """Run a shell command and return output."""
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,
            )
            return result.stdout.strip()
        except Exception:
            return ""

    def discover_hosts(self, subnet="192.168.1.0/24"):
        """Discover active hosts via ping sweep and ARP."""
        hosts = []
        # Use nmap for host discovery
        output = self._run_cmd(f"nmap -sn {subnet}")
        for line in output.splitlines():
            if "Nmap scan report for" in line:
                ip = line.split("for ")[-1].strip("()")
                hosts.append({"ip": ip, "hostname": "", "status": "up"})
        # Enrich with ARP table
        arp_out = self._run_cmd("arp -a")
        arp_map = {}
        for line in arp_out.splitlines():
            parts = line.split()
            if len(parts) >= 2:
                ip = parts[1].strip("()")
                mac = parts[3] if len(parts) > 3 else ""
                arp_map[ip] = mac
        for h in hosts:
            h["mac"] = arp_map.get(h["ip"], "unknown")
        return hosts

    def scan_ports(self, target, ports="22,80,443,8080,3306,5432,27017"):
        """Scan ports on a target host."""
        open_ports = []
        output = self._run_cmd(f"nmap -p {ports} {target}")
        for line in output.splitlines():
            if "open" in line and "/" in line:
                port = line.split("/")[0].strip()
                service = line.split()[-1] if len(line.split()) > 2 else "unknown"
                open_ports.append({"port": port, "service": service, "state": "open"})
        return open_ports

    def get_local_info(self):
        """Get local machine network info."""
        info = {}
        # Get local IPs
        ip_out = self._run_cmd("ip -o -4 addr show")
        ips = []
        for line in ip_out.splitlines():
            if "inet " in line:
                ips.append(line.split("inet ")[1].split("/")[0])
        info["local_ips"] = ips
        # Get default gateway
        gw_out = self._run_cmd("ip route | grep default")
        if gw_out:
            info["gateway"] = gw_out.split()[2]
        # Get hostname
        info["hostname"] = self._run_cmd("hostname").strip()
        return info

    def run_full_scan(self, subnet="192.168.1.0/24", callback=None):
        """Run a full network topology scan in background."""
        self.scanning = True
        def scan():
            nodes = []
            edges = []
            # Add local node
            local = self.get_local_info()
            local_node = {
                "id": "local",
                "ip": local.get("local_ips", ["127.0.0.1"])[0],
                "hostname": local.get("hostname", "localhost"),
                "type": "local",
                "ports": [],
            }
            nodes.append(local_node)
            # Discover hosts
            hosts = self.discover_hosts(subnet)
            for i, host in enumerate(hosts):
                node_id = f"host_{i}"
                ports = self.scan_ports(host["ip"])
                node = {
                    "id": node_id,
                    "ip": host["ip"],
                    "hostname": host.get("hostname", host["ip"]),
                    "mac": host.get("mac", ""),
                    "type": "host",
                    "ports": ports,
                    "status": host.get("status", "unknown"),
                }
                nodes.append(node)
                edges.append({"source": "local", "target": node_id, "type": "network"})
                if callback:
                    callback(int((i + 1) / len(hosts) * 100), f"Scanned {host['ip']}")
            self.topology = {
                "nodes": nodes,
                "edges": edges,
                "last_scan": datetime.now().isoformat(),
                "subnet": subnet,
            }
            self._save_topology()
            self.scanning = False
            if callback:
                callback(100, "Scan complete")
        t = threading.Thread(target=scan, daemon=True)
        t.start()
        return t

    def get_topology(self):
        """Get current topology."""
        return self.topology

    def get_node(self, node_id):
        """Get a specific node by ID."""
        for n in self.topology["nodes"]:
            if n["id"] == node_id:
                return n
        return None

    def export_dot(self):
        """Export topology as Graphviz DOT format."""
        lines = ["graph NetworkTopology {", "  node [shape=box, style=filled];"]
        for n in self.topology["nodes"]:
            color = "orange" if n["type"] == "local" else "lightblue"
            lines.append(f'  "{n["id"]}" [label="{n["hostname"]}\n{n["ip"]}", fillcolor={color}];')
        for e in self.topology["edges"]:
            lines.append(f'  "{e["source"]}" -- "{e["target"]}";')
        lines.append("}")
        return "\n".join(lines)

    def get_status(self):
        """Get topology engine status."""
        return {
            "scanning": self.scanning,
            "nodes_count": len(self.topology["nodes"]),
            "edges_count": len(self.topology["edges"]),
            "last_scan": self.topology.get("last_scan"),
        }
