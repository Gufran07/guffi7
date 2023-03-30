# SUBNET Details
resource "aws_subnet" "myapp-sub" {
    vpc_id = var.vpc-id
    cidr_block = var.SUB-cidr-block
    tags = {
        Name: "${var.env_prefix}-sub"
    }
    availability_zone = var.avail_zone
}
# Internet Gateway Details
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc-id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}
# Associating Subnet and IGW in Default RTB
resource "aws_default_route_table" "DEF-RTB" {
    default_route_table_id = var.def-rtb
    route {
        cidr_block = var.IGW-cidr-block
        gateway_id = aws_internet_gateway.myapp-igw.id
    }    
    tags = {
        Name: "${var.env_prefix}-DEF-RTB"
    }
}