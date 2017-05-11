variable "nat_instance_type" { }
variable "vpc_id" { }
variable "name" { }
variable "region" { }
variable "servers" { }
variable "azs" { }
variable "environment" { }
variable "public_subnet_ids" { }
variable "private_subnet_ids" { }

// variable "public_subnet_ids" { default = "${module.public_subnet.subnet_ids}" }
// variable "private_subnet_ids" { default = "${module.private_subnet.subnet_ids}"}

resource "aws_security_group" "dean-web" {
  name = "dean-${var.environment}-web-firewall"
  description = "Firewall rules for the web server."
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "dean-web" {

  name = "dean-${var.environment}-alb-tg"
  port = 8080
  protocol = "http"
  vpc_id = "${var.vpc_id}"
}

resource "aws_elb" "dean-web" {
  name = "dean-${var.environment}-web-elb"
  subnets = ["${split(",", var.public_subnet_ids)}", "${split(",", var.private_subnet_ids)}"]

  listener {
    instance_port = 8080
    instance_protocol = "tcp"
    lb_port = 8080
    lb_protocol = "tcp"
  }

  health_check {
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  target              = "http:8080/"
  interval            = 30
  }
}

resource "aws_launch_configuration" "dean-web" {
  name_prefix = "dean-${var.environment}-launchconfig"
  security_groups = [ "${aws_security_group.dean-web.id}" ]

  image_id = "ami-7dd30d12"
  instance_type = "${var.nat_instance_type}"

  user_data = "${file("${path.module}/install_go.sh")}"

  key_name = "deankeystwo"
}

resource "aws_autoscaling_group" "dean-web" {

  vpc_zone_identifier = ["${split(",", var.private_subnet_ids)}", "${split(",", var.private_subnet_ids)}"]
  name = "dean-${var.environment}-asg"
  max_size = "${var.servers}"
  min_size = "${var.servers}"
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = "${var.servers}"
  force_delete = true
  target_group_arns = ["${aws_alb_target_group.dean-web.arn}"]
  wait_for_capacity_timeout = "5m"

  launch_configuration = "${aws_launch_configuration.dean-web.name}"

  load_balancers = ["${aws_elb.dean-web.id}"]

  lifecycle {
    create_before_destroy = true
  }

}

// Instance creation with count
// resource "aws_instance" "dean-instance" {
//
//   security_groups = ["${aws_security_group.dean-web.id}"]
//
//   subnet_id = "${var.public_subnet_ids}"
//   count = "${var.servers}"
//   key_name = "deankeystwo"
//
//   ami = "ami-7dd30d12"
//
//   instance_type = "${var.nat_instance_type}"
//
//   tags {
//     Name = "${var.name}-${var.environment}-${count.index}"
//   }
//
// }
