$ErrorActionPreference = 'SilentlyContinue'
Write-Host "=== DOCTOR: проверка окружения ===" -ForegroundColor Cyan
$script:ok = 0; $script:warn = 0; $script:fail = 0

function Check($Name, $ScriptBlock, $Hint) {
    $result = [bool](& $ScriptBlock)
    if ($result) {
        Write-Host "[OK]   $Name" -ForegroundColor Green
        $script:ok++
    } else {
        Write-Host "[FAIL] $Name — $Hint" -ForegroundColor Red
        $script:fail++
    }
}

Check "PowerShell >= 5.1" { $PSVersionTable.PSVersion -ge [version]'5.1' } "Обновите PowerShell"
Check "ExecutionPolicy" { (Get-ExecutionPolicy) -in 'Bypass','Unrestricted','RemoteSigned' } "Set-ExecutionPolicy RemoteSigned"
Check "Administrator" {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
} "Запустите от имени администратора (для ARP/Prefetch/DISM)"
Check "OpenSSH Client" { Get-Command ssh -ErrorAction SilentlyContinue } "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
Check "Console UTF-8" { [Console]::OutputEncoding.CodePage -eq 65001 } "chcp 65001"
Check "connections.txt" { Test-Path (Join-Path $PSScriptRoot 'connections\connections.txt') } "Создайте connections/connections.txt"
Check "config.ini" { Test-Path (Join-Path $PSScriptRoot 'network\internet_watch\config.ini') } "Создайте network/internet_watch/config.ini"

Write-Host ""
Write-Host "Итог: OK=$($script:ok), FAIL=$($script:fail)" -ForegroundColor Cyan
if ($script:fail -gt 0) { exit 1 } else { exit 0 }