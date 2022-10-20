resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.public_subnet_cidr_block
    availability_zone = var.avail_zone

    tags = {
        Name: "${var.env_prefix}-public-subnet-1"
    }
}

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.private_subnet_cidr_block
    availability_zone = var.avail_zone

    tags = {
        Name: "${var.env_prefix}-private-subnet-1"
    }
}


# for public subnet
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

    tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# for private subnet
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.myapp-igw]
  tags = {
    Name: "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id

  # must be in the public subnet
  subnet_id = aws_subnet.public-subnet-1.id

  tags = {
    Name = "Main NAT Gateway"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

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
    Name = "${var.env_prefix}-public-rtb"
  }
}


resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

#   route {
    # cidr_block = var.vpc_cidr_block
    # gateway_id = aws_internet_gateway.example.id
#   }

  route {
    # ipv6_cidr_block        = "::/0"
    cidr_block= "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
    # egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "${var.env_prefix}-private-rtb"
  }
}



resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}