# Create a VPC
resource "aws_vpc" "homelab_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CyberDefense VPC"
  }

}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.homelab_vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "CyberDefense Public Subnet"
  }

# Create Windows Instance.
resource "aws_instance" "windows" {
  ami                         = var.windows_ami_id
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.splunk_lab_key # Use the variable for the key pair name
  security_groups             = ["${aws_security_group.win-kali-security-group.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30 # Specify the desired size in GB
  }

  tags = {
    Name = "CyberDefense [Windows 10]"
  }

}

# Crate Kali  Instance.
resource "aws_instance" "kali" {
  ami           = var.kali_ami_id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.splunk_lab_key # Use the variable for the key pair name


  security_groups             = ["${aws_security_group.win-kali-security-group.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 12 # Specify the desired size in GB
  }

  tags = {
    Name = "CyberDefense [KaliLinux]"
  }

}

# Create Splunk Instance.
resource "aws_instance" "splunk-instance" {
  ami           = var.ubuntu_ami_id
  instance_type = "t2.large"
  subnet_id     = aws_subnet.public_subnet.id

  security_groups             = ["${aws_security_group.linux-security-tools.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30 # Specify the desired size in GB
  }

  tags = {
    Name = "CyberDefense [Splunk]"
  }

}

}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.homelab_vpc.id

  tags = {
    Name = "CyberDefense IGW"
  }

}

# Create Route Table
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.homelab_vpc.id

}

# Create Route to IGW in Route Table
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = "0.0.0.0/0" # Replace with your VPC CIDR block
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Route Table to Public Sunet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route-table.id
}

# Create Security Group for Windows 10 and Kali Linux Instances.
resource "aws_security_group" "win-kali-security-group" {
  name_prefix = "win-kali-"
  description = "Example security group allowing SSH, RDP, and ICMP"
  vpc_id      = aws_vpc.homelab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["11.11.11.11/32"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 # ICMP type and code (-1 means all)
    to_port     = -1 # ICMP type and code (-1 means all)
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CyberDefense / Kali Security Group"
  }

}

# Create Security Group for Splunk Instance.
resource "aws_security_group" "linux-security-tools" {
  name_prefix = "security-tools-"
  description = "Ingress and egress rules for Security Tools Box"
  vpc_id      = aws_vpc.homelab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 # ICMP type and code (-1 means all)
    to_port     = -1 # ICMP type and code (-1 means all)
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5900
    to_port     = 5920
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["11.11.11.11/32"]
  }

  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CyberDefense Splunk Security Group"
  }

}


# Output Windows IP Address.
output "instance_public_ip_win" {
  value = "Windows Instance IP Address: ${aws_instance.windows.public_ip}"
}

# Output Kali IP Address.
output "instance_public_ip_kali" {
  value = "Kali Instance IP Address: ${aws_instance.kali.public_ip}"
}

# Output Splunk IP Address.
output "instance_public_ip_splunk-instance" {
  value = "Splunk Instance IP Address: ${aws_instance.splunk-instance.public_ip}"
}
output "splunk_instance_id" {
  value = "Splunk Instance ID: ${aws_instance.splunk-instance.id}"
}