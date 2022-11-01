resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public-subnet-1" {
  count  = var.az_public_count
  vpc_id = aws_vpc.myapp-vpc.id
  # cidr_block = var.public_subnet_cidr_block
  cidr_block = cidrsubnet(aws_vpc.myapp-vpc.cidr_block, 8, count.index)
  # availability_zone = var.avail_zone
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name : "${var.env_prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnet-1" {
  count  = var.az_private_count
  vpc_id = aws_vpc.myapp-vpc.id
  # cidr_block = var.private_subnet_cidr_block
  cidr_block = cidrsubnet(aws_vpc.myapp-vpc.cidr_block, 8, var.az_private_count + count.index)
  # availability_zone = var.avail_zone
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name : "${var.env_prefix}-private-subnet-${count.index + 1}"
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
  vpc        = true
  count      = var.az_private_count
  depends_on = [aws_internet_gateway.myapp-igw]
  tags = {
    Name : "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.az_private_count
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)

  # must be in the public subnet
  subnet_id  = element(aws_subnet.public-subnet-1.*.id, count.index)
  depends_on = [aws_internet_gateway.myapp-igw]

  tags = {
    Name = "Main NAT Gateway"
  }
}

resource "aws_route_table" "public-route-table" {
  count  = var.az_public_count
  vpc_id = aws_vpc.myapp-vpc.id

  #   route {
  # cidr_block = var.vpc_cidr_block
  # gateway_id = aws_internet_gateway.example.id
  #   }

  route {
    # ipv6_cidr_block        = "::/0"
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_internet_gateway.myapp-igw.*.id, count.index)
    # egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "${var.env_prefix}-public-rtb"
  }
}


resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  count  = var.az_private_count

  #   route {
  # cidr_block = var.vpc_cidr_block
  # gateway_id = aws_internet_gateway.example.id
  #   }

  route {
    # ipv6_cidr_block        = "::/0"
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
    # egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "${var.env_prefix}-private-rtb"
  }
}



resource "aws_route_table_association" "public" {
  count          = var.az_public_count
  subnet_id      = element(aws_subnet.public-subnet-1.*.id, count.index)
  route_table_id = element(aws_route_table.public-route-table.*.id, count.index)
}


resource "aws_route_table_association" "private" {
  count          = var.az_private_count
  subnet_id      = element(aws_subnet.private-subnet-1.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}