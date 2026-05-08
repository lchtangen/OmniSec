'use client'

import { useState } from 'react'
import Link from 'next/link'

export default function Home() {
  const [terminalOutput, setTerminalOutput] = useState('')
  const [input, setInput] = useState('')
  const [stats, setStats] = useState({
    tests: 334,
    tools: 75,
    platforms: 9,
    phases: 10
  })

  const runCommand = async (cmd: string) => {
    // Simulated terminal output
    const outputs: { [key: string]: string } = {
      'help': 'Aegis Nexus v3.0 — Next-Gen Mobile Security Platform\n\nCommands: ai, mesh, ebpf, pqc, hsm, threat, iot, drone...\nType "nhctl <command> help" for usage.',
      'status': '✅ Aegis Nexus v3.0\n✅ 334 tests passing\n✅ 75+ tools available\n✅ 10 phases complete\n✅ 9 platforms supported',
      'ai help': 'nhctl ai <command>\n  chat <msg>     Chat with AI\n  recon <target>  Autonomous recon\n  diagnose       AI diagnostic',
      'default': `root@aegis:~# ${cmd}\nCommand not found. Type "help" for available commands.`
    }
    
    setTerminalOutput(outputs[cmd] || outputs['default'])
  }

  return (
    <main style={styles.main}>
      {/* Hero Section */}
      <section style={styles.hero}>
        <div style={styles.heroContent}>
          <h1 style={styles.title}>🛡️ Aegis Nexus v3.0</h1>
          <p style={styles.subtitle}>
            The World's First AI-Native, Mesh-Enabled, Post-Quantum<br/>
            Mobile Security Platform
          </p>
          <div style={styles.ctaGroup}>
            <Link href="/downloads" style={styles.primaryBtn}>
              Download Now
            </Link>
            <Link href="https://github.com/AegisNexus" style={styles.secondaryBtn}>
              GitHub
            </Link>
          </div>
        </div>
      </section>

      {/* Stats Bar */}
      <section style={styles.statsBar}>
        <div style={styles.statItem}>
          <span style={styles.statNumber}>{stats.tests}</span>
          <span style={styles.statLabel}>Tests Passing</span>
        </div>
        <div style={styles.statItem}>
          <span style={styles.statNumber}>{stats.tools}+</span>
          <span style={styles.statLabel}>Premium Tools</span>
        </div>
        <div style={styles.statItem}>
          <span style={styles.statNumber}>{stats.phases}/10</span>
          <span style={styles.statLabel}>Phases Complete</span>
        </div>
        <div style={styles.statItem}>
          <span style={styles.statNumber}>{stats.platforms}</span>
          <span style={styles.statLabel}>Platforms</span>
        </div>
      </section>

      {/* Features Grid */}
      <section style={styles.featuresSection}>
        <h2 style={styles.sectionTitle}>Complete Feature Matrix</h2>
        <div style={styles.featuresGrid}>
          {features.map((f) => (
            <div key={f.phase} style={styles.featureCard}>
              <div style={styles.featureIcon}>{f.icon}</div>
              <h3 style={styles.featureName}>
                {f.name}
                <span style={f.status === 'complete' ? styles.complete : styles.simulated}>
                  {f.status}
                </span>
              </h3>
              <p style={styles.featureDesc}>{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Terminal Demo */}
      <section style={styles.terminalSection}>
        <h2 style={styles.sectionTitle}>Try It Live</h2>
        <div style={styles.terminal}>
          <div style={styles.terminalHeader}>
            <span style={styles.terminalTitle}>Aegis Terminal</span>
          </div>
          <div style={styles.terminalBody}>
            <pre style={styles.terminalOutput}>
              {terminalOutput || 'root@aegis:~# Type a command and press Enter\nTry: help, status, ai help'}
            </pre>
          </div>
          <div style={styles.terminalInput}>
            <span style={styles.prompt}>$</span>
            <input
              style={styles.input}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  runCommand(input)
                  setInput('')
                }
              }}
              placeholder="Enter command..."
            />
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer style={styles.footer}>
        <p>© 2026 Aegis Nexus — Built with 💚 for the security community</p>
        <div style={styles.footerLinks}>
          <Link href="/docs">Docs</Link>
          <Link href="https://github.com/AegisNexus">GitHub</Link>
          <Link href="https://discord.gg/aegis-nexus">Discord</Link>
        </div>
      </footer>
    </main>
  )
}

