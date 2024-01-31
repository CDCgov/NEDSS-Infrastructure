# Prerequisites
# 1. Create key-pair in account if desired (leaving blank is untested)
# 2. Used domain is assumed to exist

#locals on whether to create CSM
locals {
  #If create_cert == true set value to 1 and create CSM, otherwise do not create
  cert_count = var.create_cert ? 1 : 0
}

# get legacy VPC data
data "aws_vpc" "legacy_vpc" {
  id = var.legacy_vpc_id
}

# get modernized VPC data
data "aws_vpc" "modern_vpc" {
  id = var.modern_vpc_id
}

# NBS application server
module "app_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"
  count = var.deploy_on_ecs ? 0 : 1

  name                   = "${var.legacy_resource_prefix}-app-server"
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${module.app_sg.security_group_id}"]
  subnet_id              = var.private_subnet_ids[0]
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

Start-Service Wildfly
Restart-Computer -Force
</powershell>
EOF
    depends_on = [module.db]

}

# Security group for NBS application server
module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name         = "${var.legacy_resource_prefix}-app-sg"
  description  = "Security group for NBS application server"
  vpc_id       = var.legacy_vpc_id
  egress_rules = ["all-all"]

  # Open for ALB source security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 7001
      to_port                  = 7001
      protocol                 = "tcp"
      description              = "Wildfly web server"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  # Open for shared services and legacy VPC cidr block
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 7001
      to_port     = 7001
      protocol    = "tcp"
      description = "wildfly web server"
      cidr_blocks = "${var.shared_vpc_cidr_block},${data.aws_vpc.legacy_vpc.cidr_block},${data.aws_vpc.modern_vpc.cidr_block}"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "RDP access from cleint VPN"
      cidr_blocks = "${var.shared_vpc_cidr_block}"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 2
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

# Security group for NBS load balancer security group
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.legacy_resource_prefix}-alb-sg"
  description = "${var.legacy_resource_prefix} Security Group for ALB"
  vpc_id      = var.legacy_vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}


# Application load balancer for NBS application server
module "alb" {
  count = var.deploy_on_ecs ? 0 : 1
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.2"

  name = "${var.legacy_resource_prefix}-alb-ec2"

  load_balancer_type = "application"

  vpc_id          = var.legacy_vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [module.alb_sg.security_group_id]


  target_groups = [
    {
      name_prefix      = "lgcy-"
      backend_protocol = "HTTP"
      backend_port     = 7001
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/nbs/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }

      targets = {
        my_target = {
          target_id = module.app_server[0].id
          port      = 7001
        }
      }
    }
  ]

  https_listeners = [
    {
      port     = 443
      protocol = "HTTPS"
      # Use terraform create certificate or a precreated certificate
      certificate_arn    = try(module.acm[0].acm_certificate_arn, var.certificate_arn)
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

resource "aws_route53_record" "alb_dns_record" {
  count = var.deploy_on_ecs ? 0 : 1
  zone_id = var.zone_id
  name    = var.route53_url_name
  type    = "A"

  alias {
    name                   = module.alb[0].lb_dns_name
    zone_id                = module.alb[0].lb_zone_id
    evaluate_target_health = true
  }
}

# Security group for NBS backend RDS database server
module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name         = "${var.legacy_resource_prefix}-rds-sg"
  description  = "Security group for RDS instance"
  vpc_id       = var.legacy_vpc_id
  egress_rules = ["all-all"]

  # Open for application server source security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 1433
      to_port                  = 1433
      protocol                 = "tcp"
      description              = "MSSQL RDS instance access from EC2"
      source_security_group_id = module.app_sg.security_group_id
    }
  ]

  # Open for shared services and legacy VPC cidr block
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      description = "MSSQL RDS instance access from within VPCs"
      cidr_blocks = "${var.shared_vpc_cidr_block},${data.aws_vpc.legacy_vpc.cidr_block},${data.aws_vpc.modern_vpc.cidr_block}"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1

}

# NBS backend RDS database instance
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.2"

  identifier = "${var.legacy_resource_prefix}-rds-mssql"

  engine               = "sqlserver-se"
  engine_version       = "15.00"
  family               = "sqlserver-se-15.0" # DB parameter group
  major_engine_version = "15.00"             # DB option group
  instance_class       = var.db_instance_type

  //allocated_storage     = 20
  //max_allocated_storage = 100

  # Encryption at rest is not available for DB instances running SQL Server Express Edition
  storage_encrypted = true

  //username = "admin"
  //port     = 1433


  multi_az = false
  # db_subnet_group_name   = "legacy-db-subnet-group"
  # create DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.private_subnet_ids
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled = false
  create_monitoring_role       = false
  /*
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
*/
  options                   = []
  create_db_parameter_group = false
  license_model             = "license-included"
  character_set_name        = "SQL_Latin1_General_CP1_CI_AS"
  snapshot_identifier       = var.db_snapshot_identifier
  apply_immediately = var.apply_immediately
}

# Create certificate (this should be an optional resource with ability to provide arn if existing)
# Needs CNAME record in route53
module "acm" {
  count   = local.cert_count
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = var.zone_id

  # subject_alternative_names = [
  #   "*.my-domain.com",
  #   "app.sub.my-domain.com",
  # ]

  wait_for_validation = true
  validation_timeout  = "15m"
  tags                = var.tags
}

