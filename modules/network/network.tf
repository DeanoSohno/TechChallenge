variable "name" { }
variable "vpc_cidr" { }
variable "azs" { }
variable "public_subnets" { }
variable "private_subnets" { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"

}

resource "aws_network_acl" "acl" {
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = ["${concat(split(",", module.public_subnet.subnet_ids), split(",", module.private_subnet.subnet_ids))}"]

  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags { Name = "${var.name}-all"}
}

module "public_subnet" {
  source = "./public_subnet"

  name = "${var.name}-public"
  vpc_id = "${module.vpc.vpc_id}"
  public_subnets = "${var.public_subnets}"
  azs = "${var.azs}"

}

module "private_subnet" {
  source = "./private_subnet"

  name = "${var.name}-private"
  vpc_id ="${module.vpc.vpc_id}"
  private_subnets = "${var.private_subnets}"
  azs = "${var.azs}"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"

}

module "nat" {
  source = "./nat"

  name = "${var.name}-nat"
  azs = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

# VPC
output "vpc_id"   { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${module.vpc.vpc_cidr}" }

# Subnets
output "public_subnet_ids"  { value = "${module.public_subnet.subnet_ids}" }
output "private_subnet_ids" { value = "${module.private_subnet.subnet_ids}" }

# NAT
output "nat_gateway_ids" { value = "${module.nat.nat_gateway_ids}" }
