provider "aws" {
    region = "ap-south-1"
}
# VPC Details
resource "aws_vpc" "myapp-vpc" { 
    cidr_block = var.VPC-cidr-block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}
module "myapp-subnet"{
    source = "./Modules/subnet"
    SUB-cidr-block = var.SUB-cidr-block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc-id = aws_vpc.myapp-vpc.id
    def-rtb = aws_vpc.myapp-vpc.default_route_table_id
    IGW-cidr-block = var.IGW-cidr-block
}
module "myapp-ec2-inst" {
    source = "./Modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    my_ip = var.my_ip
    key_name = var.key-name
    IGW-cidr-block = var.IGW-cidr-block
    env_prefix = var.env_prefix
    pub-keylocation = var.pub_key_location
    instance-type = var.instance-type
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone
}
 