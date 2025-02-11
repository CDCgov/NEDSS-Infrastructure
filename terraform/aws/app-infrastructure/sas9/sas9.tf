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

# Attach the AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_ssm_role_policy" {
  role       = aws_iam_role.sas_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance with IAM role and security group
resource "aws_instance" "sas9" {
  ami           = var.sas_ami # "ami-0599348d3e7f1a34e"  # SAS ami in shared services account. sas9.4-02-07-2025
  instance_type = var.sas_instance_type  # "t2.medium"
  key_name      = var.sas_keypair_name  # Create this key in the account before launching
  subnet_id = var.sas_subnet_id
  iam_instance_profile = aws_iam_instance_profile.sas_iam_profile.name
  vpc_security_group_ids      = [aws_security_group.sas_sg.name]
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
}
