param([switch]$Save)

$ErrorActionPreference = 'SilentlyContinue'

function Get-DiskCheckReport {
    $lines = New-Object System.Collections.Generic.List[string]

    $lines.Add('======================================================================')
    $lines.Add('                         ПРОВЕРКА ДИСКОВ')
    $lines.Add('======================================================================')
    $lines.Add("Дата проверки   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $lines.Add("Компьютер       : $env:COMPUTERNAME")
    $lines.Add('')

    # ---------- Физические диски ----------
    $lines.Add('-- Физические диски --')
    $physicalDisks = Get-PhysicalDisk
    if ($physicalDisks) {
        foreach ($pd in $physicalDisks) {
            $sizeGB = if ($pd.Size) { [math]::Round($pd.Size / 1GB, 1) } else { 0 }
            $lines.Add("  Диск $($pd.DeviceId): $($pd.FriendlyName)")
            $lines.Add("    Тип носителя     : $($pd.MediaType)")
            $lines.Add("    Размер           : $sizeGB ГБ")
            $lines.Add("    Состояние (Health): $($pd.HealthStatus)")
            $lines.Add("    Статус (Operational): $($pd.OperationalStatus)")

            # Счётчики надёжности (в основном для SSD/NVMe, требуют прав администратора)
            $reliability = Get-StorageReliabilityCounter -PhysicalDisk $pd
            if ($reliability) {
                if ($null -ne $reliability.Wear) {
                    $lines.Add("    Износ (Wear)     : $($reliability.Wear)")
                }
                if ($null -ne $reliability.Temperature) {
                    $lines.Add("    Температура      : $($reliability.Temperature) °C")
                }
                if ($null -ne $reliability.PowerOnHours) {
                    $lines.Add("    Часы работы      : $($reliability.PowerOnHours) ч")
                }
                if ($null -ne $reliability.ReadErrorsTotal) {
                    $lines.Add("    Ошибок чтения    : $($reliability.ReadErrorsTotal)")
                }
                if ($null -ne $reliability.WriteErrorsTotal) {
                    $lines.Add("    Ошибок записи    : $($reliability.WriteErrorsTotal)")
                }
            } else {
                $lines.Add('    (счётчики надёжности недоступны — запустите от администратора)')
            }
            $lines.Add('')
        }
    } else {
        $lines.Add('  (физические диски не обнаружены)')
        $lines.Add('')
    }

    # ---------- Логические диски ----------
    $lines.Add('-- Логические диски --')
    $logicalDisks = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'
    if ($logicalDisks) {
        foreach ($ld in $logicalDisks) {
            $totalGB = [math]::Round($ld.Size / 1GB, 1)
            $freeGB  = [math]::Round($ld.FreeSpace / 1GB, 1)
            $usedGB  = [math]::Round(($ld.Size - $ld.FreeSpace) / 1GB, 1)
            $freePct = if ($ld.Size -gt 0) { [math]::Round($ld.FreeSpace / $ld.Size * 100, 1) } else { 0 }
            $warning = if ($freePct -lt 15) { '  ⚠ МАЛО МЕСТА' } else { '' }
            $lines.Add("  $($ld.DeviceID)  Всего: $totalGB ГБ | Занято: $usedGB ГБ | Свободно: $freeGB ГБ ($freePct%)$warning")
        }
    } else {
        $lines.Add('  (логические диски не обнаружены)')
    }
    $lines.Add('')

    # ---------- SMART-предсказание отказа (WMI) ----------
    $lines.Add('-- SMART (предсказание отказа) --')
    $smartStatuses = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus
    if ($smartStatuses) {
        foreach ($s in $smartStatuses) {
            $predict = if ($s.PredictFailure) { '⚠ ДА (возможен отказ)' } else { 'Нет' }
            $lines.Add("  $($s.InstanceName) : $predict")
        }
    } else {
        $lines.Add('  (SMART-статус через WMI недоступен)')
    }

    $lines.Add('======================================================================')
    return $lines
}

$report = Get-DiskCheckReport

if ($Save) {
    $reportsDir = Join-Path $PSScriptRoot 'reports'
    if (-not (Test-Path $reportsDir)) {
        New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null
    }
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $file  = Join-Path $reportsDir "diskcheck_$stamp.txt"
    $i = 1
    while (Test-Path $file) {
        $file = Join-Path $reportsDir "diskcheck_${stamp}_$i.txt"
        $i++
    }
    $report | Out-File -FilePath $file -Encoding UTF8
    Write-Host 'Отчёт сохранён:'
    Write-Host "  $file"
} else {
    foreach ($line in $report) { Write-Host $line }
}