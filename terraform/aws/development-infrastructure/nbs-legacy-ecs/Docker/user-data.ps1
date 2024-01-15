# ./user-data.ps1
# Prepare NBS Configuration and Start NBS 6.0

# Initialize hastable for data sources
# NOTE: Provide RDS_ENDPOINT when running Container

$connectionURLs = @{
    "NedssDS" = "jdbc:sqlserver://RDS_ENDPOINT:1433;SelectMethod=direct;DatabaseName=nbs_odse";
    "MsgOutDS" = "jdbc:sqlserver://RDS_ENDPOINT:1433;SelectMethod=direct;DatabaseName=nbs_msgoute";
    "ElrXrefDS" = "jdbc:sqlserver://RDS_ENDPOINT:1433;SelectMethod=direct;DatabaseName=nbs_msgoute";
    "RdbDS" = "jdbc:sqlserver://RDS_ENDPOINT:1433;SelectMethod=direct;DatabaseName=rdb";
    "SrtDS" = "jdbc:sqlserver://RDS_ENDPOINT:1433;SelectMethod=direct;DatabaseName=nbs_srte"
}


$keys = $connectionURLs.Keys.Clone()

foreach ($key in $keys) {
    $connectionURLs[$key] = $connectionURLs[$key] -replace "RDS_ENDPOINT", $env:RDS_ENDPOINT
}

# Replace datasources in standalone.xml file
$xmlFileName = "C:\nbs\wildfly-10.0.0.Final\nedssdomain\configuration\standalone.xml"

# Create a XML document
[xml]$xmlDoc = New-Object system.Xml.XmlDocument

# Read the existing XML file
[xml]$xmlDoc = Get-Content $xmlFileName

# Search and replace db host name in connection URL
$subsystems = $xmlDoc.server.profile.subsystem
$subsystems | % {
    if ($_.xmlns -eq "urn:jboss:domain:datasources:4.0") {
        $datsources = $_.datasources.datasource
        $datsources | % {
            if ( $connectionURLs.ContainsKey($_.'pool-name')) {
                $_.'connection-url' =  $connectionURLs[$_.'pool-name']
            }
        }
    }
}

# Save XML file after connection url replacement
$xmlDoc.Save($xmlFileName)


############# WIN TASK SCHEDULES #################################################################
######## Upload script to D drive 
# PowerShell script content
$scriptContent = @'
$serviceName = "Wildfly"
# Check if the service is running
$serviceStatus = Get-Service -Name $serviceName
if ($serviceStatus.Status -ne "Running") {
    # If the service is not running, start it
    Start-Service -Name $serviceName
}
'@
$filePath = "D:\wildfly-10.0.0.Final\nedssdomain\log\auto-start.ps1"
$scriptContent | Out-File -FilePath $filePath -Force

########### DI app required task schedule
$jobName = "ELMReporter Task"
$repeat = (New-TimeSpan -Minutes 2)
$currentDate= ([DateTime]::Now)
$duration = $currentDate.AddYears(25) -$currentDate
# Define the file path
$scriptPath = "D:\wildfly-10.0.0.Final\nedssdomain\Nedss\BatchFiles\ELMReporter.bat"
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType S4U
# Action to run the specified batch file
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "$scriptPath; quit"
# Trigger for daily execution once, repeating every 2 minutes
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat -RepetitionDuration $duration
# Create scheduled task
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
# Register the scheduled task
Register-ScheduledTask -TaskName $jobName -Action $action -Trigger $trigger -Principal $principal -Settings $settings
################ END OF TASK SCHEDULES ###############################################################

Start-Process "C:\\nbs\\wildfly-10.0.0.Final\\bin\\standalone.bat" -Wait -NoNewWindow -PassThru | Out-Host
