# install.ps1 — install ai-agent-skills on Windows (PowerShell).
# Usage:
#   .\install.ps1                 install all skills into every agent dir found
#   .\install.ps1 -List           list skills, install nothing
#   .\install.ps1 -Skill software-engineering-orchestrator   install one skill only
#   .\install.ps1 -Skill nextjs-development   install the Next.js skill only
#   .\install.ps1 -Skill laravel-development   install the Laravel skill only
#   .\install.ps1 -Skill dotnet-development   install the .NET skill only
#   .\install.ps1 -DryRun         show what would happen, change nothing
#   .\install.ps1 -Dest <dir>     install into a custom skills directory
param(
  [switch]$List,
  [string]$Skill = "",
  [switch]$DryRun,
  [string]$Dest = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir = Join-Path $ScriptDir "skills"

function Get-Skills {
  Get-ChildItem -Directory $SrcDir | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
  } | ForEach-Object { $_.Name } | Sort-Object
}

if ($List) { Get-Skills; exit 0 }

$Skills = @()
if ($Skill -ne "") {
  if (-not (Test-Path (Join-Path $SrcDir $Skill "SKILL.md"))) {
    Write-Error "No skill named '$Skill'. Available: $((Get-Skills) -join ', ')"
    exit 1
  }
  $Skills = @($Skill)
} else {
  $Skills = @(Get-Skills)
}

if ($Skills.Count -eq 0) {
  Write-Error "No skills found in $SrcDir"
  exit 1
}

$Dests = @(
  (Join-Path $env:USERPROFILE ".claude\skills"),
  (Join-Path $env:USERPROFILE ".codex\skills"),
  (Join-Path $env:USERPROFILE ".cursor\skills"),
  (Join-Path $env:APPDATA "opencode\skills")
)

if ($Dest -ne "") { $Dests = @($Dest) }

$Installed = 0
foreach ($dest in $Dests) {
  if ($Dest -eq "" -and -not (Test-Path (Split-Path -Parent $dest))) { continue }
  foreach ($skill in $Skills) {
    $target = Join-Path $dest $skill
    if ($DryRun) {
      Write-Host "[dry-run] would copy skills\$skill -> $target"
    } else {
      New-Item -ItemType Directory -Force -Path $dest | Out-Null
      if (Test-Path $target) { Remove-Item -Recurse -Force $target }
      Copy-Item -Recurse (Join-Path $SrcDir $skill) $target
      Write-Host "Installed $skill -> $target"
    }
    $Installed++
  }
}

if ($DryRun) {
  Write-Host "Dry run: $Installed skill copies planned, nothing changed."
} elseif ($Installed -eq 0) {
  Write-Host "No agent skills directory found."
  Write-Host "Install Claude Code, Codex, Cursor or OpenCode first, or use -Dest <dir>:"
  Write-Host "  .\install.ps1 -Dest $env:USERPROFILE\.claude\skills"
  exit 1
} else {
  Write-Host "Done: $Installed skill copies installed."
  Write-Host "Restart your agent (or start a new session) and describe a task - it will load the matching skill."
}
