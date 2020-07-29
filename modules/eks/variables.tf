variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "private_subnets_ids" {
  type        = list
  description = "List of private subnets IDs in the VPC"
}
