variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "public_subnets_ids" {
  type        = list
  description = "List containing the IDs of all created public subnets."
}

variable "node_security_group_id" {
  type        = string
  description = "ID of the Security Group used by the Kubernetes worker nodes."
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the Target Group pointing at the Kubernetes nodes."
}

variable "acm_certificate_arn" {
  type        = string
  description = "The certificate ARN in certificate manager"
}
