variable "name" {default = "dean-vpc"}
variable "cidr" { }

resource "aws_vpc" "dean-vpc" {

    cidr_block = "${var.cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {Name = "${var.name}"}
    lifecycle {create_before_destroy = true}

}

output "vpc_id" {value = "${aws_vpc.dean-vpc.id}"}
output "vpc_cidr" {value = "${aws_vpc.dean-vpc.cidr_block}" }
