provider "aws" {}

variable "cidr-block" {
    description = "cidr block"
    type = list(object({
        cidr-block = string
        name = string
    }))
}

resource "aws_vpc" "terra-vpc" { 
    cidr_block = var.cidr-block[0].cidr-block
    tags = {
        Name: var.cidr-block[0].name
    }
}

variable avail_zone {}


resource "aws_subnet" "terra-sub" {
    vpc_id = aws_vpc.terra-vpc.id
    cidr_block = var.cidr-block[1].cidr-block
    tags = {
        Name: var.cidr-block[1].name
    }
    availability_zone = var.avail_zone
}

data "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "terra-sub-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = var.avail_zone
}

resource "aws_subnet" "terra-sub-3" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "172.31.16.0/20"
    availability_zone = var.avail_zone
}

resource "aws_subnet" "terra-sub-4" {
    vpc_id = aws_vpc.terra-vpc.id
    cidr_block = "10.0.16.0/24"
    availability_zone = var.avail_zone
}

output dev-vpc-id {
  value       = aws_vpc.terra-vpc.id
}

output dev-subnet-id {
    value = aws_subnet.terra-sub-4.id
}
