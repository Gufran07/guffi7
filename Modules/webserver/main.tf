# Opening Inbound and Outbound Ports in default SG
resource "aws_default_security_group" "DEF-sg" {
    vpc_id = var.vpc_id
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
# Creating SSh entry
resource "aws_key_pair" "ssh-key" {
    key_name = var.key_name
    public_key = file(var.pub-keylocation)
}
# Creating EC2 Instance
resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.lts-amazon-linux-img.id
    instance_type = var.instance-type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_default_security_group.DEF-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name
    user_data = file("entry-pt.sh")
    tags = {
        Name = "${var.env_prefix}-EC2"
    }    
}