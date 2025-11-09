provider "aws" {
  region = "eu-central-1"
}

# Load local SSH key
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = file("${path.module}/k8s-key.pub")
}

# Custom VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "k8s-vpc"
  }
}

# Public subnet (master)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "k8s-public-subnet"
  }
}

# Private subnets (workers)
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index + 2)
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "k8s-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

# NAT Gateway for private subnets
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "k8s-nat"
  }
}

# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "k8s-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Route table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "k8s-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Security group
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Allow SSH, Kubernetes, HTTP/HTTPS"
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
<<<<<<< HEAD
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
=======
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    self      = true
>>>>>>> f2ab32fdb65281f72a145b9f4309d7ded6f4d189
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

# Kubernetes master (public subnet)
resource "aws_instance" "k8s_master" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
  }
}

# Kubernetes workers (private subnets)
resource "aws_instance" "k8s_worker" {
  count                       = 2
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.private[count.index].id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  key_name                    = aws_key_pair.k8s_key.key_name
  associate_public_ip_address = false

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}

# Outputs
output "master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_ips" {
  value = aws_instance.k8s_worker[*].private_ip
}
<<<<<<< HEAD
=======

>>>>>>> f2ab32fdb65281f72a145b9f4309d7ded6f4d189
