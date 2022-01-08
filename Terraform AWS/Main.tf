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
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(pathexpand("/home/pixel/Documents/Calein.pem"))
    host = aws_eip.EmmaX.public_ip
    }

  provisioner "remote-exec" {
  inline = [
  "sudo apt-get update",
  "sudo apt-get -f install apache2 -y",
  "sudo mv /var/www/index/index.html /var/www/index/index.html.default",
  ]
  }

  provisioner "file" {
    source = "/home/pixel/Indexes/index.html"
    destination = "/var/www/index/index.html"
  }
  provisioner "remote-exec" {
  inline = [
  "sudo service apache2 restart"
  ]

}
  tags = {
    Name = "SitePLSUpload"
  }
}