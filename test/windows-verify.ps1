# test/windows-verify.ps1
# winget-ops behaviour contract - the Windows-side checks this bundle depends on.
#
# Runs in a REAL user session on Windows. Two ways to run it:
#   * Local DTU:  wdtu run test/windows-verify.ps1     (windows-dtu-harness)
#   * CI:         run it directly on a GitHub Actions `windows-latest` runner
#
# It exercises exactly the winget operations the winget-ops agent performs:
# preflight, then a real install -> list -> uninstall lifecycle. Exit 0 = pass.
#
# ASCII-only on purpose: PowerShell 5.1 reads a BOM-less .ps1 as ANSI, so a
# stray non-ASCII character (em dash, smart quote) becomes a parser error.
#
# NOTE: this validates the winget MECHANICS the agent relies on. The agent's
# Windows-only guard and no-substitution refusal are prompt/behaviour properties
# (covered by the agent instructions + claim-guard), not by this script.

$ErrorActionPreference = 'Stop'
$pkg = '7zip.7zip'          # small, well-known, fast to install/remove
$fails = 0

function Section($t) { Write-Host "`n== $t ==" }
function Pass($t)    { Write-Host "PASS: $t" }
function Fail($t)    { Write-Host "FAIL: $t"; $script:fails++ }

# winget accepts different flags per verb. Only 'install' takes
# --accept-package-agreements; passing it to list/uninstall makes winget reject
# the arguments and print help. Keep the flag sets separate.
$src     = '--accept-source-agreements'
$instOpt = @($src, '--accept-package-agreements', '--disable-interactivity', '--silent')
$unOpt   = @($src, '--disable-interactivity', '--silent')

# ---- 0. Preflight: winget must exist in this session -----------------------
Section 'preflight'
$wg = Get-Command winget -ErrorAction SilentlyContinue
if (-not $wg) {
    Fail 'winget not found on PATH. On Windows it lives in a per-user execution alias; a SYSTEM/service context (e.g. incus exec) cannot see it. Run in a user session.'
    Write-Host "`nRESULT: FAIL - preflight"; exit 1
}
Pass ("winget present: " + (winget --version))

# ---- 1. Clean slate: ensure the package is not already installed -----------
Section "ensure $pkg absent to start"
winget list --id $pkg --exact $src *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "$pkg already installed; removing first"
    winget uninstall --id $pkg --exact @unOpt *> $null
}

# ---- 2. Install ------------------------------------------------------------
Section "install $pkg"
winget install --id $pkg --exact @instOpt
if ($LASTEXITCODE -eq 0) { Pass "install exit 0" } else { Fail "install exit $LASTEXITCODE" }

# ---- 3. Verify present -----------------------------------------------------
Section "list $pkg (expect present)"
winget list --id $pkg --exact $src
if ($LASTEXITCODE -eq 0) { Pass "$pkg is listed as installed" } else { Fail "$pkg not listed after install" }

# ---- 4. Uninstall ----------------------------------------------------------
Section "uninstall $pkg"
winget uninstall --id $pkg --exact @unOpt
if ($LASTEXITCODE -eq 0) { Pass "uninstall exit 0" } else { Fail "uninstall exit $LASTEXITCODE" }

# ---- 5. Verify absent ------------------------------------------------------
Section "list $pkg (expect absent)"
winget list --id $pkg --exact $src *> $null
if ($LASTEXITCODE -ne 0) { Pass "$pkg no longer installed" } else { Fail "$pkg still present after uninstall" }

# ---- Result ----------------------------------------------------------------
Write-Host "`n============================"
if ($fails -eq 0) { Write-Host "RESULT: PASS - winget install/list/uninstall lifecycle works"; exit 0 }
else              { Write-Host ("RESULT: FAIL - {0} check(s) failed" -f $fails); exit 1 }
