provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "vpc1" {
    cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "TVpc1"
  }
  }

  resource "aws_subnet" "sub1" {
    vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Publicsub1"
  }
}
  resource "aws_subnet" "sub2" {
    vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "privatesub2"
  }
  }
  resource "aws_subnet" "sub3" {
    vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "privatesub3"
  }
}
resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "Ig1"
  }
}
resource "aws_route_table" "rt1" {

   vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig1.id
  }

  tags = {
    Name = "pubsub"
  }
}

resource "aws_route_table" "rt2" {

   vpc_id = aws_vpc.vpc1.id

    tags = {
    Name = "privsub"
  }
}

resource "aws_route_table" "rt3" {

   vpc_id = aws_vpc.vpc1.id

    tags = {
    Name = "privsub"
  }
}
 
resource "aws_route_table_association" "attach1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_route_table_association" "attach2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "attach3" {
  subnet_id      = aws_subnet.sub3.id
  route_table_id = aws_route_table.rt3.id
}

resource "aws_security_group" "sgp" {
    vpc_id      = aws_vpc.vpc1.id
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }

     ingress {
    description      = "ssh"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "sg1"
  }
}
resource "aws_instance" "ec2public" {
  ami                     = var.ami_linux
  instance_type           = var.aws_instance_type
  subnet_id               = aws_subnet.sub1.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.sgp.id]
  key_name = "ansible"
  root_block_device {
    volume_size = 9
  }
}
resource "aws_instance" "ec2private" {
  ami                     = var.ami_linux
  instance_type           = var.aws_instance_type
  subnet_id               = aws_subnet.sub2.id
  associate_public_ip_address = "false"
  vpc_security_group_ids = [aws_security_group.sgp.id]
  key_name = "ansible"
  root_block_device {
    volume_size = 9
  }
 
}

