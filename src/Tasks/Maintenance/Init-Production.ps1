
# Purge old log files.
if ($Config['LogPurgeAfterDays'] -is [int] -and $Config['LogPurgeAfterDays'] -gt 0 ) {
    $oldestDate = (Get-Date).AddDays(- $Config['LogPurgeAfterDays'])
    $logFilter = Join-Path $env:LogDirectory '*.log'
    $logs = Get-ChildItem $logFilter
    $purgeLogs = $logs | Where-Object {$_.LastWriteTime -lt $oldestDate}
    Write-Host "Puring files matching [$logFilter] older than [$oldestDate]."
    $purgeLogs | Out-String | Write-Host
    Remove-Item $purgeLogs
}
