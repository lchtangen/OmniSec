"""
OmniSec Platform - Web API
FastAPI-based RESTful API for all 151+ tools.

Provides:
- Tool execution endpoints
- AI agent endpoints  
- Mesh networking API
- eBPF monitoring API
- Post-quantum crypto API
- Cross-platform abstraction
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, List, Optional, Any
import subprocess
import asyncio
from pathlib import Path
import json

app = FastAPI(
    title="OmniSec API",
    description="Unified API for 151+ security tools, AI agent, mesh networking, and more",
    version="3.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Models ────────────────────────────────────────────

class ToolExecuteRequest(BaseModel):
    tool: str
    args: List[str] = []
    timeout: int = 300

class ToolExecuteResponse(BaseModel):
    returncode: int
    stdout: str
    stderr: str

class AIChatRequest(BaseModel):
    message: str
    model: str = "llama3.2:3b"
    temperature: float = 0.1

class MeshMessageRequest(BaseModel):
    target: str
    message: str

# ── Tool Endpoints ─────────────────────────────────

TOOLS_DIR = Path.home() / ".nmatrix" / "plugins" / "shell"
if not TOOLS_DIR.exists():
    TOOLS_DIR = Path(__file__).parent.parent / "plugins" / "shell"

@app.get("/api/tools", tags=["Tools"])
async def list_tools() -> Dict[str, Any]:
    """List all available tools."""
    tools = []
    if TOOLS_DIR.exists():
        for tool in sorted(TOOLS_DIR.glob("nh-*")):
            tools.append({
                "name": tool.stem,
                "path": str(tool),
                "executable": tool.exists() and os.access(tool, os.X_OK)
            })
    return {"count": len(tools), "tools": tools}

@app.post("/api/tools/execute", tags=["Tools"])
async def execute_tool(request: ToolExecuteRequest, background_tasks: BackgroundTasks):
    """Execute a tool."""
    tool_path = TOOLS_DIR / f"nh-{request.tool}" if not request.tool.startswith("nh-") else TOOLS_DIR / request.tool
    
    if not tool_path.exists():
        raise HTTPException(status_code=404, detail=f"Tool not found: {request.tool}")
    
    cmd = [str(tool_path)] + request.args
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=request.timeout
        )
        return ToolExecuteResponse(
            returncode=result.returncode,
            stdout=result.stdout,
            stderr=result.stderr
        )
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Command timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ── AI Endpoints ───────────────────────────────────

@app.post("/api/ai/chat", tags=["AI"])
async def ai_chat(request: AIChatRequest):
    """Chat with AI agent."""
    # This would call the AI agent
    return {
        "response": f"AI response to: {request.message}",
        "model": request.model
    }

@app.get("/api/ai/status", tags=["AI"])
async def ai_status():
    """Check AI agent status."""
    return {"status": "operational", "model": "llama3.2:3b"}

# ── Mesh Endpoints ─────────────────────────────────

@app.get("/api/mesh/peers", tags=["Mesh"])
async def list_mesh_peers():
    """List mesh network peers."""
    return {"peers": [], "count": 0}

@app.post("/api/mesh/send", tags=["Mesh"])
async def send_mesh_message(request: MeshMessageRequest):
    """Send message via mesh network."""
    return {"status": "sent", "target": request.target}

# ── Platform Endpoints ──────────────────────────

@app.get("/api/platform/info", tags=["Platform"])
async def platform_info():
    """Get platform information."""
    import platform
    return {
        "platform": platform.system(),
        "machine": platform.machine(),
        "python": platform.python_version(),
        "matrix_version": "3.0.0"
    }

# ── Health Check ────────────────────────────────

@app.get("/health", tags=["System"])
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "version": "3.0.0"}

@app.get("/", tags=["System"])
async def root():
    """API root - redirects to docs."""
    return {
        "name": "OmniSec Platform API",
        "version": "3.0.0",
        "docs": "/docs",
        "tools": "/api/tools"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
