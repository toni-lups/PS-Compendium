#############################################################
# ADT - Test Generator
# Date 1/12/2026
# Generate random account data based on the fields below
#############################################################

#region Variables
$numAccountsCreate = 5
$destinationAdtPort = 7500
$destinationAdtIp = '127.0.0.1'
$acctNumberPrepend = 'AUTO_RUST'
$withSleepMS = 1000

$gender = 'M', 'F' 
$maleName = @( 
    'Blake', 'Jason', 'Brandon', 'Kevin', 'Adam', 
    'Thomas', 'Jack', 'Brian', 'Ryan', 'Henry', 'Bob',
    'Anthony', 'Samuel', 'Joseph', 'Benjamin', 'Daniel', 
    'Ethan', 'Jacob', 'Dave', 'Allen', 'Tim', 'Fred', 
    'Ted', 'Charles', 'Arthur', 'Mark', 'Michael', 'Steven', 
    'Jim', 'Eric', 'Sean', 'Frank', 'Gary', 'James', 'Jeff', 'Brent', 
    'George', 'Robert', 'William', 'Christopher', 'Ronald', 
    'Donald', 'Barry', 'Harry', 'Larry', 'Jerry', 'Quinton', 
    'Bart', 'Leroy', 'John', 'Doug', 'Paul', 'Winston', 'Donald', 
    'August'
) 

$femaleName = @( 
    'Isabelle', 'Julia', 'Alice', 'Ruby', 'Sarah', 
    'Lucille', 'Stella', 'Anna', 'Audrey', 'Alexa', 
    'Natalie', 'Aubrey', 'Victoria', 'Ella', 'Grace', 
    'Amelia', 'Patty', 'Emily', 'Alison', 'Stephanie', 
    'Carol', 'Betty', 'Viola', 'Julie', 'Samantha', 
    'Jill', 'Melissa', 'Mary', 'Sally', 'Susan', 'Erica', 
    'Shelly', 'Linda', 'Toni', 'Yolanda', 'Beatrice', 'Bonnie', 
    'Sharon', 'Jennifer', 'Becky', 'Wendy', 'Heather', 
    'Diana', 'Theresa', 'Christi', 'Sara', 'Margaret', 
    'Kathy', 'Cynthia', 'Maggie', 'Delilah', 'Lucy'
)

$middleName = @(
    'Thistle', 'Zephyr', 'Nimbus', 'Quasar', 'Balthazar',
    'Eponine', 'Jupiter', 'Chrysanthemum', 'Moxie', 'Peregrine',
    'Fjord', 'Elonious', 'Zamboni', 'Calliope', 'Ignatius',
    'Indigo', 'Rhapsody', 'Saffron', 'Grover', 'Tiberius',
    'Valkyrie', 'Orchid', 'Nebula', 'Draco', 'Cornelius',
    'Azriel', 'Echo', 'Banjo', 'Sagan', 'Juniper', 'Laurence', 'Cosmopolitan',
    'Thanos', 'Pumpernickel', 'Tatooine'
)

$lastName = @( 
    'Hughes', 'Watson', 'Duncan', 'Bell', 'Turner', 
    'Green', 'Campbell', 'Woods', 'Young', 'Martin', 
    'Lewis', 'White', 'Anderson', 'Davis', 'Hall', 
    'Moore', 'Thompson', 'Clark', 'Wilson', 'Taylor', 
    'Baker', 'Miller', 'Snyder', 'Williamson', 'Robertson', 
    'Jones', 'Wilson', 'Jackson', 'Brown', 'Smith', 'Ericsson', 
    'Robinson', 'Williams', 'Johnson', 'Gibson', 'Jefferson', 
    'Stevenson', 'Thornhill', 'Webster', 'Rawlings', 'Wilkinson', 
    'Snodgrass', 'Cartwright', 'Cunningham', 'Rockefeller',
    'Mazzolini'
)

 
$patientClass = 'I', 'E', 'O' 
$patientType = 'C', 'N', 'Y', 'Z', 'U', 'D', 'L'

