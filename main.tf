provider "aws" {
    region = "ap-south-1"
}
# contains all the variable

variable "VPC-cidr-block" {}
variable "SUB-cidr-block" {}
variable avail_zone {}
variable "env_prefix" {}
variable "IGW-cidr-block" {}
variable "my_ip" {}
variable "instance-type" {}
variable "key-name" {}
variable "pub-key-location" {}

# VPC Details
resource "aws_vpc" "myapp-vpc" { 
    cidr_block = var.VPC-cidr-block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

# SUBNET Details
resource "aws_subnet" "myapp-sub" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.SUB-cidr-block
    tags = {
        Name: "${var.env_prefix}-sub"
    }
    availability_zone = var.avail_zone
}

# Internet Gateway Details
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

# Creating a New route Table

/*resource "aws_route_table" "myapp-rtb" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = var.IGW-cidr-block
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}*/

# Associating subnet with new RTB

/*resource "aws_route_table_association" "sub-assoc" {
    subnet_id = aws_subnet.myapp-sub.id
    route_table_id = aws_route_table.myapp-rtb.id
}*/

# Associating Subnet and IGW in Default RTB

resource "aws_default_route_table" "DEF-RTB" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = var.IGW-cidr-block
        gateway_id = aws_internet_gateway.myapp-igw.id
    }    
    tags = {
        Name: "${var.env_prefix}-DEF-RTB"
    }
}

# Opening Inbound and Outbound Ports in default SG

resource "aws_default_security_group" "DEF-sg" {
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.IGW-cidr-block]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.IGW-cidr-block]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-DEF-sg"
    } 
}
# Creating ami for EC2 Instance

data "aws_ami" "lts-amazon-linux-img"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter{
        name = "virtualization-type"
        values = ["hvm"]
    }
}

/*output "aws_ami_id" {
  value = data.aws_ami.lts-amazon-linux-img.id
}*/

# Creating SSh entry
resource "aws_key_pair" "ssh-key" {
    key_name = var.key-name
    public_key = file(var.pub-key-location)
}

# Creating EC2 Instance

resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.lts-amazon-linux-img.id
    instance_type = var.instance-type
    subnet_id = aws_subnet.myapp-sub.id
    vpc_security_group_ids = [aws_default_security_group.DEF-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name
    user_data = file("entry-pt.sh")
    tags = {
        Name = "${var.env_prefix}-EC2"
    }
}
output "ec2_public_ip" {
    value = aws_instance.myapp-ec2.public_ip
 }
 output "aws_ec2_id" {
    value = aws_instance.myapp-ec2.id
 }
