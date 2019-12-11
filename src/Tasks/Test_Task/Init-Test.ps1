Write-Host 'Arguments:'
$args | Write-Host

Write-Host 'ENV'
Get-ChildItem Env:

Write-Host 'Configuration'
Get-Configuration
