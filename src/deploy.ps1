param (
    [string]$Instance,
    [string]$RefSpec = 'master',
    [string]$Repository = 'https://github.com/treestryder/TaskEngine',
    $Credential,
    [switch]$PostProcess,
    [switch]$Force
)

$possibleInstances = @{
    test = @{
        ComputerName = 'localhost'
        LocalPath    = 'c:\test\TaskEngine'
        RemotePath   = 'c:\test\TaskEngine'
    }
}

$updateInstance = $possibleInstances.GetEnumerator() | Where-Object {$_.Name -like $Instance}

if ($null -eq $updateInstance) {
    $list = ($possibleInstances.Keys | Sort-Object) -join ', '
    Write-Warning "Instance [$Instance] not found in; $list."
    exit 1
}

Import-Module "$PsScriptRoot/TaskEngine/GitRepository.psm1"

foreach ($i in $updateInstance) {
    Write-Host "Processing: $($i.Name)"
    Push-GitRepository -RepositoryPath $Repository -DestinationPath $i.Value['RemotePath'] -Force:$Force
    if ($PostProcess) {
        if ($null -eq $Credential) {
            $Credential = Get-Credential -Message 'Enter Task Engine credential'
        }

        Invoke-Command -ComputerName $i.Value['ComputerName'] -Credential $Credential -ArgumentList $i.Name, $i.Value['LocalPath'], $Credential {
            param (
                $Instance,
                $RootPath,
                $Credential
            )
            Set-Location $RootPath
            $postDeploys = Get-ChildItem "./Tasks/*/deploy-$Instance.ps1"
            foreach ($postDeploy in $postDeploys) {
                Write-Host "Running $($postDeploy.FullName) on $($ENV:COMPUTERNAME) as $($env:USERNAME)."
                & $postDeploy.FullName -RootPath $RootPath -Credential $Credential
            }
        }
    }
}
