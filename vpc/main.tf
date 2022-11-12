provider "aws" {


region = "us-east-1"

}


data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


resource "aws_vpc" "myvpc" {

cidr_block = "10.0.0.0/16"

tags = {
Name = "myvpc"
env = "Dev"
region = data.aws_region.current.name

}
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
   
  }
}

resource "aws_subnet" "pub1_subnet" {


vpc_id = aws_vpc.myvpc.id
cidr_block = "10.0.5.0/24"
availability_zone = data.aws_availability_zones.available.names[0]
tags = {
Name = "pub1_subnet"
}


}


resource "aws_subnet" "pub2_subnet" {


vpc_id = aws_vpc.myvpc.id
cidr_block = "10.0.6.0/24"
availability_zone = "${data.aws_availability_zones.available.names[1]}"
#"${data.aws_availability_zones.available.names[count.index]}"


tags = {

Name = "pub2-subnet"
azcode = data.aws_availability_zones.available.id

}
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }


tags = {

Name = "Public_rt"

}

}

resource "aws_route_table_association" "pubsubrt_assoc" {
  subnet_id      =  aws_subnet.pub1_subnet.id
#  subnet_id       = aws_subnet.pub2_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}


resource "aws_subnet" "priv1_subnet" {

vpc_id = aws_vpc.myvpc.id
cidr_block = "10.0.8.0/24"
#availability_zone = "${data.aws_availability_zones.names[3]}"

tags = {
Name = "priv1_subnet"
azcode = data.aws_availability_zones.available.id
}

}


resource aws_subnet "priv2_subnet" {
vpc_id = aws_vpc.myvpc.id 
cidr_block = "10.0.9.0/24"
#availability_zone = "${data.aws_availability_zones.names[4]}"

tags = {
Name = "priv2_subnet"
azcode = data.aws_availability_zones.available.id
}
}



resource "aws_nat_gateway" "mynatgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub1_subnet.id

  tags = {
    Name = "gwNAT"
  }

}

resource "aws_eip" "nat_eip" {


}


resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mynatgw.id
  }
tags = {
Name = "priv_rt"
}

}
resource "aws_route_table_association" "privrt_assoc" {
  subnet_id      = aws_subnet.priv1_subnet.id
  route_table_id = aws_route_table.priv_rt.id
}
