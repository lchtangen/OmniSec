#!/usr/bin/env python3
"""
nh-web-console — Web-based Management Console
Provides REST API and WebSocket for real-time device management
"""
import http.server
import socketserver
import json
import subprocess
import threading
import os
from urllib.parse import urlparse, parse_qs

PORT = 8080
NH_ROOT = "/data/local/nhsystem"

class ConsoleHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        
        if parsed.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(WEB_UI.encode())
            
        elif parsed.path == "/api/status":
            self.send_json({
                "status": "running",
                "tools": len([f for f in os.listdir("/data/local/nhsystem/bin") if f.startswith("nh-")]),
                "version": "3.0 nextgen"
            })
            
        elif parsed.path == "/api/tools":
            tools = []
            for f in sorted(os.listdir("/data/local/nhsystem/bin")):
                if f.startswith("nh-") and os.access(f"/data/local/nhsystem/bin/{f}", os.X_OK):
                    tools.append({"name": f, "path": f"/data/local/nhsystem/bin/{f}"})
            self.send_json({"tools": tools})
            
        elif parsed.path == "/api/exec":
            params = parse_qs(parsed.query)
            cmd = params.get("cmd", [""])[0]
            if cmd:
                try:
                    result = subprocess.run(cmd.split(), capture_output=True, text=True, timeout=30)
                    self.send_json({"output": result.stdout, "error": result.stderr, "code": result.returncode})
                except Exception as e:
                    self.send_json({"error": str(e)})
            else:
                self.send_json({"error": "No command provided"})
        else:
            self.send_error(404)
    
    def send_json(self, data):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def log_message(self, format, *args):
        pass  # Suppress logs

WEB_UI = """
<!DOCTYPE html>
<html>
<head>
    <title>NetHunter Console</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: monospace; background: #000; color: #0f0; margin: 0; padding: 20px; }
        h1 { color: #0f0; border-bottom: 1px solid #0f0; }
        .tool { background: #111; padding: 10px; margin: 5px; border: 1px solid #0f0; cursor: pointer; }
        .tool:hover { background: #222; }
        #output { background: #111; padding: 10px; margin-top: 20px; height: 300px; overflow-y: scroll; }
    </style>
</head>
<body>
    <h1>⚡ NetHunter Setup v3.0 — Web Console</h1>
    <div id="tools"></div>
    <div id="output"></div>
    
    <script>
        fetch('/api/tools').then(r => r.json()).then(data => {
            let html = '<h2>Tools (' + data.tools.length + ')</h2>';
            data.tools.forEach(t => {
                html += '<div class="tool" onclick="runTool(\"' + t.name + '\")">' + t.name + '</div>';
            });
            document.getElementById('tools').innerHTML = html;
        });
        
        function runTool(name) {
            document.getElementById('output').innerHTML += '<p>$ ' + name + '</p>';
            fetch('/api/exec?cmd=' + encodeURIComponent('nh-' + name + ' help')).then(r => r.json()).then(data => {
                if (data.output) document.getElementById('output').innerHTML += '<pre>' + data.output + '</pre>';
                if (data.error) document.getElementById('output').innerHTML += '<pre style="color:#f00">' + data.error + '</pre>';
            });
        }
    </script>
</body>
</html>
"""

if __name__ == "__main__":
    with socketserver.TCPServer(("0.0.0.0", PORT), ConsoleHandler) as httpd:
        print(f"Console running at http://0.0.0.0:{PORT}")
        httpd.serve_forever()
