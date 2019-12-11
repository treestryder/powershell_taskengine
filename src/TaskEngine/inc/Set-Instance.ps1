function Set-Instance {
    [CmdletBinding()]
    param (
        [string]$Instance,
        [switch]$Force
    )

    if ($Force -or $script:Config['_Instance'] -eq 'Uninitialized') {
        Import-LocalizedData -BaseDirectory "$PSScriptRoot\.." -FileName Config.psd1 -BindingVariable DefaultConfig -ErrorAction Stop
        foreach ($entry in $DefaultConfig.GetEnumerator()) {
            $script:Config[$entry.key] = $entry.value
        }
        $script:Config['_Instance'] = 'Default'
    }

    if (-not [string]::IsNullOrEmpty($Instance)) {
        if ($Force -or $script:Config['_Instance'] -ne $Instance) {
            $alternateConfigFile = Resolve-Path -Path "$PsScriptRoot\..\Config-$Instance.psd1"
            if (Test-Path -Path $alternateConfigFile) {
                $script:Config['_Instance'] = $Instance
                Import-LocalizedData -BaseDirectory "$PSScriptRoot\.." -FileName "Config-$Instance.psd1" -BindingVariable AlternateConfig -ErrorAction Stop
                $protectedPropertiesRegex = '$_'
                foreach ($entry in $AlternateConfig.GetEnumerator()) {
                    if ($entry.key -notmatch $protectedPropertiesRegex) {
                        $script:Config[$entry.key] = $entry.value
                    }
                }
            }
        }
    }
}
