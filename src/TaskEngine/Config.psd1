@{
    LogDirectory = ''
    TranscriptEnabled = $false
    # {0} = LogDirectory, {1} = Date/Time, {2} = Task Name, {3} = Task Instance
    TranscriptFileTemplate = '{0}\Task-{2}-{3}-{1:ddd}.log'
    TranscriptAppend = $true
}
