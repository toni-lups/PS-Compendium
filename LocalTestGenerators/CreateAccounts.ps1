############################################################################
# ADT - Test Generator
# Date 1/8/2026
# Generate random account data based on the fields below
############################################################################

#Requires -PSEdition Core

#region Variables
$numAccountsCreate = 100
$destinationAdtPort = 7500
$destinationAdtIp = '127.0.0.1' 
$acctNumberPrepend = 'AUTO'
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
    $replacementsHistory = @{} # keep a memory of replacements to give awareness for randomization

    foreach ($fieldKey in $fieldsToRandomize.Keys) {
        
        # introduce noise and do special-handling for applicable topics
        $randResult = [string]::Empty
        switch ($fieldKey) {
            # set $randResult within switch block
            'gender' {  
                $randResult = With-Noise -valueDefault (
                    $fieldsToRandomize[$fieldKey] | Get-Random
                ) -valueNoise 'U' -noiseChancePercent 1
                
                break
            } 'firstName' {
                if ( -not ($replacementsHistory.ContainsKey('gender')) || $replacementsHistory['gender'] -eq 'U') {
                    $randResult = ($fieldsToRandomize[$fieldKey] | Get-Random).Name
                    
                    break # no additional handling to perform
                }

                # choose name from selected gender
                $randResult = if ($replacementsHistory['gender'] -eq 'M') {
                    ($fieldsToRandomize[$fieldKey] 
                    | Where-Object { $_.Gender -eq 'M' }
                    | Get-Random).Name
                } else {
                    ($fieldsToRandomize[$fieldKey] 
                    | Where-Object { $_.Gender -eq 'F' }
                    | Get-Random).Name
                } 

                break
            } 'admitReason' {
                $admitReasonObj = ($fieldsToRandomize[$fieldKey] | Get-Random)

                # set rand result
                $randResult = $admitReasonObj.Code

                # replace in template the corresponding description
                $hl7TemplateResult = $hl7TemplateResult -ireplace [regex]::Escape('{admitReasonDescription}'), $admitReasonObj.Description

                break
            }
            
            default {
                # get random value for basic randomizable topic
                $randResult = ($fieldsToRandomize[$fieldKey] | Get-Random)
            }
        }

        # save to history
        $replacementsHistory.Add($fieldKey, $randResult)

        # replace determined value in template
        $hl7TemplateResult = $hl7TemplateResult -ireplace [regex]::Escape("{$fieldKey}"), $randResult
    }

    return $hl7TemplateResult
}

function Send-StringOverTcp ( 
    [Parameter(Mandatory = $True)]
    [string]$DataToSend,

    [Parameter(Mandatory = $True)]
    [string]$Hostname, 

    [Parameter(Mandatory = $True)]
    [UInt16]$Port,

    [int]$sleepMS = $withSleepMS ?? 0
) {
    Start-Sleep -Milliseconds $sleepMS

    try {
        $ErrorActionPreference = 'Stop'
        
        $destinationAdtIpEndpoint = New-Object Net.IPEndPoint([System.Net.IPAddress]::parse($destinationAdtIp), $Port)

        $TCPClient = [Net.Sockets.TcpClient]::new()
        $TCPClient.Connect($destinationAdtIpEndpoint)
        $NetStream = $TCPClient.GetStream()
        
        [Byte[]]$Buffer = [Text.Encoding]::ASCII.GetBytes($DataToSend)
        $NetStream.Write($Buffer, 0, $Buffer.Length)
        $NetStream.Flush()
    } finally {
        if ($NetStream) { $NetStream.Dispose() }
        if ($TCPClient) { $TCPClient.Dispose() }
    }
}
#endregion

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
    
    Write-Host " ---------------------------------------------------------- "
    Write-Host "  Now working on iteration $($itr): $acctNum - $admitDate   "
    Write-Host " ---------------------------------------------------------- "
    
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

    Write-Host "`nResult$(
        [string]::IsNullOrEmpty($dischargeDate) ? '' : (' (with d/c ' + $dischargeDate + ')')
    ):`n$messagePacketFormatted"

    Send-StringOverTcp -DataToSend $messagePacketFormatted -Hostname $destinationAdtIp -Port $destinationAdtPort

    # if there is a d/c date, send additional message with d/c date
    if (-not [string]::IsNullOrEmpty($dischargeDate)) { 
        # TODO add d/c disp
        
        # send w/ discharge date
        $messagePacketWithDischarge = $messagePacket `
            -ireplace [regex]::Escape('{dischargeDate}'), $dischargeDate `
            -ireplace [regex]::Escape('{messageId}'), "$($messageId)-DC"

        Send-StringOverTcp -DataToSend $messagePacketWithDischarge -Hostname $destinationAdtIp -Port $destinationAdtPort
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
