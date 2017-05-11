#-------------------------------------------------------
# General
#-------------------------------------------------------

name = "dean-testing"
region = "eu-central-1"
environment = "dev"

#-------------------------------------------------------
# Network
#-------------------------------------------------------


vpc_cidr = "10.139.0.0/16"
azs = "eu-central-1a,eu-central-1b" #Region specific availability zones
private_subnets = "10.139.1.0/24" #Creating one private subnet per AZ
public_subnets = "10.139.11.0/24" #Creating one public subnet per AZ

# NAT

nat_instance_type = "t2.micro"

#-------------------------------------------------------
# Intances
#-------------------------------------------------------

servers = 2
