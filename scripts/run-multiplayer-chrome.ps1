# Run backend + Flutter web + 1-4 isolated Chrome windows for multiplayer testing.
# Each profile has its own local storage (separate players on one machine).
#
# Usage (from repo root):
#   .\scripts\run-multiplayer-chrome.ps1              # 2 players (default)
#   .\scripts\run-multiplayer-chrome.ps1 -Players 4
#   .\scripts\run-multiplayer-chrome.ps1 -Players 1   # solo smoke test
#   .\scripts\run-multiplayer-chrome.ps1 -RoomCode ABC123   # players 2+ open ?room=CODE
#   .\scripts\run-multiplayer-chrome.ps1 -ChromeOnly -RoomCode ABC123 -Players 3
#   .\scripts\run-multiplayer-chrome.ps1 -KeepStorage   # keep cache (not recommended)
#   .\scripts\run-multiplayer-chrome.ps1 -ResetProfiles  # wipe profiles + session
#
# Params:
#   -Players (1-4)     How many Chrome windows to open
#   -RoomCode          Prefill join URL for windows 2..N (host still uses plain URL)
#   -ChromeOnly        Skip starting backend / Flutter (reuse running servers)
#   -SkipBackend       Do not start npm run dev
#   -SkipFlutter       Do not start flutter run
#   -KeepStorage       Skip cache clear (profiles may show stale Flutter build)
#   -ResetProfiles     Delete entire .chrome-profiles/player* (sessions + cache)
#   -AppUrl            Default http://localhost:8080
#   -ApiUrl            Default http://localhost:3000

param(
  [ValidateRange(1, 4)]
  [int] $Players = 2,
  [string] $RoomCode = "",
  [switch] $ChromeOnly,
  [switch] $SkipBackend,
  [switch] $SkipFlutter,
  [switch] $KeepStorage,
  [switch] $ResetProfiles,
  [string] $AppUrl = "http://localhost:8080",
  [string] $ApiUrl = "http://localhost:3000"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Front = Join-Path $RepoRoot "front"
$Back = Join-Path $RepoRoot "back"
$ProfileRoot = Join-Path $RepoRoot ".chrome-profiles"

function Find-Chrome {
  if ($env:CHROME_PATH -and (Test-Path $env:CHROME_PATH)) {
    return $env:CHROME_PATH
  }
  $candidates = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
  )
  foreach ($path in $candidates) {
    if (Test-Path $path) { return $path }
  }
  throw "Google Chrome not found. Install Chrome or set CHROME_PATH."
}

function Wait-HttpOk($url, $seconds = 90) {
  $deadline = (Get-Date).AddSeconds($seconds)
  while ((Get-Date) -lt $deadline) {
    try {
      $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { return $true }
    } catch { }
    Start-Sleep -Seconds 1
  }
  return $false
}

function Add-QueryParam($url, $name, $value) {
  $sep = if ($url.Contains("?")) { "&" } else { "?" }
  return "$url${sep}$name=$value"
}

function Build-PlayerUrl($baseUrl, $index, $code, $cacheBust) {
  $url = $baseUrl.TrimEnd("/")
  if ($index -gt 1 -and -not [string]::IsNullOrWhiteSpace($code)) {
    $c = $code.Trim().ToUpperInvariant()
    $url = Add-QueryParam $url "room" $c
  }
  if ($cacheBust) {
    $url = Add-QueryParam $url "cb" $cacheBust
  }
  return $url
}

