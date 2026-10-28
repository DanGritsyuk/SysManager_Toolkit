param(
    [string]$Action,
    [string]$Name,
    [string]$Filter
)
$ErrorActionPreference = 'Stop'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FriendlyError {
    param($ErrorRecord, [string]$ServiceName)

    $msg = $ErrorRecord.Exception.Message
    $inner = $ErrorRecord.Exception.InnerException
    if ($inner -and $inner.Message) { $msg += ' | ' + $inner.Message }

    if ($msg -match 'Cannot open|Access is denied|Access denied|отказано в доступе|0x5\b') {
        return "Нет прав для управления службой '$ServiceName'. Запустите SysManager Toolkit от имени администратора."
    }
    if ($msg -match 'Cannot find any service|не найдена|NoServiceFoundForGivenName') {
        return "Служба '$ServiceName' не найдена. Проверьте имя (Get-Service -Name *часть*)."
    }
    if ($msg -match 'cannot be stopped|Cannot stop service') {
        return "Службу '$ServiceName' нельзя остановить: она защищена или зависит от неё другая служба."
    }
    if ($msg -match 'Cannot start service|Cannot start') {
        return "Не удалось запустить '$ServiceName': проверьте зависимости и журнал событий."
    }
    return $msg
}

switch ($Action) {

    'list' {
        Get-Service |
            Where-Object { $_.Name -like "*$Filter*" -or $_.DisplayName -like "*$Filter*" } |
            Select-Object Status, Name, DisplayName |
            Format-Table -AutoSize
    }

    'restart' {
        if (-not $Name) {
            Write-Host "Укажите имя службы." -ForegroundColor Red
            exit 1
        }

        $isAdmin = Test-Admin
        if (-not $isAdmin) {
            Write-Host "Внимание: без прав администратора большинство служб перезапустить не удастся." -ForegroundColor Yellow
            Write-Host "Запустите SysManager Toolkit от имени администратора для полного доступа." -ForegroundColor DarkGray
            Write-Host ""
        }

        $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
        if (-not $svc) {
            Write-Host "Служба '$Name' не найдена. Проверьте имя." -ForegroundColor Red
            exit 1
        }

        Write-Host ("Перезапуск {0} (текущее состояние: {1})..." -f $Name, $svc.Status) -ForegroundColor Yellow
        try {
            Restart-Service -Name $Name -Force -ErrorAction Stop
            Write-Host "Готово: $Name перезапущена." -ForegroundColor Green
        } catch {
            Write-Host "[ОШИБКА] $(Get-FriendlyError $_ $Name)" -ForegroundColor Red
            Write-Host "Подсказка: системные службы требуют запуска от имени администратора." -ForegroundColor DarkGray
            exit 1
        }
    }

    'deps' {
        if (-not $Name) {
            Write-Host "Укажите имя службы." -ForegroundColor Red
            exit 1
        }
        $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
        if (-not $svc) {
            Write-Host "Служба '$Name' не найдена." -ForegroundColor Red
            exit 1
        }
        Write-Host "Зависит от:" -ForegroundColor Cyan
        $svc.ServicesDependedOn  | Select-Object Name, Status, DisplayName | Format-Table -AutoSize
        Write-Host "От неё зависят:" -ForegroundColor Cyan
        $svc.DependentServices   | Select-Object Name, Status, DisplayName | Format-Table -AutoSize
    }

    'autostart' {
        Get-CimInstance Win32_Service |
            Where-Object { $_.StartMode -eq 'Auto' } |
            Select-Object Name, DisplayName, State, StartMode |
            Format-Table -AutoSize
    }
}