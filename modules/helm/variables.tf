variable "eks_endpoint" {
  type        = string
  description = "EKS cluster endpoint"
}

variable "eks_certificate_authority_data" {
  type        = string
  description = "EKS certificate authority data"
}