$admitReason = @(
    [PSCustomObject]@{ Code = 'R06.02'; Description = 'Shortness of Breath' },
    [PSCustomObject]@{ Code = 'R10.9'; Description = 'Abdominal Pain' },
    [PSCustomObject]@{ Code = 'Q05.1'; Description = 'Thoracic Spina Bifida without Hydrocephalus' },
    [PSCustomObject]@{ Code = 'B97.4'; Description = 'Respiratory Syncytial Virus Infection' },
    [PSCustomObject]@{ Code = 'R07.9'; Description = 'Chest Pain' },
    [PSCustomObject]@{ Code = 'M25.531'; Description = 'Right Wrist Pain' },
    [PSCustomObject]@{ Code = 'N18.6'; Description = 'End Stage Renal Disease (ESRD)' },
    [PSCustomObject]@{ Code = 'J96.9'; Description = 'Respiratory Failure' },
    [PSCustomObject]@{ Code = 'A41.9'; Description = 'Sepsis, Unspecified' },
    [PSCustomObject]@{ Code = 'Q21.1'; Description = 'Atrial Septal Defect' },
    [PSCustomObject]@{ Code = 'R55'; Description = 'Syncope and Collapse' },
    [PSCustomObject]@{ Code = 'Q39.3'; Description = 'Atresia of Esophagus without Fistula' },
    [PSCustomObject]@{ Code = 'R19.7'; Description = 'Diarrhea, Chills, Weakness' },
    [PSCustomObject]@{ Code = 'L97.5'; Description = 'Non-healing Diabetic Ulcer' },
    [PSCustomObject]@{ Code = 'R41.82'; Description = 'Altered Mental Status' },
    [PSCustomObject]@{ Code = 'A04.7'; Description = 'Clostridium difficile Infection (C. Diff)' },
    [PSCustomObject]@{ Code = 'R06.02'; Description = 'Shortness of Breath' },
    [PSCustomObject]@{ Code = 'R11'; Description = 'Nausea and Vomiting' },
    [PSCustomObject]@{ Code = 'H68.029'; Description = 'Other Disorder of Eustachian Tube, Bilateral' },
    [PSCustomObject]@{ Code = 'E46'; Description = 'Malnutrition, Unspecified' },
    [PSCustomObject]@{ Code = 'I50.9'; Description = 'Congestive Heart Failure (CHF)' },
    [PSCustomObject]@{ Code = 'R10.9'; Description = 'Abdominal Pain with ERCP' },
    [PSCustomObject]@{ Code = 'N18.9'; Description = 'Chronic Kidney Disease, Unspecified' },
    [PSCustomObject]@{ Code = 'J18.9'; Description = 'Pneumonia, Unspecified Organism' },
    [PSCustomObject]@{ Code = 'I48.91'; Description = 'Unspecified Atrial Fibrillation' },
    [PSCustomObject]@{ Code = 'R03.0'; Description = 'Abnormal Blood Pressure Reading' },
    [PSCustomObject]@{ Code = 'R68.12'; Description = 'Fussiness in Infant/Child' },
    [PSCustomObject]@{ Code = 'R09.02'; Description = 'Hypoxia' },
    [PSCustomObject]@{ Code = 'W59.22'; Description = 'Struck by a Turtle' },
    [PSCustomObject]@{ Code = 'H25.9'; Description = 'Cataract, Unspecified' },
    [PSCustomObject]@{ Code = 'K63.5'; Description = 'Colon Polyps' },
    [PSCustomObject]@{ Code = 'E10.10'; Description = 'DKA with Dehydration' },
    [PSCustomObject]@{ Code = 'R50.9'; Description = 'Fever' },
    [PSCustomObject]@{ Code = 'M21.161'; Description = 'Unspecified Deformity of Right Lower Leg' },
    [PSCustomObject]@{ Code = 'M25.561'; Description = 'Traumatic Knee Pain' },
    [PSCustomObject]@{ Code = 'S06.9X1'; Description = 'Head Injury' },
    [PSCustomObject]@{ Code = 'K43.2'; Description = 'Incisional Hernia without Obstruction or Gangrene' },
    [PSCustomObject]@{ Code = 'J96.9'; Description = 'Respiratory Failure' },
    [PSCustomObject]@{ Code = 'N17.9'; Description = 'Acute Renal Failure with Hyperkalemia' },
    [PSCustomObject]@{ Code = 'E78.5'; Description = 'Hyperlipidemia, Unspecified' },
    [PSCustomObject]@{ Code = 'J18.9'; Description = 'Admission Reason: Pneumonia' },
    [PSCustomObject]@{ Code = 'J44.9'; Description = 'Chronic Obstructive Pulmonary Disease, Unspecified' },
    [PSCustomObject]@{ Code = 'I48.91'; Description = 'Unspecified Atrial Fibrillation' },
    [PSCustomObject]@{ Code = 'G80.9'; Description = 'Cerebral Palsy (CP)' },
    [PSCustomObject]@{ Code = 'Q74.0'; Description = 'Acquired Clubhand' }

    <# add elements for more possible admit diagnoses #>
)

