'Arguments:' | Out-String | Write-Host
$args | Out-String | Write-Host

'ENV' | Out-String | Write-Host
Get-ChildItem Env: | Out-String | Write-Host

'Configuration' | Out-String | Write-Host
Get-Configuration | Out-String | Write-Host
