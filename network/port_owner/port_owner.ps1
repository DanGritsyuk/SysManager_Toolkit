param(
    [int]$Port,
    [string]$Process,
    [switch]$List
)
$ErrorActionPreference = 'SilentlyContinue'

if ($List) {
    Get-NetTCPConnection -State Listen | ForEach-Object {
        $p = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            LocalAddress = $_.LocalAddress
            LocalPort    = $_.LocalPort
            PID          = $_.OwningProcess
            Process      = $p.ProcessName
        }
    } | Sort-Object LocalPort | Format-Table -AutoSize
}
elseif ($Port) {
    $conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if (-not $conns) { Write-Host "Порт $Port не слушается." -ForegroundColor Yellow; exit }
    foreach ($c in $conns) {
        $p = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
        Write-Host ("Порт {0}: PID {1} ({2}) — {3}" -f $Port, $c.OwningProcess, $p.ProcessName, $c.State) -ForegroundColor Green
    }
}
elseif ($Process) {
    $procs = Get-Process -Name "*$Process*" -ErrorAction SilentlyContinue
    if (-not $procs) { Write-Host "Процесс не найден."; exit }
    foreach ($p in $procs) {
        $conns = Get-NetTCPConnection -OwningProcess $p.Id -ErrorAction SilentlyContinue
        foreach ($c in $conns) {
            Write-Host ("{0} (PID {1}): {2}:{3} — {4}" -f $p.ProcessName, $p.Id, $c.LocalAddress, $c.LocalPort, $c.State)
        }
    }
}