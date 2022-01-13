#Internet GW
resource "aws_internet_gateway" "GWEmmaX" {
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
resource "aws_subnet" "SubnetEmmaX" {
  vpc_id            = aws_vpc.VPCEmmaX.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Subnet Calein"
  }
}


#Subnet -> Route table association
resource "aws_route_table_association" "RTAss" {
  subnet_id      = aws_subnet.SubnetEmmaX.id
  route_table_id = aws_route_table.RouteCalein.id
}


#NSG for ports 22,80,443
resource "aws_security_group" "AllowSSHHTTPHTTPS" {
  name        = "AllowSSHHTTPHTTPS"
  description = "Allow SSH, HTTP and HTTPS (customizable by all means with respect to the ports"
  vpc_id      = aws_vpc.VPCEmmaX.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
resource "aws_network_interface" "NetInterfaceEmmaX" {
  subnet_id       = aws_subnet.SubnetEmmaX.id
  private_ips     = ["10.10.1.50"]
  security_groups = [aws_security_group.AllowSSHHTTPHTTPS.id]
}

#Elastic IP (Tricky, but fun) for public address
resource "aws_eip" "EmmaX" {
  vpc                       = true
  network_interface         = aws_network_interface.NetInterfaceEmmaX.id
  associate_with_private_ip = "10.10.1.50"
  depends_on                = [aws_internet_gateway.GWEmmaX]
}

output "PublicIP_For_Site" {
  value       = aws_eip.EmmaX.public_ip
  description = "<--Public IP for the site instance"
}
