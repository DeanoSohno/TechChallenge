variable "name" {default = "private-dean"}
variable "vpc_id" { }
variable "private_subnets" { }
variable "azs" { }
variable "nat_gateway_ids" { }

resource "aws_subnet" "private-dean" {

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "eu-central-1b"
  count = "${length(split(",", var.private_subnets))}"

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }

  map_public_ip_on_launch = true

}

resource "aws_route_table" "private-dean" {

    vpc_id = "${var.vpc_id}"
    count = "${length(split(",", var.private_subnets))}"

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
    }

    tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }

}

resource "aws_route_table_association" "private-dean" {

  count = "${length(split(",", var.private_subnets))}"
  subnet_id = "${element(aws_subnet.private-dean.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private-dean.*.id, count.index)}"
}

output "subnet_ids" { value = "${join(",", aws_subnet.private-dean.*.id)}" }
