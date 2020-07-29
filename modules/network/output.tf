# VPC ID to be used in the other parts of Terraform

output "vpc_id" {
  value = module.vpc.vpc_id
}

# Private subnet IDs as a list

output "private_subnets_ids" {
  value = module.vpc.private_subnets
}

# Public subnet IDs as a list

output "public_subnets_ids" {
  value = module.vpc.public_subnets
}
