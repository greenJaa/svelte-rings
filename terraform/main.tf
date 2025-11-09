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
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
}

# Create custom VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s-vpc"
  }
}

# Create subnets
resource "aws_subnet" "k8s_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.k8s_vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "k8s-subnet-${count.index + 1}"
  }
}

# Get availability zones
data "aws_availability_zones" "available" {}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s-igw"
  }
}

# Route Table
resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "k8s-rt"
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "k8s_rta" {
  count          = length(aws_subnet.k8s_subnet)
  subnet_id      = aws_subnet.k8s_subnet[count.index].id
  route_table_id = aws_route_table.k8s_rt.id
}

# Security group for Kubernetes nodes
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Allow SSH, Kubernetes, and HTTP/HTTPS"
  vpc_id      = aws_vpc.k8s_vpc.id

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
    self        = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
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
  subnet_id                   = aws_subnet.k8s_subnet[0].id
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
  subnet_id                   = aws_subnet.k8s_subnet[count.index % length(aws_subnet.k8s_subnet)].id
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
