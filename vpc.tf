// Create VPC
resource "aws_vpc" "dls-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "dls-vpc"
  }
}

// Create Public Subnet
resource "aws_subnet" "dls-pubsubnet" {
  vpc_id     = aws_vpc.dls-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "dls-pubsubnet"
  }
}

// Create Private Subnet
resource "aws_subnet" "dls-prisubnet" {
  vpc_id     = aws_vpc.dls-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "dls-prisubnet"
  }
}


// Create Elastic IP
resource "aws_eip" "dls-eip" {
  vpc      = true
}


// Create Public NAT
resource "aws_nat_gateway" "dls-nat" {
  allocation_id = aws_eip.dls-eip.id
  subnet_id     = aws_subnet.dls-pubsubnet.id

  tags = {
    Name = "dls-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dls-igw]
}


// Create IGW
resource "aws_internet_gateway" "dls-igw" {
  vpc_id = aws_vpc.dls-vpc.id

  tags = {
    Name = "dls-igw"
  }
}

// Create Public Route Tables
resource "aws_route_table" "dls-pubrt" {
  vpc_id = aws_vpc.dls-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dls-igw.id
  }

  tags = {
    Name = "dls-pubrt"
  }
}

// Route Table Association
resource "aws_route_table_association" "dls-rta" {
  subnet_id      = aws_subnet.dls-pubsubnet.id
  route_table_id = aws_route_table.dls-pubrt.id
}
