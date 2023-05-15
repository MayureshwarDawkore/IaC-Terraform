
# Createing a new VPC 
resource "aws_vpc" "vpc_main" {
  cidr_block = "10.0.0.0/16"
}


# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.vpc_main.id
}

# Create a subnet within the VPC
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1" 
}

# Create a security group for traffic on port 80
resource "aws_security_group" "SG" {
  name        = "main_security_group"
  description = "Allow inbound traffic on port 80"

  vpc_id = aws_vpc.vpc_main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create two EC2 instances
resource "aws_instance" "EC2_instance_1" {
  ami           = "ami-007855ac798b5175e" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.SG.id]

  tags = {
    Name = "EC2_instance_1"
  }
}

resource "aws_instance" "EC2_instance_2" {
  ami           = "ami-007855ac798b5175e"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.SG.id]

  tags = {
    Name = "EC2_instance_2"
  }
}
