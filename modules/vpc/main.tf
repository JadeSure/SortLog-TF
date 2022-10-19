resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone

    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id

    tags = {
    Name = "${var.env_prefix}-igw"
  }
}


resource "aws_route_table" "myapp-route-table" {
  vpc_id = var.vpc_id

#   route {
    # cidr_block = var.vpc_cidr_block
    # gateway_id = aws_internet_gateway.example.id
#   }

  route {
    # ipv6_cidr_block        = "::/0"
    cidr_block= "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
    # egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}