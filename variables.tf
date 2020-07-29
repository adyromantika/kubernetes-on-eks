variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "acm_certificate_arn" {
  type        = string
  description = "The certificate ARN in certificate manager"
}
