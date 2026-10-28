param([switch]$Save)

$ErrorActionPreference = 'SilentlyContinue'

function Get-SysInfoReport {
    $lines = New-Object System.Collections.Generic.List[string]

    $cs   = Get-CimInstance Win32_ComputerSystem
    $os   = Get-CimInstance Win32_OperatingSystem
    $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
    $bios = Get-CimInstance Win32_BIOS

    $ramGB     = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
    $freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $uptime    = (Get-Date) - $os.LastBootUpTime
    $uptimeStr = '{0} дн. {1} ч. {2} мин.' -f $uptime.Days, $uptime.Hours, $uptime.Minutes

    $lines.Add('======================================================================')
    $lines.Add('                       СИСТЕМНАЯ ИНФОРМАЦИЯ')
    $lines.Add('======================================================================')
    $lines.Add("Дата сбора      : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $lines.Add('')
    $lines.Add('-- Общие сведения --')
    $lines.Add("  Имя ПК         : $env:COMPUTERNAME")
    $lines.Add("  Пользователь   : $env:USERNAME")
    $lines.Add("  ОС             : $($os.Caption) ($($os.Version))")
    $lines.Add("  Архитектура    : $($os.OSArchitecture)")
    $lines.Add("  Производитель  : $($cs.Manufacturer) / $($cs.Model)")
    $lines.Add("  BIOS           : $($bios.Manufacturer) $($bios.SMBIOSBIOSVersion)")
    $lines.Add("  Uptime         : $uptimeStr")
    $lines.Add('')
    $lines.Add('-- Процессор --')
    $lines.Add("  Модель         : $($cpu.Name)")
    $lines.Add("  Ядра/Потоки    : $($cpu.NumberOfCores) / $($cpu.NumberOfLogicalProcessors)")
    $lines.Add("  Частота        : $($cpu.MaxClockSpeed) MHz")
    $lines.Add('')
    $lines.Add('-- Память --')
    $lines.Add("  Всего ОЗУ      : $ramGB ГБ")
    $lines.Add("  Свободно ОЗУ   : $freeRamGB ГБ")
    $lines.Add('')
    $lines.Add('-- Логические диски --')
    $disks = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'
    if ($disks) {
        foreach ($d in $disks) {
            $total = [math]::Round($d.Size / 1GB, 1)
            $free  = [math]::Round($d.FreeSpace / 1GB, 1)
            $used  = [math]::Round(($d.Size - $d.FreeSpace) / 1GB, 1)
            $pct   = if ($d.Size -gt 0) { [math]::Round(($d.Size - $d.FreeSpace) / $d.Size * 100, 1) } else { 0 }
            $lines.Add("  $($d.DeviceID)  Всего: $total ГБ | Занято: $used ГБ ($pct%) | Свободно: $free ГБ")
        }
    } else {
        $lines.Add('  (диски не найдены)')
    }
    $lines.Add('')
    $lines.Add('-- Сетевые адаптеры (IPv4) --')
    $ips = Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' }
    if ($ips) {
        foreach ($ip in $ips) {
            $lines.Add("  $($ip.InterfaceAlias) : $($ip.IPAddress)")
        }
    } else {
        $lines.Add('  (активных IPv4-адресов не найдено)')
    }
    $lines.Add('======================================================================')

    return $lines
}

$report = Get-SysInfoReport

if ($Save) {
    $reportsDir = Join-Path $PSScriptRoot 'reports'
    if (-not (Test-Path $reportsDir)) {
        New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null
    }
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $file  = Join-Path $reportsDir "sysinfo_$stamp.txt"
    $i = 1
    while (Test-Path $file) {
        $file = Join-Path $reportsDir "sysinfo_${stamp}_$i.txt"
        $i++
    }
    $report | Out-File -FilePath $file -Encoding UTF8
    Write-Host 'Отчёт сохранён:'
    Write-Host "  $file"
} else {
    foreach ($line in $report) { Write-Host $line }
}