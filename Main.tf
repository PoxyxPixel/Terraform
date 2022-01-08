###########################################################################################

#AWS requirements
#VPC
#Internet Gateway
#Route Table
#Subnet
#Subnet /w Route Table association
#NSG for ports
#Net Interface
#Elastic IP for public IP address -> Shows the output of the AWS Instance
#Ubuntu with apache2 installed (custom site config)

###########################################################################################

#Terra Req (Well lemne, not needed )
terraform {
  required_version = ">= 0.12"
}


#VPC
resource "aws_vpc" "VPCEmmaX"{
    cidr_block = "10.10.0.0/16"
    tags = {
      Name = "EmmaX Calein"
    }
}


#Internet GW
resource "aws_internet_gateway" "GWEmmaX"{
  vpc_id = aws_vpc.VPCEmmaX.id
}


#Route Table
resource "aws_route_table" "RouteCalein" {
  vpc_id = aws_vpc.VPCEmmaX.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.GWEmmaX.id
  }

  tags = {
    Name = "Feint"
  }
}


#Subnet
resource "aws_subnet" "SubnetEmmaX"{
  vpc_id = aws_vpc.VPCEmmaX.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Subnet Calein"
  }
}


#Subnet -> Route table association
resource "aws_route_table_association" "RTAss"{
  subnet_id = aws_subnet.SubnetEmmaX.id
  route_table_id = aws_route_table.RouteCalein.id
}


#NSG for ports 22,80,443
resource "aws_security_group" "AllowSSHHTTPHTTPS" {
  name        = "AllowSSHHTTPHTTPS"
  description = "Allow SSH, HTTP and HTTPS (customizable by all means with respect to the ports"
  vpc_id      = aws_vpc.VPCEmmaX.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["79.113.84.160/32"]
  }

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["79.113.84.160/32"]
  }
    ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["79.113.84.160/32"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow-SSH-HTTP-HTTPS"
  }
}


#Net interface for subnet
resource "aws_network_interface" "NetInterfaceEmmaX"{
  subnet_id = aws_subnet.SubnetEmmaX.id
  private_ips = ["10.10.1.50"]
  security_groups = [aws_security_group.AllowSSHHTTPHTTPS.id]
}

#Elastic IP (Tricky, but fun) for public address
resource "aws_eip" "EmmaX"{
  vpc = true
  network_interface = aws_network_interface.NetInterfaceEmmaX.id
  associate_with_private_ip = "10.10.1.50"
  depends_on = [aws_internet_gateway.GWEmmaX]
}

output "PublicIP_For_Site" {
  value       = aws_eip.EmmaX.public_ip
  description = "<--Public IP for the site instance"
}


#Instance ---> Customized
resource "aws_instance" "ApacheStatic" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name = "Calein"
  network_interface{
    device_index = 0
    network_interface_id = aws_network_interface.NetInterfaceEmmaX.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install apache2 -y
              sudo systemctl start apache2
              EOF
  tags = {
    Name = "SitePLSUpload"
  }
}