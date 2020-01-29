<#
.SYNOPSIS
    Runs commands in .\Tasks\[TASK]\Init-[INSTANCE] with the environment configured and output logging.
#>
param (
    [string]$Task,
    [string]$Instance
)
$TaskArguments = @($args)

Get-Module TaskEngine | Remove-Module
Import-Module "$PsScriptRoot\TaskEngine\TaskEngine.psd1"
Set-Instance -Instance:$Instance

$Config = Get-Configuration
if ($Config['TranscriptEnabled'] -eq $true) {
    if (-not (Test-Path -Path $Config['LogDirectory'])) {
        New-Item -Path $Config['LogDirectory'] -ItemType Directory | Out-Null
    }

    $Config['_Task'] = $Task
    $Config['TaskTranscriptFile'] = $Config['TranscriptFileTemplate'] -f $Config['LogDirectory'], (Get-Date), $Task, $Instance
    
    # If one already exists, start with a clean transcript file.
    if (Test-Path $Config['TaskTranscriptFile']) { Remove-Item $Config['TaskTranscriptFile'] }

    function Write-Host {
        param (
            [Parameter(
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0
            )]
            [object[]]$InputObject
        )
        begin {
            $LineTemplate = '{1:G} {0}'
        }
        process {
            Write-Log -InputObject $InputObject -Path $Config['TaskTranscriptFile'] -LineTemplate $LineTemplate -PassThru
        }
    }

    function Write-Warning {
        param (
            [Parameter(
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0
            )]
            [object[]]$InputObject
        )
        begin {
            $LineTemplate = '{1:G} WARNING {0}'
        }
        process {
            Write-Log -InputObject $InputObject -Path $Config['TaskTranscriptFile'] -LineTemplate $LineTemplate -PassThru
        }
    }
    function Write-Error {
        param (
            [Parameter(
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0
            )]
            [object[]]$InputObject
        )
        begin {
            $LineTemplate = '{1:G} ERROR {0}'
        }
        process {
            Write-Log -InputObject $InputObject -Path $Config['TaskTranscriptFile'] -LineTemplate $LineTemplate -PassThru
        }
    }

    "Logging to: $($Config['TaskTranscriptFile'])" | Write-Host
}

# Save configuration to environment.
foreach ($item in ($Config).GetEnumerator()) {
    $path = 'ENV:' + $item.Key
    Set-Item -Path $path -Value $item.Value
}

$File = if ([string]::IsNullOrWhiteSpace($Instance)) {'Init'} else {"Init-$Instance"}
$TaskInitializer = "$PsScriptRoot\Tasks\$Task\$File"

'Starting: {0}' -f $TaskInitializer | Write-Host
try {
    & $TaskInitializer @TaskArguments | Write-Output
}
catch {
    $_.ToString() | Write-Error
}
'Finished' -f (Get-Date) | Write-Host
