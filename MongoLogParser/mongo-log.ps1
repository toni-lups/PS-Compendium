<#
    Accepts log files or pipeline input
    Assumes MongoDB JSON logs (modern default)
    Wraps jq with sane presets
    Supports subcommands (slow, errors, ops, connections, filter)
    Is invokable like a standard mongotool

    Prerequisites
    jq available in PATH
    MongoDB logs in JSON format (--logFormat json)
    winget install jqlang.jq
    Verify: jq --version

    Examples:
    mongo-log slow mongod.log
    mongo-log errors mongod.log
    mongo-log ops mongod.log
    mongo-log connections mongod.log
    mongo-log filter mongod.log '.attr.durationMillis > 100'
    Get-Content mongod.log | mongo-log slow
#>

param(
    [Parameter(Mandatory, Position = 0)]
    [string] $Command,

    [Parameter(Position = 1, HelpMessage = 'Supply the path to a MongoDB log')]
    [string] $Path,

    [Parameter(ValueFromPipeline)]
    [string] $PipelineItr,

    [Parameter(Mandatory = $false)]
    [string] $CustomFilter
)

# initialize values
begin {
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Error 'jq is required but not found in PATH - see https://jqlang.org/'; exit 1
    }
    
    # define acceptable preset jq filters
    $script:jqFilterPresets = @{
        pretty = '.'

        slow = '
            select(.msg == "Slow query") |
            {
                ts: .t.$date,
                ns: .attr.ns,
                millis: .attr.durationMillis,
                plan: .attr.planSummary,
                command: .attr.command
            }
        '

        errors = '
			select(.s == "E" or .s == "F") | 
			{
                timestamp: .t."$date",
				severity: .s,
                component: .c,
                message: .msg,
                attributes: .attr
            }
		'

        ops = '
            select(.c == "COMMAND") |
            {
                ts: .t.$date,
                db: .attr.db,
                command: (.attr.command | keys[0]),
                millis: .attr.durationMillis
            }
        '

        connections = '
            select(.msg | test("connection")) |
            {
                ts: .t.$date,
                msg: .msg,
                remote: .attr.remote
            }
        '

        filter = $CustomFilter
    }

    # to hold pass-through pipeline input to jq
    $script:pipelineBuffer = @()

    function Invoke-Jq {
        param(
            [Parameter(Mandatory)]
            [string]$Filter
        )

        if ($script:pipelineBuffer) { 

            # if filter input was given via pipeline, pass it through to jq
            $script:pipelineBuffer -as [string] | jq "$Filter"
        } else {

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
        Write-Error 'Conflicting input received from pipeline and path; provide input from either pipeline or path'; exit 1
    }
   
    # append this pipeline block to the buffer
    $script:pipelineBuffer += $PipelineItr
    $PSBoundParameters
}

<# invoke jq on input by given command #>
end {
    # validate basic operation
    if (-not $Command) {
        Write-Error "Usage: mongo-log <command> [logfile]"; exit 1
    } $Command = $Command.ToLower()

    # validate correct usage of custom jq filter option
    if (
        ($Command -eq 'filter' -and -not $script:jqFilterPresets['filter']) -or 
        ($Command -ne 'filter' -and $script:jqFilterPresets['filter'])
    ) {
        Write-Error 'Usage: mongo-log filter <logfile> <jq-filter>'; exit 1
    }

    if (-not $script:jqFilterPresets.ContainsKey($Command)) {
        Write-Error "Unknown command '$Command'"; exit 1
    }

    Invoke-Jq $script:jqFilterPresets[$Command]
}