const features = [
  { phase: 1, name: 'AI-Native Copilot', icon: '🤖', status: 'complete', desc: 'On-device LLM, autonomous recon, natural language interface' },
  { phase: 2, name: 'Mesh Networking', icon: '🕸', status: 'complete', desc: 'Reticulum stack, LXMF messaging, Yggdrasil overlay' },
  { phase: 3, name: '5G/LTE Security', icon: '📡', status: 'simulated', desc: 'IMSI catcher detection, cellular analysis (WiFi-sim)' },
  { phase: 4, name: 'eBPF Kernel Defense', icon: '🛡', status: 'complete', desc: 'Real-time syscall monitoring, file integrity' },
  { phase: 5, name: 'Post-Quantum Crypto', icon: '🔮', status: 'complete', desc: 'ML-KEM, ML-DSA, quantum-resistant VPN' },
  { phase: 6, name: 'HSM Ecosystem', icon: '🔑', status: 'complete', desc: 'YubiKey, SoloKey, TEE integration' },
  { phase: 7, name: 'Threat Intelligence', icon: '🕵', status: 'complete', desc: 'IoC management, mesh sharing, MISP export' },
  { phase: 8, name: 'Cyber-Physical', icon: '🚁', status: 'simulated', desc: 'IoT testing, drone security (WiFi-based)' },
  { phase: 9, name: 'Immersive Interface', icon: '🥽', status: 'simulated', desc: 'Voice control, AR displays (simulated)' },
  { phase: 10, name: 'Autonomous Ops', icon: '🤖', status: 'complete', desc: 'Self-healing, predictive, swarm intelligence' },
]

const styles = {
  main: { backgroundColor: '#000', color: '#00ff00', minHeight: '100vh' },
  hero: { padding: '100px 20px', textAlign: 'center' as const },
  heroContent: { maxWidth: '1000px', margin: '0 auto' },
  title: { fontSize: '3em', marginBottom: '20px', textShadow: '0 0 10px #00ff00' },
  subtitle: { fontSize: '1.5em', color: '#00aa00', marginBottom: '40px', lineHeight: '1.5' },
  ctaGroup: { display: 'flex', gap: '20px', justifyContent: 'center' },
  primaryBtn: { padding: '15px 40px', backgroundColor: '#00ff00', color: '#000', fontWeight: 'bold' as const, textDecoration: 'none' },
  secondaryBtn: { padding: '15px 40px', border: '2px solid #00ff00', color: '#00ff00', textDecoration: 'none' },
  statsBar: { display: 'flex', justifyContent: 'space-around', padding: '40px 20px', backgroundColor: '#0a0a0a', borderTop: '1px solid #00ff00', borderBottom: '1px solid #00ff00' },
  statItem: { textAlign: 'center' as const },
  statNumber: { display: 'block', fontSize: '2em', fontWeight: 'bold' as const },
  statLabel: { fontSize: '0.9em', color: '#00aa00' },
  featuresSection: { padding: '60px 20px', maxWidth: '1200px', margin: '0 auto' },
  sectionTitle: { fontSize: '2em', textAlign: 'center' as const, marginBottom: '40px' },
  featuresGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' },
  featureCard: { border: '1px solid #00ff00', padding: '20px', backgroundColor: '#0a0a0a' },
  featureIcon: { fontSize: '2em', marginBottom: '10px' },
  featureName: { fontSize: '1.2em', marginBottom: '10px' },
  featureDesc: { fontSize: '0.9em', color: '#00aa00' },
  complete: { color: '#00ff00', fontSize: '0.8em', marginLeft: '10px' },
  simulated: { color: '#ffaa00', fontSize: '0.8em', marginLeft: '10px' },
  terminalSection: { padding: '60px 20px', maxWidth: '800px', margin: '0 auto' },
  terminal: { border: '2px solid #00ff00', borderRadius: '5px', overflow: 'hidden' },
  terminalHeader: { backgroundColor: '#00ff00', color: '#000', padding: '10px 15px', fontWeight: 'bold' as const },
  terminalTitle: { fontSize: '0.9em' },
  terminalBody: { padding: '15px', minHeight: '200px' },
  terminalOutput: { fontSize: '0.9em', whiteSpace: 'pre-wrap' as const },
  terminalInput: { display: 'flex', borderTop: '1px solid #00ff00', padding: '10px 15px', alignItems: 'center' as const },
  prompt: { color: '#00ff00', marginRight: '10px' },
  input: { flex: 1, backgroundColor: 'transparent', border: 'none', color: '#00ff00', outline: 'none', fontFamily: 'monospace' },
  footer: { padding: '40px 20px', textAlign: 'center' as const, borderTop: '1px solid #00ff00', marginTop: '60px' },
  footerLinks: { display: 'flex', gap: '20px', justifyContent: 'center', marginTop: '20px' },
}
