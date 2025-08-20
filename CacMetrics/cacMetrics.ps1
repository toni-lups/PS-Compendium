######################################################################################
# Polymon - Script Engine Performance Monitoring
# Site - 
# $Version - 
# assumptions - prometheus-like format
#  - Lines starting with '#' are HELP/TYPE metadata
#  - TYPE comments are present in data, in the form "# TYPE METRIC_NAME METRIC_TYPE"
#  - metric names are constant, label names are constant
#  - whitespace is used to parse keys and values
#  - histogram bucket identifiers (script_name and le), are enclosed in curly
#  - Labels are key="value", values are numeric, labels enclosed in curly braces
######################################################################################

using namespace System.Collections.Generic

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage = 'provide a valid relative or absolute folder path')]
    [string]$LogPath
)

#region variables
$remoteMachineSE = 'FUSCAC2TEST01'
$requestUri = 'http://127.0.0.1:5011/metrics'

$alertingRules = @(
    @{
        Name             = 'HighRequestRate'
        TargetMetricName = 'my_application_requests_total'
        TargetLabel      = 'instance'
        TargetLabelValue = 'app-server-01'
        Threshold        = 1000 # Example threshold
    }
    
    # Add more monitor rules here
)

# deprecated
# $checkedMetrics = @( # list of metrics from ScriptEngine/metrics this script considers for alerting
#     'process_cpu_seconds_total', # counter
#     'process_num_threads', # gauge
#     'cac_workflow_evaluation_script_in_progress', # gauge
#     'cac_standard_workflow_accounts_in_progress', # gauge
#     'cac_custom_workflow_accounts_in_progress', # gauge
#     'cac_standard_workflow_account_duration', # histogram
#     'cac_custom_workflow_account_duration', # histogram
#     'cac_workflow_evaluation_script_duration' # histogram
#)
#endregion

#region main functions
function Parse-ScriptEngineMetrics {
    [OutputType([List[PsCustomObject]])]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$RawData
    )

    # convert /metrics raw response to a json-friendly object for ease of alerting
    $parsedDataRes = [List[PSCustomObject]]::new() # for final return
    $metricMetaData = @{} # track metric metadata (starting with #)

    Write-Host 'Starting raw data parsing'
    $RawData | ForEach-Object {
        $line = $_.Trim()
        Write-Verbose "Parsing metrics line: $line"

        TryParse-MetricMetaDataLine -Line $line -InputMap $metricMetaData
    }

    Write-Verbose "final parsed metric metadata $($metricMetaData | ConvertTo-Json -Compress:$false -Depth 10)"

    Write-Host "Completed parsing of Script Engine metrics with $($parsedDataRes.Count) metrics"
    return $parsedDataRes
}

function Parse-ScriptEngineMetricsDeprecated {
    [OutputType([List[PsCustomObject]])]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$RawData
    )

    $parsedDataRes = [List[PSCustomObject]]::new()

    # local util function
    function Update-HistogramEntry {
        param (
            [PSCustomObject]$metricsMap,
            [string]$metricName,
            [string]$lineType,
            [string]$lineValue,
            [string]$scriptName,
            [string]$leValue
        )

        # handle CDI evaluation script histogram
        $currMetric = $metricsMap[$metricName]
        if ($scriptName) {

            # add scripts property if not exist
            if (-not $currMetric.scripts) {
                $currMetric | Add-Member -NotePropertyName scripts -NotePropertyValue @{}
            }

            # set a new scripts entry
            if (-not $currMetric.scripts[$scriptName]) {
               $currMetric.scripts[$scriptName] = [PSCustomObject]@{}
            }

            if ($lineType -eq 'bucket') {
                
                # add buckets property if not exist
                if (-not $currMetric.scripts[$scriptName].buckets) {
                    $currMetric.scripts[$scriptName] | Add-Member -NotePropertyName buckets -NotePropertyValue @{}
                }

                # set a new bucket entry
                if (-not $currMetric.scripts[$scriptName].buckets[$leValue]) {
                    $currMetric.scripts[$scriptName].buckets[$leValue] = [double]$lineValue
                }
            } else {
                $currMetric.scripts[$scriptName] | Add-Member `
                    -NotePropertyName $lineType `
                    -NotePropertyValue ([double]$lineValue)
            }

        } else { # handle standard histogram: flat
            if ($lineType -eq 'bucket') {
                
                # add buckets property if not exist
                if (-not $currMetric.buckets) {
                    $currMetric | Add-Member -NotePropertyName buckets -NotePropertyValue @{}
                }

                # set a new bucket entry
                if (-not $currMetric.buckets[$leValue]) {
                    $currMetric.buckets[$leValue] = [double]$lineValue
                }
            } else {
                $currMetric | Add-Member -NotePropertyName $lineType -NotePropertyValue ([double]$lineValue)
            }
        }

        return $metricsMap
    }

    # process lines of raw data from ScriptEngine/metrics
    $metricsMap = @{}
    foreach ($line in $RawData) {
        [string[]]$lineParts = $line.Split(' ')

        if ($line -like '# HELP*') { # handle HELP lines: skip
            continue
        } elseif ($line -like '# TYPE*') { # handle TYPE lines: initialize dictionary metric key

            if ($lineParts.Count -ne 4) {
                throw "Encountered unexpected data format from ScriptEngine/metrics: $line"
            }

            $metricName = $lineParts[2]
            $metricType = $lineParts[3]

            # initialize a metric dict entry if not already created and is a member of the supported metrics list
            if (-not $metricsMap.ContainsKey($metricName) -and $checkedMetrics.Contains($metricName)) {
                $metricsMap[$metricName] = [PSCustomObject]@{
                    type = $metricType
                }
            }

            continue
        }

        # handle data lines: collect data under metric key
        $metricName = $metricsMap.Keys | Where-Object { 
            
            # match line with initialized key
            $lineParts[0] -like "$_*" 
        }
        
        # if not matched skip the line: unchecked metric
        if (-not $metricName) {
            continue
        }

        $metricValue = $lineParts[1]
        if ($metricsMap[$metricName].type -in @('gauge', 'counter')) {
            
            # simply add the line value for gauge and counter metrics
            $metricsMap[$metricName] | Add-Member -NotePropertyName value -NotePropertyValue $metricValue

        } elseif ($metricsMap[$metricName].type -eq 'histogram') {
            
            # optional histogram identifiers
            $scriptName = $null
            $leValue = $null  
            if ($lineParts[0].Contains('{') -and $lineParts[0].Contains('}')) {
                
                # try to extract identifiers script_name and le
                $contentStart = $lineParts[0].IndexOf('{') + 1
                $contentEnd = $lineParts[0].IndexOf('}')
                $content = $lineParts[0].Substring($contentStart, $contentEnd - $contentStart)

                foreach ($kvp in $content -split ',') {
                    $key, $value = $kvp.Split('=')
                    $key = $key.Trim()
                    $value = $value.Trim('"')

                    # script_name and le are the expected possible keys
                    if ($key -eq 'script_name') { $scriptName = $value }
                    elseif ($key -eq 'le') { $leValue = $value }
                }
            }
            
            # store line value according to line type (sum, count, bucket) and identifiers
            switch -wildcard ($lineParts[0]) {
                "${metricName}_sum*" {
                    $metricsMap = Update-HistogramEntry `
                        -metricsMap $metricsMap `
                        -metricName $metricName `
                        -lineType 'sum' `
                        -lineValue $metricValue `
                        -scriptName $scriptName
                }

                "${metricName}_count*" {
                    $metricsMap = Update-HistogramEntry `
                        -metricsMap $metricsMap `
                        -metricName $metricName `
                        -lineType 'count' `
                        -lineValue $metricValue `
                        -scriptName $scriptName
                }
                
                "${metricName}_bucket*" {
                    $metricsMap = Update-HistogramEntry `
                        -metricsMap $metricsMap `
                        -metricName $metricName `
                        -lineType 'bucket' `
                        -lineValue $metricValue `
                        -scriptName $scriptName `
                        -leValue $leValue
                }

                default { throw "Encountered unexpected data format from ScriptEngine/metrics: $_" }
            }
        }
    }

    return $metricsMap
}

