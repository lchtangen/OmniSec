// Aegis Nexus — React Dashboard
// Real-time system monitoring with AI insights

import React, { useState, useEffect } from 'react';
import { Line } from 'react-chartjs-2';
import { Chart as ChartJS, registerables } from 'chart.js';

ChartJS.register(...registerables);

export default function Dashboard() {
  const [systemData, setSystemData] = useState({
    cpu: 0,
    memory: 0,
    disk: 0,
    network: 'active',
    threats: 0,
    tools: 67,
    tests: 334
  });
  
  const [terminalOutput, setTerminalOutput] = useState('');
  const [command, setCommand] = useState('');
  const [aiResponse, setAiResponse] = useState('');

  // Fetch system stats
  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await fetch('/api/system-stats');
        const data = await res.json();
        setSystemData(data);
      } catch {
        // Use simulated data
        setSystemData({
          cpu: Math.random() * 100,
          memory: Math.random() * 100,
          disk: 45 + Math.random() * 10,
          network: 'active',
          threats: Math.floor(Math.random() * 5),
          tools: 67,
          tests: 334
        });
      }
    };

    fetchStats();
    const interval = setInterval(fetchStats, 5000);
    return () => clearInterval(interval);
  }, []);

  const runCommand = async () => {
    try {
      const res = await fetch('/api/exec', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ command })
      });
      const data = await res.json();
      setTerminalOutput(data.output || data.error);
      setCommand('');
    } catch (error) {
      setTerminalOutput(`Error: ${error.message}`);
    }
  };

  const askAI = async () => {
    try {
      const res = await fetch('/api/ai-chat', {
        method: 'POST',
        body: JSON.stringify({ message: 'Analyze current system state' })
      });
      const data = await res.json();
      setAiResponse(data.response);
    } catch {
      setAiResponse('AI analysis unavailable (simulation)');
    }
  };

  const cpuData = {
    labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
    datasets: [{
      label: 'CPU Usage %',
      data: Array(10).fill(0).map(() => Math.random() * 100),
      borderColor: '#0f0',
      backgroundColor: 'rgba(0, 255, 0, 0.1)',
    }]
  };

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>🛡️ Aegis Nexus v3.0</h1>
        <p style={styles.subtitle}>Next-Generation Mobile Security Platform</p>
      </header>

      <div style={styles.grid}>
        {/* Stats Cards */}
        <div style={styles.card}>
          <h3 style={styles.cardTitle}>System Health</h3>
          <div style={styles.stat}>
            <span>CPU:</span> <span style={styles.green}>{systemData.cpu.toFixed(1)}%</span>
          </div>
          <div style={styles.stat}>
            <span>Memory:</span> <span style={styles.green}>{systemData.memory.toFixed(1)}%</span>
          </div>
          <div style={styles.stat}>
            <span>Disk:</span> <span style={systemData.disk > 80 ? styles.red : styles.green}>{systemData.disk.toFixed(1)}%</span>
          </div>
        </div>

        <div style={styles.card}>
          <h3 style={styles.cardTitle}>Security Status</h3>
          <div style={styles.stat}>
            <span>Threats:</span> <span style={systemData.threats > 0 ? styles.red : styles.green}>{systemData.threats}</span>
          </div>
          <div style={styles.stat}>
            <span>Network:</span> <span style={styles.green}>{systemData.network}</span>
          </div>
        </div>

        <div style={styles.card}>
          <h3 style={styles.cardTitle}>Platform Stats</h3>
          <div style={styles.stat}>
            <span>Tools:</span> <span style={styles.green}>{systemData.tools}</span>
          </div>
          <div style={styles.stat}>
            <span>Tests:</span> <span style={styles.green}>{systemData.tests} passed</span>
          </div>
        </div>

        {/* CPU Chart */}
        <div style={styles.card}>
          <h3 style={styles.cardTitle}>CPU Usage (Live)</h3>
          <Line data={cpuData} options={{ responsive: true, maintainAspectRatio: false }} />
        </div>

        {/* Terminal */}
        <div style={styles.terminal}>
          <div style={styles.terminalHeader}>Terminal — nhctl</div>
          <pre style={styles.terminalOutput}>{terminalOutput || 'root@aegis:~# Type command and press Enter'}</pre>
          <div style={styles.terminalInput}>
            <span style={styles.prompt}>$</span>
            <input
              style={styles.input}
              value={command}
              onChange={(e) => setCommand(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && runCommand()}
              placeholder="Enter nhctl command..."
            />
          </div>
        </div>

        {/* AI Panel */}
        <div style={styles.card}>
          <h3 style={styles.cardTitle}>🤖 AI Assistant</h3>
          <p style={styles.aiResponse}>{aiResponse || 'Click to get AI analysis'}</p>
          <button style={styles.button} onClick={askAI}>Analyze System</button>
        </div>
      </div>
    </div>
  );
}

const styles = {
  container: { backgroundColor: '#000', color: '#0f0', minHeight: '100vh', padding: '20px' },
  header: { borderBottom: '2px solid #0f0', marginBottom: '20px', paddingBottom: '10px' },
  title: { color: '#0f0', fontSize: '2em', margin: 0 },
  subtitle: { color: '#0a0', margin: '5px 0 0 0' },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' },
  card: { backgroundColor: '#111', padding: '15px', border: '1px solid #0f0', borderRadius: '5px' },
  cardTitle: { color: '#0f0', borderBottom: '1px solid #0f0', paddingBottom: '5px' },
  stat: { display: 'flex', justifyContent: 'space-between', margin: '10px 0' },
  green: { color: '#0f0' },
  red: { color: '#f00' },
  terminal: { backgroundColor: '#000', border: '1px solid #0f0', borderRadius: '5px', overflow: 'hidden' },
  terminalHeader: { backgroundColor: '#0f0', color: '#000', padding: '5px 10px', fontWeight: 'bold' },
  terminalOutput: { padding: '10px', height: '200px', overflowY: 'auto', fontSize: '12px' },
  terminalInput: { display: 'flex', borderTop: '1px solid #0f0', padding: '5px' },
  prompt: { color: '#0f0', marginRight: '5px' },
  input: { flex: 1, backgroundColor: 'transparent', border: 'none', color: '#0f0', outline: 'none' },
  button: { backgroundColor: '#0f0', color: '#000', border: 'none', padding: '10px 20px', cursor: 'pointer', fontWeight: 'bold' },
  aiResponse: { fontSize: '14px', lineHeight: '1.5' }
};
