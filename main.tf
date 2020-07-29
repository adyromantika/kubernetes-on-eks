terraform {
  backend "s3" {
    bucket = "kubernetes-on-eks"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.0"
}

# Launch the network infrastructure

module "network" {
  source = "./modules/network"

  project_name     = var.project_name
}

# Launch EKS

module "eks" {
  source = "./modules/eks"

  project_name         = var.project_name
  vpc_id               = module.network.vpc_id
  private_subnets_ids  = module.network.private_subnets_ids
}

# Launch ALB

module "alb" {
  source = "./modules/alb"

  project_name           = var.project_name
  vpc_id                 = module.network.vpc_id
  public_subnets_ids     = module.network.public_subnets_ids
  node_security_group_id = module.eks.node_security_group_id
  target_group_arn       = module.eks.target_group_arn
  acm_certificate_arn    = var.acm_certificate_arn
}

# Install HELM and defined charts

module "helm" {
  source = "./modules/helm"

  eks_endpoint                   = module.eks.endpoint
  eks_certificate_authority_data = module.eks.certificate_authority_data
}
