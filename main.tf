# Createing a new VPC 
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}