$facility = 'Dolbey_Memorial_North', 'Dolbey_West', 'Dolbey_North', 'Dolbey_South', 'Dolbey', 'Dolbey_Memorial_South' 
$payor = 'MEDICARE', 'MEDICAID', 'UNITED_HEALTHCARE', 'BLUE_CROSS', 'BLUE_SHIELD', 'MEDICARE/MEDICAID', 'AMERITAS' 
$admitSource = '7', '2', '1', 'A' 
$room = @( 
    '100', '101', '102', '103', '104', '105', '106',
    '107', '108', '200', '201', '202', '203', '204', 
    '205', '206', '207', '208', '300', '301', '302', 
    '303', '304', '305', '306', '307', '308', '400', 
    '401', '402', '403', '404', '405', '406', '407', 
    '408', '500', '501', '502', '503', '504'
)

$bed = 'A', 'B', 'C', 'D' 
$hospitalService = 'MED', 'CARD', 'INTMED', 'Renal', 'URO', 'SPS', 'SPP', 'CCS', 'ELP'

# message types to create, if others are added some data might need to be changed based on what scripts are supposed to do
$messageType = 'A04', 'A08' #,'A01','A02','A03','A04','A05','A06','A07','A08','A11','A12','A13','A13','A17','A24','A31','A34','Z44','Z47'

#region FolderWatcher
$createPDF = $false # pull pdf and put in folder for folder watcher interface testing
$pdfInterfaceFolder = 'c:\interfaces\pdf\'

# doctypes for documents, can add to this list to create additional doc type names
$doctypes = @('HP', 'CardiacCath', 'OperativeNotes', 'Consult', 'ProgressNotes', 'Echocardiogram')

# full path to pdf file
if ($createPDF) {
    $sourceFile = Get-ChildItem $pdfInterfaceFolder\*.pdf
}
#endregion
#endregion

$fieldsToRandomize = [ordered]@{ # items prerequisite to others should appear first in list
    gender          = $gender
    patientType     = $patientType
    patientClass    = $patientClass
    facility        = $facility
    payor           = $payor
    admitReason     = $admitReason
    admitSource     = $admitSource
    room            = $room
    bed             = $bed
    hospitalService = $hospitalService
    messageType     = $messageType
    middleName      = $middleName
    lastName        = $lastName
    firstName       = (
        ( $maleName | ForEach-Object { [PSCustomObject]@{ Name = $_; Gender = 'M' } } ) +
        ( $femaleName | ForEach-Object { [PSCustomObject]@{ Name = $_; Gender = 'F' } } )
    )
}

#region Functions
function With-Noise {
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()] 
        [string]$valueDefault,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$valueNoise, 

        [ValidateRange(1, 100)]
        [int]$noiseChancePercent = 10
    )

    $resolvedValue = if ( (Get-Random -Minimum 1 -Maximum 101) -le $noiseChancePercent ) {
        $valueNoise
    } else {
        $valueDefault
    }

    return $resolvedValue
}
 
