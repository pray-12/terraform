resource "aws_vpc" "myvpc" {
    cidr_block = var.main_cidr

    tags = {
        Name = "myvpc"
    }
}

resource "aws_subnet" "subnet_1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "subnet1"
    }
}

resource "aws_subnet" "subnet_2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "subnet2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id

    tags = {
        Name = "myigw"
    }
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "myrt"
    }

}

resource "aws_route_table_association" "subnet_association_1"{
    subnet_id = aws_subnet.subnet_1.id
    route_table_id =  aws_route_table.rt.id


}

resource "aws_route_table_association" "subnet_association_2"{
    subnet_id = aws_subnet.subnet_2.id
    route_table_id =  aws_route_table.rt.id

}

# Create a security group

resource "aws_security_group" "sg" {
    name = "my_security_group"
    description = "Allow SSH and HTTP traffic"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        description = "Allow SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "my_security_group"
    }
}

# Crete an EC2 instance

resource "aws_instance" "myinstance-1" {
    ami = "ami-07a00cf47dbbc844c"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_1.id
    security_groups = [aws_security_group.sg.id]
    user_data = base64encode(file("userdata.sh"))

    tags = {
        Name = "myinstance-1"
    }
}

resource "aws_instance" "myinstance-2" {
    ami = "ami-07a00cf47dbbc844c"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_2.id
    security_groups = [aws_security_group.sg.id]
    user_data = base64encode(file("userdata-2.sh"))

    tags = {
        Name = "myinstance-2"
    }
}

# Create a S3 bucket

resource "aws_s3_bucket" "mybucket" {
    bucket = "my-unique-bucket-name-12345-is-available-5-14-2026"
    acl = "private"

    tags = {
        Name = "mybucket"
    }
}

#  Create a load balancer

resource "aws_lb" "myalb" {
    name = "myalb"
    internal = false # private load balancer
    load_balancer_type = "application"
    security_groups = [aws_security_group.sg.id]
    subnets = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

    tags = {
        Name = "myalb"
    }
}

resource "aws_lb_target_group" "mytargetgroup" {
    name = "mytargetgroup"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.myvpc.id

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "mytargetgroup"
    }
}

resource "aws_lb_target_group_attachment" "mytargetgroupattachment1" {
    target_group_arn = aws_lb_target_group.mytargetgroup.arn
    target_id = aws_instance.myinstance-1.id
    port = 80
}

resource "aws_lb_target_group_attachment" "mytargetgroupattachment2" {
    target_group_arn = aws_lb_target_group.mytargetgroup.arn
    target_id = aws_instance.myinstance-2.id
    port = 80
}


resource "aws_lb_listener" "mylistener" {
    load_balancer_arn = aws_lb.myalb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.mytargetgroup.arn
    }
}

output "vpc_id" {
    value = aws_lb.myalb.arn
}