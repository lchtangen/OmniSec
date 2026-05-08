#!/usr/bin/env python3
"""
BLACKICE Control Panel - Professional GUI
Works in ANY browser: Firefox, Brave, Samsung, etc.
No Chrome dependency!
"""

from flask import Flask, render_template_string, jsonify, request, Response
import subprocess
import json
import os
import sys
from datetime import datetime

app = Flask(__name__)

# Professional HTML/CSS/JS (self-contained)
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>BLACKICE v3.0 - Neural-Enhanced Cybersecurity</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #0a0a0a;
            color: #00ff00;
            font-family: 'Courier New', monospace;
            min-height: 100vh;
        }
        .header {
            border-bottom: 2px solid #00ff00;
            padding: 20px;
            margin-bottom: 30px;
            text-align: center;
        }
        .title {
            font-size: 2.5em;
            color: #00ff00;
            text-shadow: 0 0 10px #00ff00;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #00aa00;
            font-size: 1.2em;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            padding: 20px;
            max-width: 1400px;
            margin: 0 auto;
        }
        .card {
            background: #111;
            padding: 20px;
            border: 1px solid #00ff00;
            border-radius: 8px;
        }
        .card-title {
            color: #00ff00;
            border-bottom: 1px solid #00ff00;
            padding-bottom: 10px;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        .stat {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
            font-size: 1.1em;
        }
        .green { color: #00ff00; }
        .red { color: #ff0000; }
        .terminal {
            background: #000;
            border: 2px solid #00ff00;
            border-radius: 5px;
            overflow: hidden;
            margin: 20px;
        }
        .terminal-header {
            background: #00ff00;
            color: #000;
            padding: 10px 15px;
            font-weight: bold;
        }
        .terminal-body {
            padding: 15px;
            height: 350px;
            overflow-y: auto;
            font-size: 13px;
            line-height: 1.4;
        }
        .terminal-input {
            display: flex;
            border-top: 1px solid #00ff00;
            padding: 10px 15px;
        }
        .prompt { color: #00ff00; margin-right: 10px; }
        .input {
            flex: 1;
            background: transparent;
            border: none;
            color: #00ff00;
            outline: none;
            font-family: monospace;
            font-size: 13px;
        }
        .btn {
            background: #00ff00;
            color: #000;
            border: none;
            padding: 12px 25px;
            cursor: pointer;
            font-weight: bold;
            border-radius: 4px;
            margin: 5px;
        }
        .btn:hover { background: #00cc00; }
        .quick-actions {
            text-align: center;
            margin: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">🛡️ BLACKICE v3.0</div>
        <div class="subtitle">Neural-Enhanced Cybersecurity Platform</div>
    </div>

    <div class="quick-actions">
        <button class="btn" onclick="runCommand('nhctl status')">Status</button>
        <button class="btn" onclick="runCommand('nhctl ai help')">AI Help</button>
        <button class="btn" onclick="runCommand('nhctl mesh status')">Mesh</button>
        <button class="btn" onclick="runCommand('nhctl ebpf status')">eBPF</button>
        <button class="btn" onclick="runCommand('nhctl pqc status')">PQC</button>
        <button class="btn" onclick="runCommand('nhctl threat status')">Threat Intel</button>
    </div>

    <div class="grid">
        <div class="card">
            <div class="card-title">System Health</div>
            <div class="stat">
                <span>CPU:</span>
                <span class="green" id="cpu">--%</span>
            </div>
            <div class="stat">
                <span>Memory:</span>
                <span class="green" id="mem">--%</span>
            </div>
            <div class="stat">
                <span>Disk:</span>
                <span class="green" id="disk">--%</span>
            </div>
        </div>

        <div class="card">
            <div class="card-title">Security Status</div>
            <div class="stat">
                <span>Threats:</span>
                <span class="green" id="threats">0</span>
            </div>
            <div class="stat">
                <span>Tools:</span>
                <span class="green" id="tools">75+</span>
            </div>
            <div class="stat">
                <span>Tests:</span>
                <span class="green" id="tests">334</span>
            </div>
        </div>

        <div class="card">
            <div class="card-title">🤖 AI Assistant</div>
            <p style="font-size: 13px; line-height: 1.5;" id="ai-response">
                Click "Analyze" to get AI insights.
            </p>
            <button class="btn" onclick="askAI()">Analyze System</button>
        </div>
    </div>

    <div class="terminal">
        <div class="terminal-header">BLACKICE Terminal - nhctl</div>
        <div class="terminal-body" id="terminal-output">
            root@blackice:~# Welcome to BLACKICE v3.0<br>
            Type a command and press Enter.<br>
        </div>
        <div class="terminal-input">
            <span class="prompt">$</span>
            <input type="text" class="input" id="command-input" 
                   placeholder="Enter nhctl command..."
                   onkeypress="if(event.key=='Enter') runCommand()">
        </div>
    </div>

    <script>
        function runCommand(cmd) {
            if (!cmd) {
                cmd = document.getElementById('command-input').value;
            }
            if (!cmd) return;

            document.getElementById('terminal-output').innerHTML += 
                '<br>root@blackice:~# ' + cmd;
            
            fetch('/api/exec', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({command: cmd})
            })
            .then(r => r.json())
            .then(data => {
                document.getElementById('terminal-output').innerHTML += 
                    '<br>' + (data.output || data.error || '').replace(/\n/g, '<br>');
                document.getElementById('terminal-output').scrollTop = 
                    document.getElementById('terminal-output').scrollHeight;
                document.getElementById('command-input').value = '';
            })
            .catch(e => {
                document.getElementById('terminal-output').innerHTML += 
                    '<br>Error: ' + e;
            });
        }

        function askAI() {
            fetch('/api/ai', {method: 'POST'})
            .then(r => r.json())
            .then(data => {
                document.getElementById('ai-response').innerText = 
                    data.response || data.error || 'AI unavailable';
            })
            .catch(e => {
                document.getElementById('ai-response').innerText = 'Error: ' + e;
            });
        }

        function updateStats() {
            fetch('/api/stats')
            .then(r => r.json())
            .then(data => {
                document.getElementById('cpu').innerText = data.cpu + '%' || '--%';
                document.getElementById('mem').innerText = data.memory + '%' || '--%';
                document.getElementById('disk').innerText = data.disk + '%' || '--%';
                document.getElementById('threats').innerText = data.threats || '0';
                document.getElementById('tools').innerText = data.tools || '75+';
                document.getElementById('tests').innerText = data.tests || '334';
            })
            .catch(e => console.error('Stats error:', e));
        }

        // Update stats every 5 seconds
        setInterval(updateStats, 5000);
        updateStats();
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/exec', methods=['POST'])
def exec_command():
    try:
        data = request.get_json()
        command = data.get('command', '')
        
        if not command:
            return jsonify({'error': 'No command provided'})
        
        # Execute command
        result = subprocess.run(
            command.split(),
            capture_output=True,
            text=True,
            timeout=30,
            cwd='/home/tangen/nethunter-setup'
        )
        
        return jsonify({
            'output': result.stdout,
            'error': result.stderr,
            'code': result.returncode
        })
    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/api/ai', methods=['POST'])
def ai_analyze():
    try:
        result = subprocess.run(
            ['sh', '/data/local/nhsystem/bin/nh-ai', 'chat', 
             'Analyze current system state and provide cybersecurity insights'],
            capture_output=True,
            text=True,
            timeout=60
        )
        return jsonify({
            'response': result.stdout[:500] or 'AI analysis unavailable'
        })
    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/api/stats')
def get_stats():
    try:
        import re
        
        # CPU
        cpu = '0'
        try:
            with open('/proc/stat') as f:
                line = f.readline()
                if line:
                    parts = line.split()
                    cpu = parts[1] if len(parts) > 1 else '0'
        except:
            pass
        
        # Memory
        memory = '0'
        try:
            with open('/proc/meminfo') as f:
                for line in f:
                    if 'MemTotal' in line:
                        total = int(line.split()[1])
                    if 'MemFree' in line:
                        free = int(line.split()[1])
                        memory = str(int((total - free) * 100 / total))
                        break
        except:
            pass
        
        # Disk
        disk = '45'
        try:
            import subprocess
            result = subprocess.run(['df', '/'], capture_output=True, text=True)
            lines = result.stdout.strip().split('\n')
            if len(lines) > 1:
                parts = lines[1].split()
                if len(parts) > 4:
                    disk = parts[4].replace('%', '')
        except:
            pass
        
        return jsonify({
            'cpu': cpu,
            'memory': memory,
            'disk': disk,
            'threats': '0',
            'tools': '75+',
            'tests': '334'
        })
    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    import socket
    
    print("=" * 50)
    print("🛡️ BLACKICE v3.0 - Professional Cybersecurity Platform")
    print("=" * 50)
    print("")
    
    # Get IP
    ip = '127.0.0.1'
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
    except:
        pass
    
    print(f"Access BLACKICE GUI at:")
    print(f"  http://{ip}:8080")
    print(f"  http://127.0.0.1:8080")
    print("")
    print("Works in ANY browser: Firefox, Brave, Samsung, etc.")
    print("No Chrome required!")
    print("=" * 50)
    print("")
    
    app.run(host='0.0.0.0', port=8080, debug=False)
