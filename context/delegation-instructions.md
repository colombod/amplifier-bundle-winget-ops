# Winget Operations Delegation

## When to Delegate to winget-ops

**ALWAYS delegate winget and Windows package management operations to `winget-ops:winget-ops`.**

| Trigger | Example |
|---------|---------|
| Package search | "Find a package for...", "Search winget for..." |
| Package install | "Install Python", "Set up Node.js" |
| Package upgrade | "Update all packages", "Upgrade VS Code" |
| Package removal | "Uninstall...", "Remove..." |
| Package listing | "What's installed?", "Show installed packages" |
| System setup | "Set up a dev environment", "Install my tools" |
| Package info | "Show details for...", "What version of X is available?" |
| Export/import | "Export my packages", "Set up a new machine like this one" |

**Do NOT attempt winget commands directly via bash or pwsh.** The winget-ops agent has safety protocols, idempotency checks, and structured output formatting you lack.
