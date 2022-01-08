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

#VPC
resource "aws_vpc" "VPCEmmaX"{
    cidr_block = "10.10.0.0/16"
    tags = {
      Name = "EmmaX Calein"
    }
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