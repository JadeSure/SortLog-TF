output "public_subnet" {
    value = aws_subnet.public-subnet-1
}

output "private_subnet" {
    value = aws_subnet.private-subnet-1
}


output "public_route_table" {
    value =  aws_route_table.public-route-table
}

output "private_route_table" {
    value = aws_route_table.private-route-table
}

output "myapp_vpc" {
    value = aws_vpc.myapp-vpc
}
   