---
bundle:
  name: winget-ops
  version: 1.0.0
  description: >-
    Windows Package Manager (winget) operations bundle.
    Provides a specialist agent for package search, install, upgrade,
    and system management via winget on Windows.

includes:
  - bundle: winget-ops:behaviors/winget-ops
---

# Winget Operations Bundle

Provides `winget-ops` — a specialist agent for Windows Package Manager operations.

## Usage

Delegate winget operations:
```
delegate(agent="winget-ops:winget-ops", instruction="Install Python 3.12 via winget")
delegate(agent="winget-ops:winget-ops", instruction="Search for Node.js packages")
delegate(agent="winget-ops:winget-ops", instruction="Upgrade all outdated packages")
```

