param(
    [switch]$DryRun,
    [switch]$Clean,
    [switch]$Dism,
    [switch]$ResetBase,
    [switch]$IncludePrefetch,
    [switch]$IncludeBrowserCache,
    [int]$AgeDays = 0
)

$ErrorActionPreference = 'SilentlyContinue'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-CleanupTargets {
    param([switch]$IncludePrefetch, [switch]$IncludeBrowserCache)

    $targets = @(
        [PSCustomObject]@{ Name = 'User Temp';     Path = $env:TEMP;                                     RequiresAdmin = $false }
        [PSCustomObject]@{ Name = 'Windows Temp';  Path = (Join-Path $env:WinDir 'Temp');                RequiresAdmin = $true  }
        [PSCustomObject]@{ Name = 'Crash Dumps';   Path = (Join-Path $env:LOCALAPPDATA 'CrashDumps');    RequiresAdmin = $false }
    )

    if ($IncludePrefetch) {
        $targets += [PSCustomObject]@{
            Name = 'Prefetch'; Path = (Join-Path $env:WinDir 'Prefetch'); RequiresAdmin = $true
        }
    }

    if ($IncludeBrowserCache -and $env:LOCALAPPDATA) {
        $targets += [PSCustomObject]@{
            Name = 'Chrome Cache'; Path = (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Default\Cache'); RequiresAdmin = $false
        }
        $targets += [PSCustomObject]@{
            Name = 'Edge Cache';   Path = (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data\Default\Cache'); RequiresAdmin = $false
        }
        $ffProfiles = Join-Path $env:LOCALAPPDATA 'Mozilla\Firefox\Profiles'
        if (Test-Path -LiteralPath $ffProfiles) {
            Get-ChildItem -LiteralPath $ffProfiles -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $cache = Join-Path $_.FullName 'cache2'
                if (Test-Path -LiteralPath $cache) {
                    $targets += [PSCustomObject]@{
                        Name = "Firefox Cache ($($_.Name))"; Path = $cache; RequiresAdmin = $false
                    }
                }
            }
        }
    }

    return $targets
}

function Get-CleanupCandidates {
    param($Targets, [int]$AgeDays)

    $cutoff = (Get-Date).AddDays(-$AgeDays)
    $result = @()

    foreach ($t in $Targets) {
        if (-not (Test-Path -LiteralPath $t.Path)) { continue }
        $files = Get-ChildItem -LiteralPath $t.Path -File -Recurse -Force -ErrorAction SilentlyContinue |
                 Where-Object { $_.LastWriteTime -lt $cutoff }
        foreach ($f in $files) {
            $result += [PSCustomObject]@{
                Target  = $t.Name
                Path    = $f.FullName
                SizeMB  = [math]::Round($f.Length / 1MB, 3)
                AgeDays = [math]::Round(((Get-Date) - $f.LastWriteTime).TotalDays, 1)
                Status  = 'Planned'
            }
        }
    }

    return $result
}

function Remove-CleanupItem {
    param($Candidates)

    foreach ($c in $Candidates) {
        try {
            Remove-Item -LiteralPath $c.Path -Force -ErrorAction Stop
            if (-not (Test-Path -LiteralPath $c.Path)) {
                $c.Status = 'Deleted'
            } else {
                $c.Status = 'Skipped (in use)'
            }
        } catch {
            $c.Status = 'Error: ' + $_.Exception.Message
        }
    }

    return $Candidates
}

function Export-CleanupLog {
    param($Candidates)

    $logDir = Join-Path $PSScriptRoot 'logs'
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $logFile = Join-Path $logDir "cleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Candidates | Export-Csv -Path $logFile -NoTypeInformation -Encoding UTF8
    Write-Host "Лог: $logFile" -ForegroundColor DarkGray
}

function Invoke-DismCleanup {
    param([switch]$ResetBase)

    if (-not (Test-Admin)) {
        Write-Host 'DISM требует прав администратора.' -ForegroundColor Red
        return
    }

    $useResetBase = $ResetBase
    if (-not $useResetBase) {
        $answer = Read-Host 'Использовать /ResetBase? После этого откат обновлений станет невозможен (y/n)'
        if ($answer -eq 'y') { $useResetBase = $true }
    }

    $dismArgs = @('/Online', '/Cleanup-Image', '/StartComponentCleanup')
    if ($useResetBase) { $dismArgs += '/ResetBase' }

    Write-Host ''
    Write-Host ('Запуск: Dism.exe ' + ($dismArgs -join ' ')) -ForegroundColor Yellow
    Write-Host 'Это может занять 5–15 минут...' -ForegroundColor DarkGray
    & Dism.exe @dismArgs
}

# ---------- main ----------

if ($Dism) {
    Invoke-DismCleanup -ResetBase:$ResetBase
    exit 0
}

if (-not $DryRun -and -not $Clean) {
    $DryRun = $true
}

if ($AgeDays -le 0) {
    $raw = Read-Host 'Удалять файлы старше N дней (по умолчанию 7)'
    if ([string]::IsNullOrWhiteSpace($raw)) { $AgeDays = 7 }
    else { $AgeDays = [int]$raw }
}

$isAdmin = Test-Admin
if (-not $isAdmin) {
    Write-Host 'Внимание: скрипт запущен без прав администратора.' -ForegroundColor Yellow
    Write-Host 'Windows Temp и Prefetch могут быть недоступны для записи.' -ForegroundColor DarkGray
}

$targets = Get-CleanupTargets -IncludePrefetch:$IncludePrefetch -IncludeBrowserCache:$IncludeBrowserCache

Write-Host ''
Write-Host '=== ЦЕЛИ ОЧИСТКИ ===' -ForegroundColor Cyan
foreach ($t in $targets) {
    $mark = if (Test-Path -LiteralPath $t.Path) { 'OK' } else { 'нет' }
    Write-Host ("  {0,-20} {1}  [{2}]" -f $t.Name, $t.Path, $mark)
}

$candidates = Get-CleanupCandidates -Targets $targets -AgeDays $AgeDays

$totalCount = $candidates.Count
$totalSize  = 0
if ($totalCount -gt 0) {
    $totalSize = ($candidates | Measure-Object -Property SizeMB -Sum).Sum
}

Write-Host ''
Write-Host ("Найдено файлов старше {0} дн.: {1}" -f $AgeDays, $totalCount) -ForegroundColor Green
Write-Host ("Суммарный объём: {0} МБ" -f [math]::Round($totalSize, 1)) -ForegroundColor Green

if ($totalCount -eq 0) {
    Write-Host 'Нечего очищать.' -ForegroundColor DarkGray
    exit 0
}

if ($DryRun) {
    Write-Host ''
    Write-Host 'Режим анализа. Ничего не удалено.' -ForegroundColor Yellow
    Write-Host 'Для удаления запустите с параметром -Clean.' -ForegroundColor DarkGray
    Export-CleanupLog -Candidates $candidates
    exit 0
}

$confirm = Read-Host ('Будут удалены файлы старше {0} дн. Введите YES для продолжения' -f $AgeDays)
if ($confirm -ne 'YES') {
    Write-Host 'Отменено.' -ForegroundColor DarkGray
    exit 0
}

$candidates = Remove-CleanupItem -Candidates $candidates

$deleted = @($candidates | Where-Object { $_.Status -eq 'Deleted' })
$skipped = @($candidates | Where-Object { $_.Status -like 'Skipped*' })
$errors  = @($candidates | Where-Object { $_.Status -like 'Error*' })

$freedMB = 0
if ($deleted.Count -gt 0) {
    $freedMB = ($deleted | Measure-Object -Property SizeMB -Sum).Sum
}

Write-Host ''
Write-Host '=== ИТОГ ===' -ForegroundColor Cyan
Write-Host ("Удалено:      {0} файлов, {1} МБ" -f $deleted.Count, [math]::Round($freedMB, 1)) -ForegroundColor Green
Write-Host ("Пропущено:    {0}" -f $skipped.Count) -ForegroundColor Yellow
Write-Host ("Ошибок:       {0}" -f $errors.Count) -ForegroundColor Red

Export-CleanupLog -Candidates $candidates