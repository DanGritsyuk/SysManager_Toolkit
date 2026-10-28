param(
    [string]$FilePath,
    [string]$Action,
    [int]$Lines = 50,
    [string]$SearchTerm = "",
    [string]$Encoding = "UTF8"
)

$ErrorActionPreference = 'SilentlyContinue'

if (-not (Test-Path -LiteralPath $FilePath)) {
    Write-Host "Ошибка: Файл не найден!" -ForegroundColor Red
    exit 1
}

$fileInfo = Get-Item -LiteralPath $FilePath
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
$lastWrite = $fileInfo.LastWriteTime

Write-Host "==========================================================" -ForegroundColor DarkGray
Write-Host " Файл: $FilePath" -ForegroundColor Cyan
Write-Host " Размер: $sizeMB МБ | Изменен: $lastWrite" -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor DarkGray

# Кодировка приходит параметром; по умолчанию — UTF8
$enc = $Encoding

try {
    switch ($Action) {
        "Head" {
            Write-Host "Чтение первых $Lines строк..." -ForegroundColor Yellow
            Get-Content -LiteralPath $FilePath -TotalCount $Lines -Encoding $enc
        }
        "Tail" {
            Write-Host "Чтение последних $Lines строк..." -ForegroundColor Yellow
            Get-Content -LiteralPath $FilePath -Tail $Lines -Encoding $enc
        }
        "Live" {
            Write-Host "Режим реального времени (Ctrl+C для выхода)..." -ForegroundColor Green
            Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
            Get-Content -LiteralPath $FilePath -Tail $Lines -Wait -Encoding $enc
        }
        "Search" {
            Write-Host "Поиск: '$SearchTerm'..." -ForegroundColor Yellow
            Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
            Select-String -LiteralPath $FilePath -Pattern $SearchTerm -Context 2, 2 -Encoding $enc | 
                Select-Object -First 100 | 
                ForEach-Object { 
                    Write-Host "Строка $($_.LineNumber):" -ForegroundColor DarkGray
                    $_.Context.PreContext | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
                    Write-Host "> $($_.Line)" -ForegroundColor Green
                    $_.Context.PostContext | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
                    Write-Host ""
                }
        }
        "Page" {
            Write-Host "Постраничный просмотр (Пробел - далее, Q - выход)..." -ForegroundColor Yellow
            Get-Content -LiteralPath $FilePath -Encoding $enc | Out-Host -Paging
        }
    }
} catch {
    Write-Host "Ошибка при чтении: $_" -ForegroundColor Red
}