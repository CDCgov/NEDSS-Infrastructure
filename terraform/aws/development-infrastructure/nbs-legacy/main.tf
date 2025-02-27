# Prerequisites
# 1. Create key-pair in account if desired (leaving blank is untested)

# NBS application server
module "app_server" {
  count = var.deploy_on_ecs ? 0 : 1
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.7"
  depends_on = [ aws_ssm_parameter.odse_user, aws_ssm_parameter.odse_pass, aws_ssm_parameter.rdb_user, aws_ssm_parameter.rdb_pass, aws_ssm_parameter.srte_user, aws_ssm_parameter.srte_pass]
  

  user_data_replace_on_change = true

  name                   = "${var.resource_prefix}-app-server"
  ami                    = var.ami
  ami_ssm_parameter      = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base"
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${module.app_sg.security_group_id}"]
  subnet_id              = var.subnet_ids[0]
  key_name               = var.ec2_key_name

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for NBS application server"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMReadOnlyAccess      =  "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  }

  tags = var.tags

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 100
    }
  ]

  ebs_block_device = [
    {
      device_name = "xvdj"
      encrypted   = true
      volume_type = "gp3"
      volume_size = 100
    }
  ]

  user_data = <<-EOT
<powershell>
Write-Verbose "NOTICE: turn off UAC"
reg.exe ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f 
            
#Format windows D drive
Initialize-Disk  -Number 1 -PartitionStyle "MBR"
New-Partition -DiskNumber 1  -UseMaximumSize -IsActive  -AssignDriveLetter
Format-Volume  -DriveLetter d -Confirm:$FALSE

#Disable windows firewall on instance
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Download and unzip deployment package
Copy-S3Object -BucketName "${var.artifacts_bucket_name}" -Key "nbs/${var.deployment_package_key}" -LocalFile D:\${var.deployment_package_key}
Expand-Archive -Path D:\${var.deployment_package_key} -DestinationPath D:\

# install AWS CLI and refresh Path
Start-Process msiexec.exe -Wait -ArgumentList '/i https://awscli.amazonaws.com/AWSCLIV2.msi /qn /norestart'
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ";" + [System.Environment]::GetEnvironmentVariable('Path','User')

# install sqlcmd
mkdir C:\executables\sqlcmd
Invoke-WebRequest -Uri https://github.com/microsoft/go-sqlcmd/releases/download/v1.8.2/sqlcmd-windows-amd64.zip -OutFile C:\executables\sqlcmd\sqlcmd-windows-amd64.zip
Expand-Archive C:\executables\sqlcmd\sqlcmd-windows-amd64.zip C:\executables\sqlcmd\
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\executables\sqlcmd", "Machine")

# Set WildFly Memory and JAVA_TOOL_OPTIONS
$env:JAVA_OPTS="-Xms${var.java_memory} -Xmx${var.java_memory} -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Xss4m"
$env:JAVA_OPTS="$env:JAVA_OPTS -Djava.net.preferIPv4Stack=true"
$env:JAVA_OPTS="$env:JAVA_OPTS -Djboss.modules.system.pkgs=org.jboss.byteman"
$env:JAVA_TOOL_OPTIONS="-Dsun.stdout.encoding=cp437 -Dsun.stderr.encoding=cp437"

# Obtain parameters from parameter store
$odse_user = $(aws ssm get-parameter --name ${aws_ssm_parameter.odse_user.name} --with-decryption | ConvertFrom-Json).parameter.value
$odse_pass = $(aws ssm get-parameter --name ${aws_ssm_parameter.odse_pass.name} --with-decryption | ConvertFrom-Json).parameter.value
$rdb_user = $(aws ssm get-parameter --name ${aws_ssm_parameter.rdb_user.name} --with-decryption | ConvertFrom-Json).parameter.value
$rdb_pass = $(aws ssm get-parameter --name ${aws_ssm_parameter.rdb_pass.name} --with-decryption | ConvertFrom-Json).parameter.value
$srte_user = $(aws ssm get-parameter --name ${aws_ssm_parameter.srte_user.name} --with-decryption | ConvertFrom-Json).parameter.value
$srte_pass = $(aws ssm get-parameter --name ${aws_ssm_parameter.srte_pass.name} --with-decryption | ConvertFrom-Json).parameter.value

