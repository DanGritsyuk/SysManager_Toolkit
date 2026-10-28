<# : BAT+PowerShell hybrid script
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cls
echo ============================================
echo   ЗАПОЛНЕНИЕ ARP-ТАБЛИЦЫ
echo ============================================
echo.

:: Путь к папке с таблицами (относительно расположения scan.bat)
set "TABLE_DIR=%~dp0tables"
if not exist "%TABLE_DIR%" mkdir "%TABLE_DIR%"

set /p "subnet_input=Введите подсеть (первые 3 октета, например 192.168.1, или CIDR, например 192.168.1.0/24) или нажмите Enter для автоопределения: "

echo.
echo Запуск сканирования сети и заполнение ARP-кэша...
echo Пожалуйста, подождите. Это может занять некоторое время.

:: Копируем себя во временный .ps1 файл
set "psfile=%TEMP%\arp_fill.ps1"
copy /y "%~f0" "%psfile%" >nul

:: Запускаем PowerShell с временным .ps1 файлом
powershell -NoProfile -ExecutionPolicy Bypass -File "%psfile%" -Subnet "%subnet_input%"
set exitcode=%errorlevel%

:: Удаляем временный файл
del "%psfile%" 2>nul

if %exitcode% neq 0 (
    echo.
    echo Ошибка при выполнении сканирования.
    pause
    exit /b 1
)

echo.
echo ============================================
echo            Полная ARP-таблица
echo ============================================
cls
arp -a

:: Сохраняем результат в файл в папку tables с меткой времени
set "timestamp=%date:/=-%_%time::=-%"
set "timestamp=%timestamp: =0%"
set "filename=ARP_table_%timestamp%.txt"
set "fullpath=%TABLE_DIR%\%filename%"
arp -a > "%fullpath%"
echo.
for %%F in ("%fullpath%") do set "name=%%~nxF"
echo Таблица сохранена в файл: %name%
echo.

pause
exit /b

goto :EOF
#>

param (
    [string]$Subnet
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$one = [uint32]1

if ([string]::IsNullOrEmpty($Subnet)) {
    $ipConfig = Get-NetIPAddress -AddressFamily IPv4 |
                Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.PrefixOrigin -ne 'WellKnown' } |
                Sort-Object InterfaceMetric |
                Select-Object -First 1

    if (-not $ipConfig) {
        Write-Error 'Не удалось определить IP-адрес.'
        exit 1
    }

    $ipAddr   = $ipConfig.IPAddress
    $prefix   = $ipConfig.PrefixLength
    $ipBytes  = [System.Net.IPAddress]::Parse($ipAddr).GetAddressBytes()
    [Array]::Reverse($ipBytes)
    $ipUint   = [uint32][System.BitConverter]::ToUInt32($ipBytes, 0)

    $maskUint = [uint32](([uint32]::MaxValue -shl (32 - $prefix)) -band [uint32]::MaxValue)
    $netUint  = [uint32]($ipUint -band $maskUint)
    $broadcastUint = [uint32]($netUint -bor ((-bnot $maskUint) -band [uint32]::MaxValue))

    $startUint = [uint32]($netUint + $one)
    $endUint   = [uint32]($broadcastUint - $one)

    if ($endUint -lt $startUint) {
        Write-Host 'Подсеть слишком мала (нет хостов).'
        exit
    }

    $range = for ($i = $startUint; $i -le $endUint; $i++) {
        $i32 = [uint32]$i
        $bytes = [System.BitConverter]::GetBytes($i32)
        [Array]::Reverse($bytes)
        ([System.Net.IPAddress]$bytes).ToString()
    }
}
else {
    if ($Subnet -match '^(\d{1,3}\.\d{1,3}\.\d{1,3})\.?\*?$') {
        $base  = $matches[1]
        $range = 1..254 | ForEach-Object { "$base.$_" }
    }
    elseif ($Subnet -match '^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/(\d+)$') {
        $ip     = $matches[1]
        $prefix = [int]$matches[2]

        $ipBytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
        [Array]::Reverse($ipBytes)
        $ipUint  = [uint32][System.BitConverter]::ToUInt32($ipBytes, 0)

        $maskUint = [uint32](([uint32]::MaxValue -shl (32 - $prefix)) -band [uint32]::MaxValue)
        $netUint  = [uint32]($ipUint -band $maskUint)
        $broadcastUint = [uint32]($netUint -bor ((-bnot $maskUint) -band [uint32]::MaxValue))

        $startUint = [uint32]($netUint + $one)
        $endUint   = [uint32]($broadcastUint - $one)

        $range = for ($i = $startUint; $i -le $endUint; $i++) {
            $i32 = [uint32]$i
            $bytes = [System.BitConverter]::GetBytes($i32)
            [Array]::Reverse($bytes)
            ([System.Net.IPAddress]$bytes).ToString()
        }
    }
    else {
        Write-Error 'Неверный формат. Введите три октета (192.168.1) или CIDR (192.168.1.0/24).'
        exit 1
    }
}

Write-Host "Обнаружено адресов для опроса: $($range.Count)"
if ($range.Count -gt 2000) {
    Write-Warning 'Подсеть очень большая, сканирование может занять несколько минут.'
}

$jobs = $range | ForEach-Object {
    Test-Connection -ComputerName $_ -Count 1 -AsJob -ErrorAction SilentlyContinue
}

$jobs | Wait-Job -Timeout 10 | Out-Null
$jobs | Remove-Job -Force

Write-Host 'Сканирование завершено.'