#AWS resource to create a VPC CIDR Block and to enable a DNS hostname to the instances
resource "aws_vpc" "boundary_db_demo_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "Boundary DB Demo Public VPC CIDR Block"
  }
}

# Create a Public subnet and assign to the VPC. The NAT gateway will be associated to this subnet
resource "aws_subnet" "boundary_db_demo_subnet" {
  vpc_id                  = aws_vpc.boundary_db_demo_vpc.id
  cidr_block              = var.aws_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Boundary DB Demo Public Subnet"
  }
}

resource "aws_subnet" "boundary_db_demo_subnet2" {
  vpc_id                  = aws_vpc.boundary_db_demo_vpc.id
  cidr_block              = var.aws_subnet_cidr2
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "Boundary DB Demo Public Subnet 2"
  }
}

# AWS resource to create the Internet Gateway
resource "aws_internet_gateway" "boundary_db_demo_ig" {
  vpc_id = aws_vpc.boundary_db_demo_vpc.id
  tags = {
    Name = "boundary-db-demo-igw"
  }
}

//AWS resource to create a route table with a default route pointing to the IGW

resource "aws_route_table" "boundary_db_demo_rt" {
  vpc_id = aws_vpc.boundary_db_demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.boundary_db_demo_ig.id
  }
  tags = {
    Name = "boundary-db-demo-rt"
  }

}

# AWS resource to associate the route table to the CIDR blocks created
resource "aws_route_table_association" "boundary_db_demo_rt_associate" {
  subnet_id      = aws_subnet.boundary_db_demo_subnet.id
  route_table_id = aws_route_table.boundary_db_demo_rt.id
}

resource "aws_route_table_association" "boundary_db_demo_rt_associate2" {
  subnet_id      = aws_subnet.boundary_db_demo_subnet2.id
  route_table_id = aws_route_table.boundary_db_demo_rt.id

}