function Randomize-Template {
    [OutputType([string])]
    param()

    $hl7TemplateResult = $hl7Template
    
    # remember replacements so later fields can depend on earlier
    $replacementsHistory = @{}

    foreach ($fieldKey in $fieldsToRandomize.Keys) {

        $randResult = [string]::Empty

        switch ($fieldKey) {
            'gender' {
                $randResult = With-Noise -valueDefault (
                    $fieldsToRandomize[$fieldKey] | Get-Random
                ) -valueNoise 'U' -noiseChancePercent 1

                break
            }

            'patientClass' {
                $randResult = With-Noise -valueDefault (
                    $fieldsToRandomize[$fieldKey] | Get-Random
                ) -valueNoise 'U' -noiseChancePercent 1

                break
            }

            'admitReason' {
                $admitReasonObj = $fieldsToRandomize[$fieldKey] | Get-Random

                # code goes into {admitReason}
                $randResult = $admitReasonObj.Code

                # description goes into {admitReasonDescription}
                $hl7TemplateResult = $hl7TemplateResult -ireplace `
                    [regex]::Escape('{admitReasonDescription}'), `
                    $admitReasonObj.Description

                break
            }

            'firstName' {
                if (-not $replacementsHistory.ContainsKey('gender') -or $replacementsHistory['gender'] -eq 'U') {
                    $randResult = ($fieldsToRandomize[$fieldKey] | Get-Random).Name; break
                }

                if ($replacementsHistory['gender'] -eq 'M') {
                    $randResult = (
                        $fieldsToRandomize[$fieldKey] |
                            Where-Object { $_.Gender -eq 'M' } |
                            Get-Random
                    ).Name
                } else {
                    $randResult = (
                        $fieldsToRandomize[$fieldKey] |
                            Where-Object { $_.Gender -eq 'F' } |
                            Get-Random
                    ).Name
                }

                break
            }

            default {
                $randResult = $fieldsToRandomize[$fieldKey] | Get-Random
                break
            }
        }

        # record + replace token in template
        $replacementsHistory[$fieldKey] = $randResult
        $hl7TemplateResult = $hl7TemplateResult -ireplace [regex]::Escape("{$fieldKey}"), $randResult
    }

    return $hl7TemplateResult
}

function Connect-TcpClientWithTimeout {
    param(
        [Parameter(Mandatory)] [string] $Hostname,
        [Parameter(Mandatory)] [int] $Port,
        [int] $ConnectTimeoutMs = 5000
    )

    $client = New-Object System.Net.Sockets.TcpClient
    [IAsyncResult] $iar = $client.BeginConnect($Hostname, $Port, $null, $null)

    if (-not $iar.AsyncWaitHandle.WaitOne($ConnectTimeoutMs)) {
        $client.Close()
        
        throw "TCP connect timeout after ${ConnectTimeoutMs}ms to $Hostname`:$Port"
    }

    $client.EndConnect($iar)
    $client.NoDelay = $true
    
    return $client
}

function Read-MllpMessageWithTimeout {
    param(
        [Parameter(Mandatory)] [System.IO.Stream] 
        $Stream,
        
        [int] $ReadTimeoutMs = 8000
    )

    <#
        MLLP: defines message boundaries for HL7 over TCP:
        start: VT (0x0B)
        end: FS (0x1C) + CR (0x0D)
    #>
    $VT = 0x0B
    $FS = 0x1C
    $CR = 0x0D

    $Stream.ReadTimeout = $ReadTimeoutMs

    $memStream = New-Object System.IO.MemoryStream
    $buf = New-Object byte[] 1

    # Wait for VT
    while ($true) {
        $numBytes = $Stream.Read($buf, 0, 1)  # throws on timeout

        if ($numBytes -le 0) { throw 'Remote closed connection while waiting for MLLP start.' }
        if ($buf[0] -eq $VT) { break }
    }

    # Read until FS CR
    $prevWasFS = $false
    while ($true) {
        $numBytes = $Stream.Read($buf, 0, 1)
        if ($numBytes -le 0) { throw 'Remote closed connection while reading MLLP message.' }

        $b = $buf[0]
        if ($prevWasFS -and $b -eq $CR) {
            break
        }

        if ($b -eq $FS) {
            $prevWasFS = $true
            continue
        }

        $prevWasFS = $false
        [void] $memStream.WriteByte($b)
    }

    return [System.Text.Encoding]::ASCII.GetString($memStream.ToArray())
}

