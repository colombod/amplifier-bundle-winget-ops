# Winget Operations Delegation

## When to Delegate to winget-ops

**ALWAYS delegate to `winget-ops:winget-ops` when the user wants to install, update, remove, or check software on Windows.** This applies even when the user does NOT mention "winget" or "package" — on Windows, winget is the standard way to install software.

### Immediate Delegation Triggers

Any of these phrases mean you MUST delegate to `winget-ops:winget-ops`:

| Trigger Pattern | Examples | Why |
|----------------|----------|-----|
| **"Install X"** | "Install Python", "Install VS Code", "Install Git" | Installing software = winget-ops |
| **"I need X"** | "I need Node.js", "I need a PDF viewer" | Implies installation is needed |
| **"Set up X"** | "Set up a Python dev environment", "Set up Docker" | Setting up tools = installing them |
| **"Get me X"** | "Get me the .NET SDK", "Get me Rust" | Casual install request |
| **"Add X"** | "Add PowerShell 7", "Add 7-Zip" | Implies installation |
| **"Update X" / "Upgrade X"** | "Update VS Code", "Upgrade all my tools" | Software updates = winget-ops |
| **"Remove X" / "Uninstall X"** | "Remove Docker", "Uninstall Chrome" | Software removal = winget-ops |
| **"Is X installed?"** | "Is Python installed?", "Do I have Git?" | Checking install status = winget-ops |
| **"What version of X?"** | "What version of Node do I have?" | Version queries = winget-ops |
| **"What needs updating?"** | "Any outdated software?", "What's out of date?" | Update checks = winget-ops |
| **"Search for X"** | "Is there a package for X?", "Find a terminal emulator" | Software discovery = winget-ops |
| **"Export/import packages"** | "Export my setup", "Set up a new machine like this" | Machine setup = winget-ops |

### What NOT to do

**Do NOT run winget, choco, or installer commands directly via pwsh or bash.** The winget-ops agent has:
- Safety protocols (won't uninstall system-critical packages)
- Idempotency checks (verifies before and after)
- Structured output (reports package IDs, versions, status)
- Correct flags (`--accept-source-agreements`, `--disable-interactivity`)

### Edge cases

| Situation | Action |
|-----------|--------|
| User says "install" but means a Python/npm/NuGet package | NOT winget-ops — that's pip/npm/dotnet-ops territory |
| User says "install" and means a Windows application or runtime | YES winget-ops |
| User says "install Python" (the runtime itself) | YES winget-ops |
| User says "pip install requests" (a Python library) | NOT winget-ops — use pwsh directly |
