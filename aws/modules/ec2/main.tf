locals {
  name_prefix = "${var.project}-${var.environment}"
}

# Security Group — 인바운드: SSH, HTTP, HTTPS / 아웃바운드: 전체 허용
resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-sg"
  description = "${local.name_prefix} EC2 Security Group"

  tags = {
    Name        = "${local.name_prefix}-sg"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.this.id
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ssh_allowed_cidrs[0]
}

resource "aws_vpc_security_group_ingress_rule" "ssh_extra" {
  count             = length(var.ssh_allowed_cidrs) > 1 ? length(var.ssh_allowed_cidrs) - 1 : 0
  security_group_id = aws_security_group.this.id
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ssh_allowed_cidrs[count.index + 1]
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.this.id
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.this.id
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# SSH Key Pair
resource "aws_key_pair" "this" {
  key_name   = "${local.name_prefix}-key"
  public_key = var.ssh_public_key

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Amazon Linux 2023 최신 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  # Docker + Docker Compose 설치
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker

    # Docker Compose 플러그인 설치
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # ec2-user를 docker 그룹에 추가
    usermod -aG docker ec2-user
  EOF

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name        = "${local.name_prefix}-server"
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# Elastic IP — 고정 퍼블릭 IP
resource "aws_eip" "this" {
  instance = aws_instance.this.id

  tags = {
    Name        = "${local.name_prefix}-eip"
    Project     = var.project
    Environment = var.environment
  }
}
