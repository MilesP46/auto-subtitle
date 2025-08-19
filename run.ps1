param(
    [Parameter(Mandatory=$true)][string]$Video,
    [string]$Model
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is required but not installed."
    exit 1
}

if (-not (Test-Path 'in')) { New-Item -ItemType Directory 'in' | Out-Null }
if (-not (Test-Path 'out')) { New-Item -ItemType Directory 'out' | Out-Null }

if (-not (Test-Path '.env')) {
    Write-Error "Missing .env file. Copy .env.example to .env and set OPENAI_API_KEY."
    exit 1
}

Get-Content .env | ForEach-Object {
    if ($_ -and -not $_.StartsWith('#')) {
        $parts = $_ -split '=', 2
        [Environment]::SetEnvironmentVariable($parts[0], $parts[1])
    }
}

$envArgs = @()
if ($Model) {
    $envArgs += '--env'
    $envArgs += "MODEL=$Model"
}

docker compose run --rm @envArgs autosub "/data/$Video"
