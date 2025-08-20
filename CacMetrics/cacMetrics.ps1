######################################################################################
# Polymon - Performance Monitoring
# Site - Covenant
# $Version - A1
# assumptions - prometheus-like format
#  - Lines starting with '#' are HELP/TYPE metadata
#  - TYPE comments are present in data, in the form "# TYPE METRIC_NAME METRIC_TYPE"
#  - metric names are constant, label names are constant
#  - whitespace is used to parse keys and values
#  - histogram bucket identifiers (script_name and le), are enclosed in curly
#  - Labels are key="value", values are numeric, labels enclosed in curly braces
######################################################################################

#region variables
$remoteComputer = 'FUSCAC2TEST01'
$url = 'http://127.0.0.1:5011/metrics'

$checkedMetrics = @( # list of metrics from ScriptEngine/metrics this script considers for alerting
    'process_cpu_seconds_total', # counter
    'process_num_threads', # gauge
    'cac_workflow_evaluation_script_in_progress', # gauge
    'cac_standard_workflow_accounts_in_progress', # gauge
    'cac_custom_workflow_accounts_in_progress', # gauge
    'cac_standard_workflow_account_duration', # histogram
    'cac_custom_workflow_account_duration', # histogram
    'cac_workflow_evaluation_script_duration' # histogram
)
#endregion

# convert /metrics response to a json-friendly object for ease of processing
function ConvertFrom-Response {
    [OutputType([PSCustomObject])]
    param (
        [string[]]$res
    )

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
    foreach ($line in $res) {
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

# get raw data from remote: ScriptEngine/metrics
# try {
#     $remoteResult = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
#         param($url)

#         return (Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10) -split "`n"
#     } -ArgumentList $url
# } catch {
#     $Status.StatusText = "Error completing ScriptEngine/metrics request: $($_.Exception.Message)"
#     $Status.StatusID = 2

#     return
# }

$remoteResult = Get-Content -Path 'C:\Users\alupica\OneDrive - Dolbey Systems, Inc\Desktop\metrics_output.txt' # TODO FOR TESTING: REMOVE
if (-not $remoteResult) {
    $Status.StatusText = "Warning: Script Engine metrics call returned no results"
    $Status.StatusID = 2

    return
}

# load raw data into structured dictionary
try {
    $structuredData = ConvertFrom-Response -res $remoteResult
} catch {
    Write-Host "$($_.Exception.Message)"
    $Status.StatusText = "Error parsing metrics data: $($_.Exception.Message)"
    $Status.StatusID = 2

    return
}

Write-Host $($structuredData | ConvertTo-Json -Compress:$false -Depth 10) # TODO FOR TESTING: REMOVE
