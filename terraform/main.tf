provider "aws" {
  region = "eu-central-1"
}

# Load local SSH key
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = file("${path.module}/k8s-key.pub")
}

# Get latest Debian AMI
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian official AMI owner

  filter {
    name  = "name"
    values = ["debian-12-amd64-*"]
  }
}

# Get default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name  = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group for Kubernetes nodes
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Allow SSH, Kubernetes, and HTTP/HTTPS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    # This setting allows ingress traffic from any resource
    # that is also assigned to this specific Security Group.
    self = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

# Kubernetes master node
resource "aws_instance" "k8s_master" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.medium"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
  }

}

# Kubernetes worker nodes
resource "aws_instance" "k8s_worker" {
  count                       = 2
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.small"
  subnet_id                   = data.aws_subnets.default.ids[count.index % length(data.aws_subnets.default.ids)]
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }


}

# Output IPs
output "master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_ips" {
  value = aws_instance.k8s_worker[*].public_ip
}