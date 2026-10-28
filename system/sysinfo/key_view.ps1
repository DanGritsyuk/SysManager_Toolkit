$ErrorActionPreference = 'SilentlyContinue'

function Format-ProductKey([string]$raw) {
    if (-not $raw) { return $null }
    $clean = $raw -replace '[^A-Z0-9]', ''
    if ($clean.Length -ne 25) { return $raw }
    return ($clean -replace '(.{5})(?!$)', '$1-')
}

function ConvertFrom-DigitalProductId([byte[]]$bytes) {
    if (-not $bytes -or $bytes.Length -lt 67) { return $null }
    $chars = 'BCDFGHJKMPQRTVWXY2346789'
    $key = @()
    for ($i = 24; $i -ge 0; $i--) {
        $cur = 0
        for ($j = 14; $j -ge 0; $j--) {
            $cur = $cur * 256
            $cur = $bytes[$j + 52] + $cur
            $bytes[$j + 52] = [Math]::Floor($cur / 24)
            $cur = $cur % 24
        }
        $key = $chars[$cur] + $key
    }
    return ($key -replace '(.{5})(?!$)', '$1-')
}

# 1. OEM-ключ из BIOS/UEFI
$oemKey = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey

# 2. BackupProductKeyDefault из реестра
$backupKey = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' -Name BackupProductKeyDefault).BackupProductKeyDefault

# 3. Декодированный DigitalProductId
$digitalKey = $null
$bytes = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DigitalProductId).DigitalProductId
if ($bytes) { $digitalKey = ConvertFrom-DigitalProductId $bytes }

# 4. Статус лицензии
$lic = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f'" | Select-Object -First 1
$statusMap = @{
    0 = 'Не активирована'
    1 = 'Активирована'
    2 = 'Пробный период'
    3 = 'Дополнительный период'
    4 = 'Не активирована (лимит)'
    5 = 'Уведомление'
    6 = 'Расширенный пробный период'
}
$statusText = if ($statusMap.ContainsKey($lic.LicenseStatus)) { $statusMap[$lic.LicenseStatus] } else { "Неизвестно ($($lic.LicenseStatus))" }

Write-Host '======================================================================'
Write-Host '                    ЛИЦЕНЗИЯ WINDOWS'
Write-Host '======================================================================'
Write-Host ("  Статус           : " + $statusText)
if ($lic.Name)        { Write-Host ("  Редакция         : " + $lic.Name) }
if ($lic.Description) { Write-Host ("  Описание         : " + $lic.Description) }
Write-Host ''
if ($oemKey)      { Write-Host ("  OEM (BIOS)       : " + (Format-ProductKey $oemKey)) }
else              { Write-Host '  OEM (BIOS)       : не найден' }
if ($backupKey)   { Write-Host ("  Backup (реестр)  : " + (Format-ProductKey $backupKey)) }
else              { Write-Host '  Backup (реестр)  : не найден' }
if ($digitalKey)  { Write-Host ("  DigitalProductId : " + $digitalKey) }
else              { Write-Host '  DigitalProductId : не найден' }
Write-Host '======================================================================'
Write-Host 'Примечание: для digital license (обновление/Store) реального ключа'
Write-Host 'на машине нет — показывается generic-ключ. Это нормально.'