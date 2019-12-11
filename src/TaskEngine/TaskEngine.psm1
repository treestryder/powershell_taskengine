Set-StrictMode -Version Latest
$script:Config = @{
    _Instance = 'Uninitialized'
}
# Fail at the first exception.
try {
    Get-ChildItem "$PSScriptRoot/inc/*.ps1" | ForEach-Object { . $_ }
    Set-Instance
}
catch {
    throw
}
