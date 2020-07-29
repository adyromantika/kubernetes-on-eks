# Automatically get the availability zones from the current region

data "aws_availability_zones" "availability_zones" {}

# Launch the VPC

module "vpc" {
  source  = "github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v2.44.0"

  name = "${var.project_name}"
  cidr = "10.0.0.0/16"

  azs              = data.aws_availability_zones.availability_zones.names
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  public_subnet_tags = merge(
    {"Name" = "public-${var.project_name}"},
    {"Tier" = "public"}
  )

  private_subnet_tags = merge(
    {"Name" = "private-${var.project_name}"},
    {"Tier" = "private"},
    {"kubernetes.io/cluster/${var.project_name}-eks" = "shared"}
  )

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}
