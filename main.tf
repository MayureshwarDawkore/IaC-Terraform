# Createing a new VPC 
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"
}


# Create an IGW and attach VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.VPC.id
}

# Create 2 subnets in diffrent AZ for the VPC
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

}

resource "aws_subnet" "main_subnet2" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

}

# Createing security group for traffic port 80
resource "aws_security_group" "SG" {
  name        = "main_security_group"
  description = "Allow inbound traffic on port 80"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

}

# Create two EC2 instances
resource "aws_instance" "EC2_1" {
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.SG.id]

  tags = {
    Name = "EC2_instance_1"
  }
}

resource "aws_instance" "EC2_2" {
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet2.id
  vpc_security_group_ids = [aws_security_group.SG.id]

  tags = {
    Name = "EC2_instance_2"
  }
}

# Create an ELB
resource "aws_lb" "ELB" {
  name               = "ELB"
  load_balancer_type = "application"
  subnets            = [aws_subnet.main_subnet.id, aws_subnet.main_subnet2.id]

  security_groups = [aws_security_group.SG.id]

  tags = {
    Name = "ELB"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ELB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "EC2_1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.EC2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "EC2_2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.EC2_2.id
  port             = 80
}

output "lb_dns_name" {
  value = aws_lb.ELB.dns_name
}

