provider "aws" {
  region = "us-east-1"
  access_key = "value"
  secret_key = "value"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "main"
  }
}

data "aws_availability_zones" "main_availbility_zone" {
  state = "available"
}
resource "aws_subnet" "public_1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.main_availbility_zone.names[0]
  tags = {
    "Name" = "public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.main_availbility_zone.names[1]
  tags = {
    "Name" = "public-2"
  }
}


resource "aws_subnet" "private_1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.main_availbility_zone.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name        = "private-1"

  }
}
resource "aws_subnet" "private_2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.4.0/24"
  availability_zone       = data.aws_availability_zones.main_availbility_zone.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name        = "private-2"

  }
}

resource "aws_internet_gateway" "igw_1"{
  vpc_id = "${aws_vpc.main.id}"
  tags = { 
    name = "Main_Gatway"
  } 
}

resource "aws_route_table" "route_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.3.0/24"
    gateway_id = aws_internet_gateway.igw_1.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw_1.id
  }

  tags = {
    Name = "main_route"
  }
}

resource "aws_route_table_association" "route_a_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.route_1.id
}

resource "aws_security_group" "ssh" {
    vpc_id = "${aws_vpc.main.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["10.0.1.0/24"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"

        cidr_blocks = ["10.0.1.0/24"]
    } 
}
resource "aws_network_interface" "niw" {
  subnet_id       = aws_subnet.private_1.id
  private_ips     = ["10.0.3.0"]
  security_groups = [aws_security_group.ssh.id]
}

resource "aws_eip" "eip_main"{
  vpc = true
  network_interface =  aws_network_interface.niw.id
  associate_with_private_ip = "10.0.3.0"


} 
variable "AMI" {    
    default = {
        eu-west-2 = "ami-03dea29b0216a1e03"
        us-east-1 = "ami-0c2a1acae6667e438"
    }
}
variable "AWS_REGION" {    
    default = "eu-west-2"
}

resource "aws_instance" "ec2_1" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_1.id}"
    key_name = "test"
    vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
    network_interface  { 
      device_index = 0
      network_interface_id = aws_network_interface.niw.id
    }
}

resource "aws_instace" "ec2_2" {
    ami = "${lookup(var.AMI, var.AWS_REGION)}"
    instance_type  = "t2.micro"
    subnet_id = "${aws_subnet.private_1.id}"
}

