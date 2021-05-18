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
resource "aws_subnet" "public-1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.main_availbility_zone.names[0]
  tags = {
    "Name" = "public-1"
  }
}
resource "aws_internet_gateway" "public-gateway" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        Name = "public-gateway"
    }
}

resource "aws_subnet" "public-2" {
  availability_zone = data.aws_availability_zones.main_availbility_zone.names[1]


}


