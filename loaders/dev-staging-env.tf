variable "name" { }
variable "vpc_cidr" { }
variable "azs" { }
variable "public_subnets" { }
variable "private_subnets" { }

variable "nat_instance_type" { }
variable "region" { }
variable "servers" { }
variable "environment" { }

provider "aws" { region = "${var.region}" }

module "network" {
  source = "../modules/network"

  name = "${var.name}"
  public_subnets = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
  azs = "${var.azs}"
  vpc_cidr = "${var.vpc_cidr}"

}

module "compute" {
  source = "../modules/compute"

  name = "${var.name}"
  nat_instance_type = "${var.nat_instance_type}"
  region = "${var.region}"
  servers = "${var.servers}"
  azs = "${var.azs}"
  environment = "${var.environment}"
  vpc_id = "${module.network.vpc_id}"
  public_subnet_ids  = "${module.network.public_subnet_ids}"
  private_subnet_ids  = "${module.network.private_subnet_ids}"

}
