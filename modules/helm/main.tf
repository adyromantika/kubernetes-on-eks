provider "helm" {
  kubernetes {
    host     = var.eks_endpoint

    cluster_ca_certificate = base64decode(var.eks_certificate_authority_data)
  }
}
