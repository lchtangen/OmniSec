# Website Structure for aegis-nexus.org
# Next.js + Tailwind CSS

## Project Structure
```
aegis-nexus.org/
├── app/
│   ├── layout.tsx           # Root layout with navigation
│   ├── page.tsx              # Homepage
│   ├── features/
│   │   └── page.tsx          # Features grid (10 phases)
│   ├── docs/
│   │   ├── layout.tsx
│   │   ├── page.tsx          # Documentation home
│   │   ├── installation/
│   │   │   └── page.tsx      # Installation guide
│   │   ├── ai-guide/
│   │   │   └── page.tsx      # AI agent guide
│   │   └── mesh-guide/
│   │       └── page.tsx      # Mesh networking guide
│   ├── downloads/
│   │   └── page.tsx          # Downloads (Android, Linux, macOS)
│   ├── community/
│   │   └── page.tsx          # Discord, GitHub, forums
│   └── api/
│       └── route.ts           # API endpoint for stats
├── components/
│   ├── Hero.tsx             # Homepage hero section
│   ├── FeaturesGrid.tsx      # 10-phase feature grid
│   ├── TerminalDemo.tsx     # Interactive terminal demo
│   ├── StatsBar.tsx         # Live stats (tests, tools, etc.)
│   ├── Platforms.tsx        # Platform support grid
│   └── Footer.tsx           # Footer with links
├── public/
│   ├── favicon.ico
│   ├── logo.png
│   └── demo-terminal.gif
├── styles/
│   └── globals.css          # Global styles (hacker theme)
├── package.json
├── tailwind.config.js
├── tsconfig.json
└── README.md
```

## Key Pages Content

### Homepage (`app/page.tsx`)
```tsx
export default function Home() {
  return (
    <main className="bg-black text-green-500 min-h-screen">
      <Hero />
      <section className="container mx-auto px-4 py-16">
        <h2 className="text-3xl font-bold mb-8">The Future of Mobile Security</h2>
        <FeaturesGrid />
      </section>
      <TerminalDemo />
      <StatsBar />
    </main>
  );
}
```

### Features Grid (`components/FeaturesGrid.tsx`)
```tsx
const phases = [
  { num: 1, name: "AI-Native Copilot", status: "complete", icon: "🤖" },
  { num: 2, name: "Mesh Networking", status: "complete", icon: "🕸" },
  { num: 3, name: "5G/LTE Security", status: "simulated", icon: "📡" },
  { num: 4, name: "eBPF Kernel Defense", status: "complete", icon: "🛡" },
  { num: 5, name: "Post-Quantum Crypto", status: "complete", icon: "🔮" },
  { num: 6, name: "HSM Ecosystem", status: "complete", icon: "🔑" },
  { num: 7, name: "Threat Intelligence", status: "complete", icon: "🕵" },
  { num: 8, name: "Cyber-Physical", status: "simulated", icon: "🚁" },
  { num: 9, name: "Immersive Interface", status: "simulated", icon: "🥽" },
  { num: 10, name: "Autonomous Ops", status: "complete", icon: "🤖" },
];
```

### Terminal Demo (`components/TerminalDemo.tsx`)
```tsx
// Interactive terminal that runs actual nhctl commands (via API)
export function TerminalDemo() {
  const [output, setOutput] = useState("");
  const [input, setInput] = useState("");

  const runCommand = async (cmd: string) => {
    const res = await fetch("/api/terminal", {
      method: "POST",
      body: JSON.stringify({ command: cmd }),
    });
    const data = await res.json();
    setOutput(data.output);
  };

  return (
    <div className="bg-black border border-green-500 p-4 rounded font-mono">
      <div className="text-green-400 mb-2">root@aegis-nexus:~#</div>
      <pre className="text-green-300">{output}</pre>
      <div className="flex items-center mt-2">
        <span className="text-green-400">$</span>
        <input
          className="bg-transparent border-none outline-none text-green-300 ml-2 flex-1"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === "Enter" && runCommand(input)}
        />
      </div>
    </div>
  );
}
```

## Package.json
```json
{
  "name": "aegis-nexus.org",
  "version": "3.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "tailwindcss": "^3.4.0"
  }
}
```

## Deploy to Vercel
```bash
vercel --prod --name aegis-nexus-org
```

## Environment Variables
```
NEXT_PUBLIC_GITHUB_REPO=https://github.com/AegisNexus/aegis-nexus
NEXT_PUBLIC_VERSION=3.0
NEXT_PUBLIC_TEST_COUNT=334
NEXT_PUBLIC_TOOL_COUNT=67
```