#Initialize hastable for data sources
$connectionURLs = @{ "NedssDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_odse";                     
                     "MsgOutDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_msgoute";                     
                     "ElrXrefDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_msgoute";                     
                     "RdbDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=rdb";                    
                     "SrtDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_srte"}

$connectionURLs_user = @{ "NedssDS" = "$odse_user";                     
                          "MsgOutDS" = "$odse_user";                    
                          "ElrXrefDS" = "$odse_user";                     
                          "RdbDS" = "$rdb_user";                     
                          "SrtDS" = "$srte_user"}

$connectionURLs_pass = @{ "NedssDS" = "$odse_pass";                     
                          "MsgOutDS" = "$odse_pass";                     
                          "ElrXrefDS" = "$odse_pass";                     
                          "RdbDS" = "$rdb_pass";                     
                          "SrtDS" = "$srte_pass"}

# Set environment variables thatdon't go away if server reboots or stopped and restarted
[Environment]::SetEnvironmentVariable("JAVA_HOME", "D:\wildfly-10.0.0.Final\Java\jdk8u412b08", "Machine")
[Environment]::SetEnvironmentVariable("JBOSS_HOME", "D:\wildfly-10.0.0.Final", "Machine")
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\executables\sqlcmd;D:\wildfly-10.0.0.Final\Java\jdk8u412b08\bin", "Machine")
[Environment]::SetEnvironmentVariable("JAVA_OPTS", $env:JAVA_OPTS, "Machine")
[Environment]::SetEnvironmentVariable("JAVA_TOOL_OPTIONS", $env:JAVA_TOOL_OPTIONS, "Machine")

# Set local variables for use in script
$env:JAVA_HOME="D:\wildfly-10.0.0.Final\Java\jdk8u412b08"
$env:JBOSS_HOME="D:\wildfly-10.0.0.Final"
$env:Path=$env:Path + ";D:\wildfly-10.0.0.Final\Java\jdk8u412b08\bin"

#Replace datasources in standalone.xml file
$xmlFileName = "D:\wildfly-10.0.0.Final\nedssdomain\configuration\standalone.xml"

#Create a XML document
[xml]$xmlDoc = New-Object system.Xml.XmlDocument

#Read the existing XML file
[xml]$xmlDoc = Get-Content $xmlFileName

#Search and replace db host name, user, pass in connection URL
$subsystems = $xmlDoc.server.profile.subsystem
$subsystems | ForEach-Object { 
  if ($_.xmlns -eq "urn:jboss:domain:datasources:4.0") {
    $datsources = $_.datasources.datasource
    $datsources | ForEach-Object {
      if ( $connectionURLs.ContainsKey($_.'pool-name')) {
        $_.'connection-url' =  $connectionURLs[$_.'pool-name']
        $_.security.'user-name' = $connectionURLs_user[$_.'pool-name']
        $_.security.password = $connectionURLs_pass[$_.'pool-name']
      }
    }    
  }
}

#Save XML file after connection url replacement
$xmlDoc.Save($xmlFileName)

# Update static BatchFiles
# covid19ETL.bat

$setenvFilePath = "$env:JBOSS_HOME\nedssdomain\Nedss\BatchFiles\covid19ETL.bat"
$currentContent = Get-Content -Path $setenvFilePath

$setEchoOff = "@echo off"
$setDATABASE_ENDPOINT = "set DATABASE_ENDPOINT=${var.nbs_db_dns}"
$setrdb_user = "set rdb_user=$rdb_user"
$setrdb_pass = "set rdb_pass=$rdb_pass"
$newContent = $setEchoOff, $setDATABASE_ENDPOINT, $setrdb_user, $setrdb_pass, $currentContent
$newContent | Set-Content -Path $setenvFilePath

#Install wildfly windows service   
Set-Location -Path "D:\wildfly-10.0.0.Final\bin\service"
.\service.bat install 