function Reset-ChromeProfile($profileDir) {
  if (Test-Path $profileDir) {
    Remove-Item -LiteralPath $profileDir -Recurse -Force -ErrorAction SilentlyContinue
  }
  New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

function Clear-ChromeProfileCaches($profileDir) {
  $default = Join-Path $profileDir "Default"
  if (-not (Test-Path $default)) { return }

  $cacheDirs = @(
    "Cache",
    "Code Cache",
    "Service Worker",
    "GPUCache",
    "blob_storage"
  )
  foreach ($name in $cacheDirs) {
    $p = Join-Path $default $name
    if (Test-Path $p) {
      Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}

$chrome = Find-Chrome
$codeHint = if ($RoomCode) { $RoomCode.Trim().ToUpperInvariant() } else { "(create room in Player 1, then re-run with -RoomCode)" }

Write-Host "=== Regicide local multiplayer ===" -ForegroundColor Cyan
Write-Host "Players: $Players | Room prefill (2+): $codeHint"
Write-Host "Chrome:  $chrome"
Write-Host "Profiles: $ProfileRoot\player1 .. player$Players"
if ($ResetProfiles) {
  Write-Host "Storage: RESET profiles (cache + sessions)" -ForegroundColor Yellow
} elseif ($KeepStorage) {
  Write-Host "Storage: KEEP (may load stale UI - omit -KeepStorage to clear cache)" -ForegroundColor Yellow
} else {
  Write-Host "Storage: clear HTTP/cache per profile (sessions kept); close old Chrome windows first"
}
Write-Host ""

if (-not $ChromeOnly) {
  if (-not $SkipBackend) {
    $backRunning = $false
    try {
      $h = Invoke-WebRequest -Uri "$ApiUrl/health" -UseBasicParsing -TimeoutSec 2
      if ($h.StatusCode -eq 200) { $backRunning = $true }
    } catch { }

    if (-not $backRunning) {
      Write-Host "Starting backend ($ApiUrl)..."
      Start-Process -FilePath "npm" -ArgumentList "run", "dev" -WorkingDirectory $Back -WindowStyle Minimized
      if (-not (Wait-HttpOk "$ApiUrl/health" 45)) {
        throw "Backend did not start. Check the back terminal."
      }
    } else {
      Write-Host "Backend already running ($ApiUrl)"
    }
  }

  if (-not $SkipFlutter) {
    $flutterUp = $false
    try {
      $f = Invoke-WebRequest -Uri $AppUrl -UseBasicParsing -TimeoutSec 2
      if ($f.StatusCode -ge 200) { $flutterUp = $true }
    } catch { }

    if (-not $flutterUp) {
      Write-Host "Starting Flutter web ($AppUrl)..."
      Start-Process -FilePath "flutter" `
        -ArgumentList "run", "-d", "web-server", "--web-hostname=localhost", "--web-port=8080" `
        -WorkingDirectory $Front -WindowStyle Minimized
      Write-Host "Waiting for Flutter (first compile may take 1-2 min)..."
      if (-not (Wait-HttpOk $AppUrl 180)) {
        throw "Flutter dev server did not become ready at $AppUrl"
      }
    } else {
      Write-Host "Flutter already serving $AppUrl"
      Write-Host "  If UI looks old: hot restart Flutter (Shift+R), then re-run this script." -ForegroundColor DarkYellow
    }
  } else {
    if (-not (Wait-HttpOk $AppUrl 5)) {
      throw "Flutter not reachable at $AppUrl. Start it or omit -SkipFlutter."
    }
  }
} else {
  if (-not (Wait-HttpOk $AppUrl 5)) {
    throw "App not reachable at $AppUrl. Start Flutter or drop -ChromeOnly."
  }
  Write-Host "ChromeOnly: assuming backend + Flutter already running."
}

$chromeArgs = @(
  "--no-first-run",
  "--no-default-browser-check",
  "--disable-cache",
  "--disk-cache-size=1"
)

$cacheBust = if ($KeepStorage) { "" } else { [DateTimeOffset]::UtcNow.ToUnixTimeSeconds().ToString() }

for ($i = 1; $i -le $Players; $i++) {
  $profileDir = Join-Path $ProfileRoot "player$i"
  if ($ResetProfiles) {
    Reset-ChromeProfile $profileDir
    Write-Host "Reset profile - Player $i"
  } else {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    if (-not $KeepStorage) {
      Clear-ChromeProfileCaches $profileDir
    }
  }
  $url = Build-PlayerUrl $AppUrl $i $RoomCode $cacheBust
  Write-Host "Opening Chrome - Player $i : $url"
  Start-Process -FilePath $chrome -ArgumentList (@("--user-data-dir=$profileDir") + $chromeArgs + $url)
  if ($i -lt $Players) { Start-Sleep -Seconds 1 }
}

Write-Host ""
Write-Host "=== Test checklist ===" -ForegroundColor Green
Write-Host "  App     $AppUrl"
Write-Host "  API     $ApiUrl"
if ($Players -eq 1) {
  Write-Host "  Solo    Player 1: name -> Create room (solo) -> Start -> play"
} else {
  Write-Host "  Host    Player 1: name -> Create room -> copy invite link in lobby"
  if ($RoomCode) {
    Write-Host "  Guests  Players 2-$Players : URL prefilled with room=$codeHint -> Join"
  } else {
    Write-Host "  Guests  Players 2-$Players : enter code from host -> Join"
    Write-Host "  Tip     After host creates room, re-run:"
    Write-Host "          .\scripts\run-multiplayer-chrome.ps1 -ChromeOnly -Players $Players -RoomCode ROOMCODE"
  }
  Write-Host "  Start   Host starts when 2-4 players connected"
  Write-Host "  Rules   No hand reveals in chat; hand counts OK (see in-game reminder)"
}
Write-Host ""
Write-Host "Hot reload: 'r' in Flutter terminal; use Shift+R if UI still stale after cache clear."
Write-Host "Stale UI: close player Chrome windows, re-run script (default clears cache). Full wipe: -ResetProfiles"
Write-Host "Keep lobby session across runs: -KeepStorage (may show old build until hard refresh)."
Write-Host "Profiles persist in .chrome-profiles/ (gitignored)."
