# Winget Operations Delegation

**On Windows, delegate all software install/upgrade/uninstall/query work to
`winget-ops:winget-ops`.** This holds even when the user never says "winget" or "package" —
on Windows, winget is the standard way to install software.

The agent's own description carries the full trigger list and examples (it is the single
source of truth for *when* to delegate). This file only adds the routing boundary that the
description does not: **what is NOT winget-ops.**

## Routing boundary — winget-ops vs. language package managers

| Situation | Route to |
|-----------|----------|
| Install a Windows application, runtime, SDK, tool, or editor (e.g. "install Python", "I need Node.js", "set up VS Code") | **`winget-ops:winget-ops`** |
| Update / uninstall / check / search installed Windows software | **`winget-ops:winget-ops`** |
| Export/import a package list for machine setup | **`winget-ops:winget-ops`** |
| A **language** package — `pip install requests`, `npm install`, `dotnet add package`, a NuGet ref | **NOT winget-ops** — use the relevant language tool (pip/npm/dotnet-ops) or the shell directly |

## Windows-only

`winget-ops` targets **Windows** — `winget` exists only there. Only delegate winget work when
the host is Windows. On a non-Windows host the agent will run a preflight (`winget --version`)
and **fail loud** rather than substitute `apt`/`brew`/`choco` — that refusal is correct, not a
bug to route around.

## Do not run installers directly

Do not run `winget`, `choco`, or installer commands yourself. The `winget-ops` agent owns the
safety protocols, idempotency checks, correct non-interactive flags, and structured output — and
it carries its own `bash` + `filesystem` tools, so those never need to be present in this session.
