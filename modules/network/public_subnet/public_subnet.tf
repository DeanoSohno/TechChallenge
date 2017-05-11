variable "name" {default = "public-dean"}
variable "vpc_id" { }
variable "public_subnets" { }
variable "azs" { }


resource "aws_internet_gateway" "public-dean" {

  vpc_id = "${var.vpc_id}"

  tags { Name = "${var.name}" }

}

resource "aws_subnet" "public-dean" {

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count = "${length(split(",", var.public_subnets))}"

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }

  map_public_ip_on_launch = true

}

resource "aws_route_table" "public-dean" {

    vpc_id = "${var.vpc_id}"

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public-dean.id}"
    }

    tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }

}

resource "aws_route_table_association" "public-dean" {

  count = "${length(split(",", var.public_subnets))}"
  subnet_id = "${element(aws_subnet.public-dean.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-dean.id}"
}

output "subnet_ids" { value = "${join(",", aws_subnet.public-dean.*.id)}" }
