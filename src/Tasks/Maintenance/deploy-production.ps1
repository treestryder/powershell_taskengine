param (
    $RootPath,
    $Credential
)
$TaskName = Split-Path $PSScriptRoot -Leaf

$date = Get-Date
$invoker = Join-Path $RootPath 'Invoke-Task.ps1'
$instance = 'production'
$command = 'Powershell.exe -NonInteractive -ExecutionPolicy RemoteSigned -File \"{0}\" {1} {2}' -f $invoker, $TaskName, $instance
SCHTASKS /Create /SC Daily /ST 00:00 /SD $date.ToString('MM/dd/yyyy') /TR $command /TN $TaskName /RU $Credential.UserName /RP $Credential.GetNetworkCredential().Password /F | Write-Output
