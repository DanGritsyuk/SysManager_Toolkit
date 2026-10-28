param([string]$OutDir)
$ErrorActionPreference = 'SilentlyContinue'

if (-not $OutDir) { $OutDir = Join-Path $PSScriptRoot '..\..\reports' }
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$tmp = Join-Path $env:TEMP "collect_$stamp"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
Write-Host "Сбор диагностики..." -ForegroundColor Cyan

systeminfo > "$tmp\systeminfo.txt" 2>&1
ipconfig /all > "$tmp\ipconfig.txt" 2>&1
route print > "$tmp\route.txt" 2>&1
arp -a > "$tmp\arp.txt" 2>&1

Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort, OwningProcess, State |
    Export-Csv "$tmp\ports.csv" -NoTypeInformation -Encoding UTF8
Get-Service |
    Select-Object Status, Name, DisplayName, StartType |
    Export-Csv "$tmp\services.csv" -NoTypeInformation -Encoding UTF8
Get-Process | Sort-Object CPU -Descending | Select-Object -First 50 Name, Id, CPU, WorkingSet |
    Export-Csv "$tmp\top_processes.csv" -NoTypeInformation -Encoding UTF8
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, HealthStatus |
    Export-Csv "$tmp\disks.csv" -NoTypeInformation -Encoding UTF8
Get-EventLog -LogName System -Newest 100 |
    Select-Object TimeGenerated, EntryType, Source, Message |
    Export-Csv "$tmp\event_system.csv" -NoTypeInformation -Encoding UTF8
Get-EventLog -LogName Application -Newest 100 |
    Select-Object TimeGenerated, EntryType, Source, Message |
    Export-Csv "$tmp\event_app.csv" -NoTypeInformation -Encoding UTF8

$zip = Join-Path $OutDir "collect_$stamp.zip"
Compress-Archive -Path "$tmp\*" -DestinationPath $zip -Force
Remove-Item -Recurse -Force $tmp
Write-Host "Готово: $zip" -ForegroundColor Green