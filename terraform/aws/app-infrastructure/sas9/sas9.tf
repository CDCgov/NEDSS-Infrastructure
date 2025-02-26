# provider "aws" {
#   region = "us-east-1"  # Change to your desired region
# }

# IAM Role for EC2 instance with SSM managed instance core policy
resource "aws_iam_role" "sas_role" {
  name               = "sas-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_ssm_role_policy" {
  role       = aws_iam_role.sas_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_readonly_role_policy" {
  role       = aws_iam_role.sas_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "sas_iam_profile" {
  name = "sas-iam-profile"
  role = aws_iam_role.sas_role.name
}

# Security Group to allow vpn and intra vpc traffic
resource "aws_security_group" "sas_sg" {
  name        = "sas-sg"
  description = "Allow vpn and intra vpc traffic"
  vpc_id = var.sas_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr_block] 
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
    Name = "sas-sg"
  }
}

# EC2 Instance with IAM role and security group
resource "aws_instance" "sas9" {
  ami           = var.sas_ami # "ami-0599348d3e7f1a34e"  # SAS ami in shared services account. sas9.4-02-07-2025
  instance_type = var.sas_instance_type  # "t2.medium"
  key_name      = var.sas_keypair_name  # Create this key in the account before launching
  subnet_id = var.sas_subnet_id
  iam_instance_profile = aws_iam_instance_profile.sas_iam_profile.name
  vpc_security_group_ids      = [aws_security_group.sas_sg.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size = var.sas_root_volume_size # 200         # The size of the root volume, which is 200GB in your case
    volume_type = "gp3"       # You can change this to another volume type (e.g., gp2, io1)
    encrypted   = true        # Enable encryption for the root volume
    kms_key_id  = var.sas_kms_key_id  # Reference the KMS key for encryption
  }
  tags = {
    Name = "SAS9.4"
  }

  user_data = <<-EOF
        #!/bin/bash

        # debug
        set -x

        # Set variables only if they are not already defined
        BACKUP=$${BACKUP:-true}
        SYSPREP=$${SYSPREP:-false}
        REPLACE=$${REPLACE:-true}
        RUN_SQL=$${RUN_SQL:-true}  # Control SQL execution (default: true)

        # Default values if parameters are missing
        DEFAULT_RDS_ENDPOINT="EXAMPLE-rds-endpoint"
        DEFAULT_SQL_USERNAME="EXAMPLE-DB"
        DEFAULT_SQL_PASSWORD="EXAMPLE-DB-PASS"
        DEFAULT_EXAMPLE_SAS_USERNAME="EXAMPLE-SAS-USER"
        DEFAULT_EXAMPLE_SAS_PASSWORD="EXAMPLE-SAS-PASS"

        # Ensure REPLACE is false if SYSPREP is true
        if [[ "$SYSPREP" == "true" ]]; then
            REPLACE=false
        fi

        FILES="/etc/systemd/system/sas_spawner.env /home/SAS/.odbc.ini /etc/odbc.ini /home/SAS/.bashrc /home/SAS/update_config.sql"

        TMP_DATE=$(date +%F-%H-%M)

        echo "running $0 at $(date)" > /tmp/$(basename $0).log.$${TMP_DATE}

        # Function to collect system information
        collect_system_info() {
            # Fetch RDS endpoint from Parameter Store
            RDS_ENDPOINT=$(aws ssm get-parameter --name "rds_endpoint" --query "Parameter.Value" --output text 2>/dev/null)

            # If RDS endpoint isn't found, try fetching it from AWS CLI
            if [[ -z "$RDS_ENDPOINT" ]]; then
                echo "rds_endpoint not found in Parameter Store, checking AWS RDS instances..."
                RDS_COUNT=$(aws rds describe-db-instances --query "length(DBInstances)" --output text 2>/dev/null)

                if [[ "$RDS_COUNT" -eq 1 ]]; then
                    RDS_ENDPOINT=$(aws rds describe-db-instances --query "DBInstances[0].Endpoint.Address" --output text 2>/dev/null)
                    echo "RDS endpoint found: $RDS_ENDPOINT"
                else
                    echo "Error: More than one RDS instance found or unable to retrieve RDS instance."
                    exit 1
                fi
            fi

            # Default RDS endpoint if all retrieval attempts fail
            RDS_ENDPOINT=$${RDS_ENDPOINT:-$DEFAULT_RDS_ENDPOINT}
            echo "Final RDS_ENDPOINT=$${RDS_ENDPOINT}"

            PRIVATE_IP=$(aws ec2 describe-instances --instance-id $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
            echo "PRIVATE_IP=$PRIVATE_IP"

            HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
            echo "HOSTNAME=$HOSTNAME"

            SQL_USERNAME=$(aws ssm get-parameter --name "sql_username" --query "Parameter.Value" --output text 2>/dev/null)
            SQL_USERNAME=$${SQL_USERNAME:-$DEFAULT_SQL_USERNAME}
            echo "SQL_USERNAME=$SQL_USERNAME"

            SQL_PASSWORD=$(aws ssm get-parameter --name "sql_password" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
            SQL_PASSWORD=$${SQL_PASSWORD:-$DEFAULT_SQL_PASSWORD}
            echo "SQL_PASSWORD retrieved"

            EXAMPLE_SAS_USERNAME=$(aws ssm get-parameter --name "example_sas_username" --query "Parameter.Value" --output text 2>/dev/null)
            EXAMPLE_SAS_USERNAME=$${EXAMPLE_SAS_USERNAME:-$DEFAULT_EXAMPLE_SAS_USERNAME}
            echo "EXAMPLE_SAS_USERNAME=$EXAMPLE_SAS_USERNAME"

            EXAMPLE_SAS_PASSWORD=$(aws ssm get-parameter --name "example_sas_password" --with-decryption --query "Parameter.Value" --output text 2>/dev/null)
            EXAMPLE_SAS_PASSWORD=$${EXAMPLE_SAS_PASSWORD:-$DEFAULT_EXAMPLE_SAS_PASSWORD}
            echo "EXAMPLE_SAS_PASSWORD retrieved"
        }

        # Function to rotate logs and reset shell history
        rotate_logs_and_clear_history() {
            echo "Rotating logs and clearing shell history..."

            # Rotate logs
            for log_file in /var/log/messages /var/log/syslog /var/log/auth.log /var/log/secure /var/log/sas/*; do
                if [[ -f "$log_file" ]]; then
                    mv "$log_file" "$log_file.$TMP_DATE"
                    touch "$log_file"
                    chmod 600 "$log_file"
                fi
            done

            # Reset shell history for key users
            for user in sas root ssm-user ec2-user; do
                home_dir=$(eval echo ~$user)
                if [[ -d "$home_dir" ]]; then
                    echo "Clearing history for user: $user"
                    cat /dev/null > "$home_dir/.bash_history"
                    history -c
                fi
            done

            # Ensure history is cleared from memory
            export HISTSIZE=0
        }

        # Collect system info only if REPLACE is true
        if [[ "$REPLACE" == "true" ]]; then
            collect_system_info
        fi

        # If SYSPREP is enabled, rotate logs and clear shell history
        if [[ "$SYSPREP" == "true" ]]; then
            #rotate_logs_and_clear_history
            echo not runnning rotate_logs_and_clear_history
        fi

        for TMP_FILE in $FILES; do
            if [[ "$BACKUP" == "true" ]]; then
                echo "Backing up $TMP_FILE"
                cp -p "$TMP_FILE" "$TMP_FILE.$TMP_DATE"
            fi

            echo "Restoring template file for $TMP_FILE"
            cp -p "$TMP_FILE.template" "$TMP_FILE"

            if [[ "$REPLACE" == "true" ]]; then
                echo "Replacing placeholders in $TMP_FILE"
                sed -i "s#<DB_ENDPOINT>#$RDS_ENDPOINT#g" "$TMP_FILE"
                sed -i "s#<PRIVATE_IP>#$PRIVATE_IP#g" "$TMP_FILE"
                sed -i "s#<HOSTNAME>#$HOSTNAME#g" "$TMP_FILE"
                sed -i "s#EXAMPLE_SAS_USERNAME#$EXAMPLE_SAS_USERNAME#g" "$TMP_FILE"
                sed -i "s#EXAMPLE_SAS_PASSWORD#$EXAMPLE_SAS_PASSWORD#g" "$TMP_FILE"
                sed -i "s#<USERNAME>#$SQL_USERNAME#g" "$TMP_FILE"
                sed -i "s#<PASSWORD>#$SQL_PASSWORD#g" "$TMP_FILE"
            else
                echo "Skipping placeholder replacements for $TMP_FILE (REPLACE=false)"
            fi
        done

        if [[ "$REPLACE" == "true" ]]; then
            # Execute SQL script if enabled
            if [[ "$RUN_SQL" == "true" ]]; then
                    echo "Executing SQL script... output in /tmp/sql.out.$TMP_DATE "
                    /opt/mssql-tools18/bin/sqlcmd -S "$RDS_ENDPOINT" -U "$SQL_USERNAME" -P "$SQL_PASSWORD" -i "/home/SAS/update_config.sql" -C > /tmp/sql.out.$TMP_DATE 2>&1
            else
                    echo "Skipping SQL execution (RUN_SQL=false)"
                    echo sqlcmd -S "$RDS_ENDPOINT" -U "$SQL_USERNAME" -P "$SQL_PASSWORD" -i "/home/SAS/update_config.sql" -C
            fi

            echo "restart SAS service"
            #systemctl stop sas_spawner.service; systemctl daemon-reload; systemctl start sas_spawner.service; systemctl status sas_spawner.service
            systemctl stop sas_spawner.service; systemctl daemon-reload; systemctl start sas_spawner.service
        fi
  EOF

}

