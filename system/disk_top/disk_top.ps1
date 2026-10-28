param(
    [string]$Path = "C:\",
    [int]$Top = 20,
    [switch]$Folders
)
$ErrorActionPreference = 'SilentlyContinue'

if ($Folders) {
    Get-ChildItem -LiteralPath $Path -Directory -Force |
        ForEach-Object {
            $size = (Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum).Sum
            [PSCustomObject]@{ Folder = $_.FullName; SizeGB = [math]::Round($size / 1GB, 2) }
        } | Sort-Object SizeGB -Descending | Select-Object -First $Top | Format-Table -AutoSize
} else {
    Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending | Select-Object -First $Top |
        Select-Object @{N='SizeMB';E={[math]::Round($_.Length / 1MB, 2)}}, FullName |
        Format-Table -AutoSize
}