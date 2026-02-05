<#  
    Goals:
    - Accept log files or pipeline input
    - Wrap jq with sane presets
        Support subcommands (slow, errors, ops, connections, filter)
        Invokable like a standard mongotool

    Prerequisites:
    - MongoDB logs in JSON format (--logFormat json)
    - jq available in PATH
        winget install jqlang.jq
        Verify: jq --version

    Examples:
    mongolog slow mongod.log
    mongolog errors mongod.log
    mongolog ops mongod.log
    mongolog connections mongod.log
    mongolog filter mongod.log '.attr.durationMillis > 100'
    Get-Content mongod.log | mongolog slow

    jq help: https://earthly.dev/blog/jq-select/
#>

param(
    [Parameter(Position = 0, Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Command,

    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string] $Path,

    [ValidateNotNullOrEmpty()]
    [string] $CustomFilter,

    [Parameter(ValueFromPipeline, DontShow)]
    [string] $PipelineItr
)

# initialize values
begin {

    $slowOpThresholdMS = 100

    # to hold pass-through pipeline input to jq
    $script:pipelineBuffer = @()
    
    # define acceptable preset jq filters
    $script:jqFilterPresets = @{
        pretty = "."

        compact = '
            . as $log
            | {
                severity: $log.s,
                component: $log.c,
                context: $log.ctx,
                message: $log.msg,
                attributes: $log.attr
            }
        '

        slow = '
            select(.c == \"COMMAND\" and (.attr.durationMillis // 0) > 100) 
            | . as $log 
            | {
                message: $log.msg,
                op: ( $log.attr.command // {} | keys_unsorted[0] ),
                namespace: $log.attr.ns,
                app: ( $log.attr.command // {} | .client.application.name ) // $log.attr.appName,

                durationMS: $log.attr.durationMillis,
                plan: $log.attr.planSummary,
                keysExamined: $log.attr.keysExamined // 0,
                docsExamined: $log.attr.docsExamined // 0
            }
        '

        harm = '
            select(.s == \"E\" or .s == \"F\" or .s == \"W\") 
            | . as $log
            | {
                severity: $log.s,
                component: $log.c,
                context: $log.ctx,
                message: $log.msg,
                attributes: $log.attr
            }
        '

        filter = $CustomFilter
    }

    function Invoke-Jq {
        param(
            [Parameter(Mandatory)]
            [string]$Filter
        )

        # if filter input was given via pipeline, pass it through to jq
        if ($script:pipelineBuffer) { 
            $script:pipelineBuffer -as [string] | jq "$Filter"
        } else {
            if (-not (Test-Path $Path)) {
                Write-Error 'Usage: .\mongolog.ps1 <Command> <logfile>' -Category InvalidArgument -CategoryReason 'Specified log path does not exist'; 
                
                exit 1
            }

            # if filter input was NOT given via pipeline, collect input for jq from given mongo log path
            Get-Content -Raw $Path | jq "$Filter"
        }
    }
}

<# handle (optional) pipeline input #>
process {
    if (-not $PipelineItr) { 
        return 
    } elseif ($PSBoundParameters.ContainsKey('Path')) {
        Write-Error 'Conflicting input received from pipeline and path. Provide input from either pipeline or path'; exit 1
    }
   
    # append this pipeline block to the buffer
    $script:pipelineBuffer += $PipelineItr
}

<# invoke jq on input by given command #>
end {
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Error 'jq is required but not found in PATH - see https://jqlang.org/'; exit 1
    }

    # validate correct usage of custom jq filter option
    $Command = $Command.ToLower()
    if (
        ($Command -eq 'filter' -and -not $script:jqFilterPresets['filter']) -or 
        ($Command -ne 'filter' -and $script:jqFilterPresets['filter'])
    ) {
        Write-Error 'Usage: .\mongolog.ps1 filter [logfile] <custom jq filter>' -Category InvalidOperation -CategoryReason 'Invalid usage of custom filter argument'
        
        exit 1
    }

    # validate unknown command 
    if (-not $script:jqFilterPresets.ContainsKey($Command)) {
        Write-Error "Unrecognized command '$Command'.`nValid options are $( $script:jqFilterPresets.Keys -join ', ' )."
        
        exit 1
    }

    Invoke-Jq $script:jqFilterPresets[$Command]
}
