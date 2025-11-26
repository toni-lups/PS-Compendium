###################################################
# Polymon - Script Engine Performance Monitoring
# $Version - 
# Assumptions - prometheus-like format
# TODO - add more key assumptions
###################################################

using namespace System.Collections.Generic

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage = 'provide a valid relative or absolute folder path')]
    [string]$LogPath
)

# --- variables ----
$remoteMachineSE = 'FUSCAC2TEST01'
$requestUri = 'http://127.0.0.1:5011/metrics'

$alertingRules = @(
    @{
        Name             = 'HighRequestRate'
        TargetMetricName = 'my_application_requests_total'
        TargetLabel      = 'instance'
        TargetLabelValue = 'app-server-01'
        Threshold        = 1000
    }
    
    # Add more monitor rules here
)

# --- models (PowerShell 5+) ---
class MetricPoint {
    [string]    $Name     # full name as read from line (e.g., http_request_duration_seconds_bucket)
    [string]    $BaseName # base name with suffix (kind) removed (e.g., http_request_duration_seconds)
    [string]    $Type     # from TYPE metadata
    [string]    $Kind
    [hashtable] $Labels   # labels (if any)
    [double]    $Value

    MetricPoint([string] $name, [hashtable]$labels = @{}, [double]$value) {
        # TODO implement
    }

    static [List[MetricPoint]] ParseLines([string[]]$Lines) {
        $points = [List[MetricPoint]]::new() 
        $meta = @{} # track metric metadata seperately (lines starting with '#')

        Write-Host 'Starting raw data parsing'
        foreach ($line in $Lines) {
            $line = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            # produce a metric point, or update metadata 
            Write-Verbose "Parsing metrics line: $line"
            $point = [MetricPoint]::FromLine($line, $meta)

            if ($point) { $points.Add($point) }  
        }

        Write-Host "Completed parsing of Script Engine metrics with $($points.Count) metrics"
        return $points
    }

    hidden static [MetricPoint] FromLine(
        [string]$line,
        [hashtable]$meta # in/out
    ) {
        if ($line.StartsWith('#')) { # update metadata

            # regex patterns with named capture groups
            $metaPatterns = @{
                Help = '# HELP (?<MetricName>\S+) (?<Help>.*)'
                Type = '# TYPE (?<MetricName>\S+) (?<Type>.*)'
            }

            switch -Regex ($line) {
                $metaPatterns.Help {
                    $metricName = $Matches.MetricName
                    $metricHelp = $Matches.Help

                    $meta[$metricName] = @{ 
                        Help = $metricHelp
                        Type = 'unknown'
                    }

                    return $null
                }

                $metaPatterns.Type {
                    $metricName = $Matches.MetricName
                    $metricType = $Matches.Type

                    if (-not $meta.ContainsKey($metricName)) {
                        $meta[$metricName] = @{}
                    }

                    $meta[$metricName].Type = $metricType
            
                    return $null
                }
        
                default {
                    Write-Warning "metadata line '$line' is malformed, or not one of supported varieties ($( ($metaPatterns.Keys) -join ', ' ))"
                    return $null
                }
            }
        } 

        # process a data line
        $labels = [MetricPoint]::ParseLabels($line)
        # TODO left off here
    }

    #--- helpers ---
    hidden static [hashtable] ParseLabels([string]$line) {  
        $result = @{} 

        $labelBoundLeft = $line.IndexOf('{')
        if ($labelBoundLeft -eq -1) { # no labels to take
            return @{}
        }

        $labelBoundRight = $line.IndexOf('}', $labelBoundLeft + 1)
        if (($labelBoundRight -eq -1) -or ($labelBoundRight -gt $labelBoundLeft)) {
            Write-Warning "Unable to parse labels from line: $line"
            return @{}
        }

        $content = $line.Substring($labelBoundLeft + 1, ($labelBoundRight - $labelBoundLeft) - 1)
        foreach ($kvp in ($content -split ',')) {
            $key, $val = $kvp -split '='

            # TODO left off here
        }

        return $result
    }
}

# --- monitor main ---

# 1) fetch
$rawData = (Get-ScriptEngineMetrics) ?? ( Get-Content -Path 'C:\Users\alupica\OneDrive - Dolbey Systems, Inc\Desktop\metrics_output.txt' ) # TODO FOR TESTING: REMOVE RHS
if (-not $rawData) {
    $Status.StatusText = "Monitor failed to retrieve processing metrics data from the Script Engine on $remoteMachineSE"
    $Status.StatusID = 2

    return
}

# 2) parse
try {
    $parsedData = Parse-ScriptEngineMetrics -RawData $rawData
} catch {
    Write-Host "$($_.Exception.Message)"
    $Status.StatusText = "Error parsing metrics data: $($_.Exception.Message)"
    $Status.StatusID = 2

    return
}

# 3) log (if path given)
if ($PSBoundParameters.ContainsKey('LogPath')) {

}

# 4) alert 
foreach ($Rule in $AlertRules) {
    Invoke-Alert -ParsedMetrics $ParsedMetrics -AlertRuleName $Rule.Name -AlertParameters $Rule
}

Write-Host 'Script Engine metrics monitoring completed'
