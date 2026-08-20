# amplifier-bundle-winget-ops

Windows Package Manager (winget) specialist agent for [Amplifier](https://github.com/microsoft/amplifier). Search, install, upgrade, and manage packages on Windows through a dedicated agent with safety protocols and structured output.

## Installation

### As an app bundle (recommended)

```bash
amplifier bundle add git+https://github.com/colombod/amplifier-bundle-winget-ops@main --app
```

### As a composable behavior (add to existing bundle)

```bash
amplifier bundle add git+https://github.com/colombod/amplifier-bundle-winget-ops@main#subdirectory=behaviors/winget-ops.yaml --app
```

### In a custom bundle

```yaml
includes:
  - bundle: git+https://github.com/microsoft/amplifier-foundation@main
  - bundle: git+https://github.com/colombod/amplifier-bundle-winget-ops@main#subdirectory=behaviors/winget-ops.yaml
```

## Prerequisites

- **Windows 10/11** with [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) installed (comes with App Installer from the Microsoft Store). winget is **Windows-only** — this bundle does nothing on Linux/macOS and the agent will refuse (fail loud) there.
- **[Git for Windows](https://gitforwindows.org)** — provides the `bash` that the agent's shell tool (`tool-bash`) resolves to on Windows. (No PowerShell module is required; the agent calls the `winget` CLI directly and is shell-agnostic.)
- **Amplifier** — `uv tool install git+https://github.com/microsoft/amplifier`

## What It Does

The `winget-ops` agent handles all Windows package management via delegation. Instead of running winget commands yourself, delegate to the agent — it has safety protocols, idempotency checks, and structured output.

### Capabilities

| Operation | Example prompt |
|-----------|---------------|
| Search packages | "Search winget for Python" |
| Install packages | "Install VS Code and Git" |
| Upgrade packages | "Update all outdated packages" |
| Remove packages | "Uninstall Docker Desktop" |
| List installed | "What packages do I have installed?" |
| Check updates | "What packages need updating?" |
| Package details | "Show me details for Node.js LTS" |
| Export/import | "Export my packages for a new machine" |
| System setup | "Set up a dev environment with Python, Node, Git, and VS Code" |

### How It Works

```
User: "Install Python 3.12"
  |
  v
Orchestrator sees winget trigger --> delegates to winget-ops agent
  |
  v
winget-ops agent (fast model, shell-agnostic — calls the winget CLI directly):
  0. Preflight: winget --version  (if winget is absent, STOP — Windows-only, fail loud)
  1. Searches for package: winget search --id Python.Python.3.12
  2. Installs: winget install --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
  3. Verifies: winget list --id Python.Python.3.12
  4. Returns structured result with package ID, version, and status
```

## Safety

The agent enforces safety protocols:

- Uses `--id` for precise package matching (avoids ambiguous installs)
- Uses `--accept-source-agreements` and `--accept-package-agreements` for non-interactive operation
- Uses `--disable-interactivity` to prevent installer UI popups
- Will NOT uninstall system-critical packages without explicit confirmation
- Will NOT add untrusted package sources
- Will NOT use `--force` without confirming with you

## Bundle Structure

```
amplifier-bundle-winget-ops/
├── bundle.md                        # Root bundle — just composes the behavior
├── agents/
│   └── winget-ops.md                # Specialist agent (model_role: fast) — carries its OWN bash + filesystem tools
├── behaviors/
│   └── winget-ops.yaml              # Composable behavior — ships the agent + delegation context
└── context/
    └── delegation-instructions.md   # Thin routing boundary for orchestrators
```

**Single source of truth.** The behavior (`behaviors/winget-ops.yaml`) declares the agent and
the delegation context; the root (`bundle.md`) only `includes:` the behavior. So a full-bundle
install and a behavior-only install register **identical** capability.

**Tools stay with the agent.** `tool-bash` and `tool-filesystem` are declared in the agent's
own frontmatter, so they mount **only inside the `winget-ops` sub-session** when it is spawned —
they are never added to your main session's toolset.

## Common Package IDs

Quick reference for frequently installed packages:

| Package | winget ID |
|---------|-----------|
| Python 3.12 | `Python.Python.3.12` |
| Node.js LTS | `OpenJS.NodeJS.LTS` |
| Git | `Git.Git` |
| VS Code | `Microsoft.VisualStudioCode` |
| .NET SDK 8 | `Microsoft.DotNet.SDK.8` |
| PowerShell 7 | `Microsoft.PowerShell` |
| Docker Desktop | `Docker.DockerDesktop` |
| Windows Terminal | `Microsoft.WindowsTerminal` |
| Rust | `Rustlang.Rustup` |
| Go | `GoLang.Go` |

## Related Bundles

| Bundle | Purpose | Install |
|--------|---------|---------|
| [tool-bash](https://github.com/microsoft/amplifier-module-tool-bash) | Shell tool module (dependency) — resolves to Git-for-Windows bash on Windows | Mounted automatically, inside the winget-ops agent only |
| [dotnet-ops](https://github.com/colombod/amplifier-bundle-dotnet-ops) | .NET CLI agent (cross-platform) | `amplifier bundle add git+https://github.com/colombod/amplifier-bundle-dotnet-ops@main --app` |

## License

MIT
