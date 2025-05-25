# VPC Module: main.tf

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-vpc"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-public-subnet-${count.index + 1}"
      "Tier" = "Public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index] # Ensure AZs align if creating NAT GW per AZ
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-private-subnet-${count.index + 1}"
      "Tier" = "Private"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-igw"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NAT Gateways (one per AZ for high availability)
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs) # Assuming one NAT GW per public subnet's AZ
  vpc   = true                            # Correct syntax is domain = "vpc" for TF > 0.12, but older aws provider might just need `vpc=true` or simply rely on association. For modern provider, use `domain = "vpc"`
  # domain = "vpc" # For newer provider versions

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-nat-eip-${count.index + 1}"
    }
  )
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs) # Create a NAT GW in each public subnet's AZ
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # NAT GW needs to be in a public subnet

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-nat-gw-${count.index + 1}"
    }
  )

  # Explicit dependency on the Internet Gateway is good practice
  depends_on = [aws_internet_gateway.main]
}

# Private Route Tables (one per private subnet, pointing to its respective NAT GW)
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    # Route traffic through the NAT Gateway located in the same AZ as the private subnet
    # This assumes a 1:1 mapping of private subnets to NAT GWs based on AZ index.
    nat_gateway_id = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id # Ensure this logic correctly maps AZs
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-private-rt-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