function Get-Hl7Field {
    param(
        [Parameter(Mandatory)] 
        [string]$SegmentLine,
        
        [Parameter(Mandatory)]
        [int]$FieldNumber
    )

    # HL7 fields are 1-based after segment name. Example: "MSA|AA|123" => field 1="AA", field 2="123"
    $parts = $SegmentLine -split '\|', -1
    $idx = $FieldNumber  # because parts[0] is segment name
    
    if ($idx -ge 0 -and $idx -lt $parts.Length) { 
        return $parts[$idx] 
    }
    
    return $null
}

function Send-Hl7MllpRobust {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MllpPayload,
        [Parameter(Mandatory)] [string] $Hostname,
        [Parameter(Mandatory)] [int] $Port,
        [Parameter(Mandatory)] [string] $ExpectedMessageControlId,  # your $messageId (MSH-10)
        [int] $PreSleepMS = $( if ($withSleepMS) { $withSleepMS } else { 0 } ),

        # Error handling parameters
        [int] $ConnectTimeoutMs = 5000,
        [int] $WriteTimeoutMs = 5000,
        [int] $AckTimeoutMs = 8000,
        [int] $MaxRetries = 3
    )

    $bytes = [System.Text.Encoding]::ASCII.GetBytes($MllpPayload)
    $attempt = 0
    $lastErr = $null

    if ($PreSleepMs -gt 0) {
        Start-Sleep -Milliseconds $PreSleepMs
    }

    while ($attempt -le $MaxRetries) {
        $attempt++
        $client = $null
        $stream = $null
        
        try {
            $client = Connect-TcpClientWithTimeout -Hostname $Hostname -Port $Port -ConnectTimeoutMs $ConnectTimeoutMs
            $client.SendTimeout = $WriteTimeoutMs
            $client.ReceiveTimeout = $AckTimeoutMs

            $stream = $client.GetStream()
            $stream.WriteTimeout = $WriteTimeoutMs

            # Send
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush()

            # Read HL7 ACK (MLLP framed)
            $ackHl7 = Read-MllpMessageWithTimeout -Stream $stream -ReadTimeoutMs $AckTimeoutMs

            # Find MSA line
            $msaLine = ($ackHl7 -split '(\r\n|\n|\r)') | Where-Object { $_ -like 'MSA|*' } | Select-Object -First 1
            if (-not $msaLine) { throw "No MSA segment found in ACK. Raw ACK: $ackHl7" }

            $msa1 = Get-Hl7Field -SegmentLine $msaLine -FieldNumber 1  # AA/AE/AR
            $msa2 = Get-Hl7Field -SegmentLine $msaLine -FieldNumber 2  # should match original MSH-10

            if ($msa2 -ne $ExpectedMessageControlId) {
                throw "ACK MSA-2 '$msa2' did not match expected message id '$ExpectedMessageControlId'."
            }

            if ($msa1 -ne 'AA') {
                throw "Received non-accept ACK (MSA-1='$msa1') for message '$ExpectedMessageControlId'. Raw ACK: $ackHl7"
            }

            return [pscustomobject]@{
                Success  = $true
                Attempt  = $attempt
                AckCode  = $msa1
                AckMsgId = $msa2
                AckRaw   = $ackHl7
            }
        } catch {
            $lastErr = $_
            if ($attempt -gt $MaxRetries) { break }

            $retryDelayMs = 500 * [Math]::Pow(2, $attempt - 1) # retry delay from base delay and attempt number
            Start-Sleep -Milliseconds ([Math]::Min($retryDelayMs, 5000)) # sleep for computed delay, or to a maximum delay
        } finally {
            if ($stream) { $stream.Dispose() }
            if ($client) { 
                $client.Close(); 
                $client.Dispose() 
            }
        }
    }

    throw "Send/ACK failed after $($MaxRetries + 1) attempts. Last error: $($lastErr.Exception.Message)"
}