function Get-ScriptEngineMetrics {
    [OutputType([string[]])]
    param ()

    $headers = @{ 'Accept' = 'application/openmetrics-text; version=1.0.0; charset=utf-8' }
    try {
        Write-Host "Fetching from $requestUri on $remoteMachineSE"

        # get raw data from remote: ScriptEngine/metrics
        $remoteResult = Invoke-Command -ComputerName $remoteMachineSE -ScriptBlock {
            return (
                Invoke-RestMethod -Uri $using:requestUri -Method Get -Headers $using:headers -TimeoutSec 15
            ) -split "`n"
        } -ErrorAction Stop

        return $remoteResult
    } catch {
        Write-Error "Error completing ScriptEngine/metrics request: $($_.Exception.Message)"

        return $null
    }
}
#endregion

#region helper functions
function TryParse-MetricMetaDataLine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Line,

        [Parameter(Mandatory = $true)]
        [hashtable]$InputMap 
    )

    # line is not a metadata line
    if (-not $line.StartsWith('#')) {
        return 
    }

    # regex patterns with named capture groups
    $patterns = @{
        Help = '# HELP (?<MetricName>\S+) (?<Help>.*)'
        Type = '# TYPE (?<MetricName>\S+) (?<Type>.*)'
    }

    switch -Regex ($line) {
        $patterns.Help {
            $metricName = $Matches.MetricName
            $metricHelp = $Matches.Help

            # assume HELP metadata precedes TYPE metadata of the same family
            $InputMap[$metricName] = @{ 
                Help = $metricHelp
                Type = 'unknown'
            }

            break
        }

        $patterns.Type {
            $metricName = $Matches.MetricName
            $metricType = $Matches.Type

            if (-not $InputMap.ContainsKey($metricName)) {
                $InputMap[$metricName] = @{}
            }

            $InputMap[$metricName].Type = $metricType
            
            break
        }
        
        default {
            Write-Warning "metadata line '$line' is not one of supported varieties ($( ($patterns.Keys) -join ', ' ))"
        }
    }
}

function Parse-MetricDataLine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Line,

        [hashtable]$HashInput
    )

}
#endregion

# fetch
$rawData = (Get-ScriptEngineMetrics) ?? ( Get-Content -Path 'C:\Users\alupica\OneDrive - Dolbey Systems, Inc\Desktop\metrics_output.txt' ) # TODO FOR TESTING: REMOVE RHS
if (-not $rawData) {
    $Status.StatusText = "Monitor failed to retrieve processing metrics data from the Script Engine on $remoteMachineSE"
    $Status.StatusID = 2

    return
}

# parse
try {
    $parsedData = Parse-ScriptEngineMetrics -RawData $rawData
} catch {
    Write-Host "$($_.Exception.Message)"
    $Status.StatusText = "Error parsing metrics data: $($_.Exception.Message)"
    $Status.StatusID = 2

    return
}

# log (if path given)
if ($PSBoundParameters.ContainsKey('LogPath')) {

}

# alert 
foreach ($Rule in $AlertRules) {
    Invoke-Alert -ParsedMetrics $ParsedMetrics -AlertRuleName $Rule.Name -AlertParameters $Rule
}

Write-Host 'Script Engine metrics monitoring completed'
