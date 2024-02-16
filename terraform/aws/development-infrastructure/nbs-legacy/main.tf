# Prerequisites
# 1. Create key-pair in account if desired (leaving blank is untested)

# NBS application server
module "app_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"
  count = var.deploy_on_ecs ? 0 : 1

  name                   = "${var.resource_prefix}-app-server"
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${module.app_sg.security_group_id}"]
  subnet_id              = var.subnet_ids[0]
  key_name               = var.ec2_key_name

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for NBS application server"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
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

  user_data = <<EOF
<powershell>
#Initialize hastable for data sources
$connectionURLs = @{ "NedssDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_odse";
                        "MsgOutDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_msgoute";
                        "ElrXrefDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_msgoute";
                        "RdbDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=rdb";
                        "SrtDS" = "jdbc:sqlserver://${var.nbs_db_dns}:1433;SelectMethod=direct;DatabaseName=nbs_srte"}
            
#Format windows D drive
Initialize-Disk  -Number 1 -PartitionStyle "MBR"
New-Partition -DiskNumber 1  -UseMaximumSize -IsActive  -AssignDriveLetter
Format-Volume  -DriveLetter d -Confirm:$FALSE

#Disable windows firewall on instance
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Download and unzip deployment package
Copy-S3Object -BucketName "${var.artifacts_bucket_name}" -Key "nbs/${var.deployment_package_key}" -LocalFile D:\${var.deployment_package_key}
Expand-Archive -Path D:\${var.deployment_package_key} -DestinationPath D:\

# Set environment variables thatdon't go away if server reboots or stopped and restarted 
[Environment]::SetEnvironmentVariable("JAVA_HOME", "D:\wildfly-10.0.0.Final\Java\jdk1.8.0_181", "Machine")
[Environment]::SetEnvironmentVariable("JBOSS_HOME", "D:\wildfly-10.0.0.Final", "Machine")
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";D:\wildfly-10.0.0.Final\Java\jdk1.8.0_181\bin", "Machine")

#Replace datasources in standalone.xml file
$xmlFileName = "D:\wildfly-10.0.0.Final\nedssdomain\configuration\standalone.xml"

#Create a XML document
[xml]$xmlDoc = New-Object system.Xml.XmlDocument

#Read the existing XML file
[xml]$xmlDoc = Get-Content $xmlFileName

#Search and replace db host name in connection URL
$subsystems = $xmlDoc. server.profile.subsystem
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

#Save XML file after connection url replacement
$xmlDoc.Save($xmlFileName)

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

########### DI app required task schedule
$jobName = "ELRImporter Task"
$repeat = (New-TimeSpan -Minutes 2)
$currentDate= ([DateTime]::Now)
$duration = $currentDate.AddYears(25) -$currentDate
# Define the file path
$scriptPath = "D:\wildfly-10.0.0.Final\nedssdomain\Nedss\BatchFiles\ELRImporter.bat"
$argument = ">ElrImporter.output"
$scriptDirPath = "D:\wildfly-10.0.0.Final\nedssdomain\Nedss\BatchFiles"
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType S4U
# Action to run the specified batch file
$action = New-ScheduledTaskAction -Execute "$scriptPath" -Argument "$argument" -WorkingDirectory "$scriptDirPath"
# Trigger for daily execution once, repeating every 2 minutes
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat -RepetitionDuration $duration
# Create scheduled task
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
# Register the scheduled task
Register-ScheduledTask -TaskName $jobName -Action $action -Trigger $trigger -Principal $principal -Settings $settings
################ END OF TASK SCHEDULES ###############################################################

Start-Service Wildfly
Restart-Computer -Force
</powershell>
EOF   
}

# Add in-line IAM role for EC2 access to shared services bucket
resource "aws_iam_role_policy" "shared_s3_access" {
  count = var.deploy_on_ecs ? 0 : 1
  name = "cross_account_s3_access_policy"
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