$itr = 0
do {
    $itr++

    # produce random boilerplate account information
    $acctNum = "$acctNumberPrepend-$(New-Guid)"
    $mrnNum = (Get-Random -Minimum 10000 -Maximum 99999)
    $messageDate = (Get-Date).ToString('yyyyMMddhhmmssff')
    $birthDate = (Get-Date).
    AddDays( - (Get-Random -Maximum 31)).
    AddYears( - (Get-Random -Maximum 101)).
    ToString('yyyyMMddhhmm')
    
    $admitDateObj = (Get-Date).AddDays( - (Get-Random -Min 1 -Maximum 40))
    $admitDate = $admitDateObj.ToString('yyyyMMddhhmm')

    # create a d/c date (sometimes), some range of days after admit date
    $dischargeDate = With-Noise -valueDefault '' -valueNoise (
        $admitDateObj.AddDays((Get-Random -Min 0 -Maximum 7)).ToString('yyyyMMddhhmm')
    ) -noiseChancePercent 20
    
    # hl7 template with replaceable template field values
    $hl7Template = (
        "MSH|^~\&|REG|WMC|{facility}|WMC|$messageDate||ADT^{messageType}|{messageId}|||`r`n" +
        "PID|||$mrnNum||{lastName}^{firstName}^{middleName}^^^||$birthDate|{gender}||C||||||S||$acctNum|`r`n" +
        "PV1||{patientClass}|{facility}^{room}^{bed}|Admit Type|||00139^Person^Doctor^P^^^MD|||{hospitalService}||||{admitSource}|||00139^Person^Doctor^P^^^MD|{patientType}||SP||||||||||||||||d/c disp||||||||$admitDate|{dischargeDate}|||||`r`n" +
        "PV2|||^{admitReasonDescription}||`r`n" +
        "DG1||ICD10-CM|{admitReason}|{admitReasonDescription}||||||`r`n" +
        "IN1||^{payor}||{payor}||||||||||||||||||Payor ID|||||||||||||||||||||||`r`n"
    )

    # send adt message
    $messagePacket = ([char]11 + $(Randomize-Template) + [char]28 + [char]13) 
    $messageId = "M-$(New-Guid)"
    
    $messagePacketFormatted = $messagePacket `
        -ireplace [regex]::Escape('{dischargeDate}'), '' `
        -ireplace [regex]::Escape('{messageId}'), $messageId

    Write-Host "| Now working on iteration $($itr): $acctNum - $messageId |"
    Write-Host ("`nMessage packet:`n" + $messagePacketFormatted)
    try {
        $result = Send-Hl7MllpRobust `
            -MllpPayload $messagePacketFormatted `
            -Hostname $destinationAdtIp `
            -Port $destinationAdtPort `
            -ExpectedMessageControlId $messageId `
            -AckTimeoutMs 8000 `
            -MaxRetries 3
        
        Write-Host "[PASS] $acctNum ($messageId) ACK=$($result.AckCode) ATTEMPT=$($result.Attempt)`n" -ForegroundColor Green
        
        # if there is a d/c date, send additional message with d/c date
        if (-not [string]::IsNullOrEmpty($dischargeDate)) {
            $messageId_dc = "$($messageId)-DC" 
            
            Write-Host "Sending discharge message ($messageId_dc) ..."

            # send w/ discharge date (TODO add d/c disp)
            $messagePacketWithDischarge = $messagePacket `
                -ireplace [regex]::Escape('{dischargeDate}'), $dischargeDate `
                -ireplace [regex]::Escape('{messageId}'), $messageId_dc

            Send-Hl7MllpRobust `
                -MllpPayload $messagePacketWithDischarge `
                -Hostname $destinationAdtIp `
                -Port $destinationAdtPort `
                -ExpectedMessageControlId $messageId_dc `
                -AckTimeoutMs 8000 `
                -MaxRetries 3
        }
    } catch {
        Write-Host "[FAIL] $acctNum ($messageId) $_`n" -ForegroundColor Red
    }

    # if set to send to folder watcher then do the thing
    if ($createPDF) {
        Copy-Item $sourceFile (
            $pdfInterfaceFolder + (
                $sourceFile.Name.Replace('acct', $acctNum).Replace('doctype', (Get-Random $doctypes))
            )
        )
    }
} until ($itr -eq $numAccountsCreate)