#Set service to start automatically and start the service
#Set-Service Wildfly -StartupType Automatic
sc.exe config Wildfly start= delayed-auto

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

########### Windows Task Scheduler NBS Recurring Start Check
$jobname = "NBS Recurring Start Check"
$scriptPath = "D:\wildfly-10.0.0.Final\nedssdomain\log\auto-start.ps1"
$repeat = (New-TimeSpan -Minutes 5)
$currentDate= ([DateTime]::Now)
#Windows doesn't like infinite duration, setting it for max 25 years
$duration = $currentDate.AddYears(25) -$currentDate
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType S4U
#Configure Task Action
$action = New-ScheduledTaskAction –Execute "Powershell.exe" -Argument "$scriptPath; quit"
#Configure Task Trigger
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat -RepetitionDuration $duration
#Configure Task Settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
#Create Scheduled Task
Register-ScheduledTask -TaskName $jobName -Action $action -Trigger $trigger -Principal $principal -Settings $settings

########### NBS Specific Windows Scheduled Tasks

$env:scheduledTaskCsvFile="D:\nbsScheduledTasks.csv"
Add-Content -Path $env:scheduledTaskCsvFile -Value "filename,scriptPathFromWorkDir,startTime,frequencyDays,frequencyHours,frequencyMinutes"

$env:scheduledTaskCsv="${var.windows_scheduled_tasks}"
if ($null -ne $env:scheduledTaskCsv -and $env:scheduledTaskCsv -ne "") {
    Add-Content -Path $env:scheduledTaskCsvFile -Value ($env:scheduledTaskCsv.split(';').replace('"','').replace('''','') | ForEach-Object {$_.Trim()})
}

# Import new csv file and update
$csvDataUpdated = Import-Csv -Path $env:scheduledTaskCsvFile

# Set Work dir
$WorkingDirectory = "$env:JBOSS_HOME\nedssdomain\Nedss\BatchFiles"

# Modify Triggers
foreach ($row in $csvDataUpdated) { 
    Write-Output "Adding Task: $row.filename"

    $days=[int]$row.frequencyDays
    $hours=[int]$row.frequencyHours
    $minutes=[int]$row.frequencyMinutes
    $jobName = $row.filename
    $repeat = (New-TimeSpan -Days $days -Hours $hours -Minutes $minutes)
    $currentDate= ([DateTime]::Now)
    $duration = $currentDate.AddYears(25) -$currentDate

    # Define the file path    
    $filename = $row.filename
    $filename_noext = $filename.split('.')[0]
    $scriptPathFromWorkDir = ".\" + $row.scriptPathFromWorkDir + $row.filename
    $argument = "> " + $filename_noext + ".output 2>&1"
    
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType S4U
    # Action to run the specified batch file
    $action = New-ScheduledTaskAction -Execute "$scriptPathFromWorkDir" -Argument "$argument" -WorkingDirectory "$WorkingDirectory"
    # Trigger for daily execution once, repeating every 2 minutes
    $trigger = New-ScheduledTaskTrigger -Once -At $row.startTime -RepetitionInterval $repeat -RepetitionDuration $duration
    # Create scheduled task
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
    # Register the scheduled task
    Register-ScheduledTask -TaskName $jobName -Action $action -Trigger $trigger -Principal $principal -Settings $settings

    Write-Output "Scheduled task $WorkingDirectory\" + $row.scriptPathFromWorkDir + $row.filename
}

################ END OF TASK SCHEDULES ###############################################################

Start-Service Wildfly
Restart-Computer -Force
</powershell>
EOT   
}

# Add in-line IAM role for EC2 access to shared services bucket
resource "aws_iam_role_policy" "shared_s3_access" {
  count = var.deploy_on_ecs || var.local_bucket ? 0 : 1
  name = "${var.resource_prefix}-cross-account-s3-access-policy"
  role = module.app_server[0].iam_role_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.artifacts_bucket_name}"
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = "${var.kms_arn_shared_services_bucket}"
      },
    ]
  })

  depends_on = [module.app_server]
}
