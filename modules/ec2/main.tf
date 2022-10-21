resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip_address]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    # any port is Okay
    from_port        = 0
    to_port          = 0
    # any
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    # allow to access VPC endpoint???
    prefix_list_ids = []
  }

  tags = { 
    Name = "${var.env_prefix}-sg"
  }
}

#  default security group
# resource "aws_default_security_group" "default-sg" {
#   name        = "myapp-sg"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = aws_vpc.myapp-vpc.id

#   ingress {
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = [var.my_ip_address]
#   }

#   ingress {
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     # any port is Okay
#     from_port        = 0
#     to_port          = 0
#     # any
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#     # allow to access VPC endpoint???
#     prefix_list_ids = []
#   }

#   tags = {
#     Name = "${var.env_prefix}-default-sg"
#   }
# }


# resource "aws_instance" "myapp-server" {
#   ami                       = data.aws_ami.latest-amazon-linux-image.id
#   instance_type             = "m5.large"
#   host_resource_group_arn   = "arn:aws:resource-groups:us-west-2:012345678901:group/win-testhost"
#   tenancy                   = "host"
# }

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  # filter {
  #   name = "name"
  #   values = ["Amazon Linux 2 AMI*"]
  # }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

}

resource "aws_instance" "myapp-server" {
  # ami                       = data.aws_ami.latest-amazon-linux-image.id
  ami = "ami-067e6178c7a211324"
  instance_type = var.instance_type
  #   subnet_id = module.myapp-subnet.subnet[0].id
  subnet_id = var.subnet_id
  vpc_security_group_ids =  [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  # associate a public IP address with an instance in a VPC
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  # user_data = file("./entry-script.sh")
               

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server"
  public_key = file(var.public_key_location)
}


resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = var.subnet_id
  route_table_id = var.route_table_id
}
