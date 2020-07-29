# Output kubeconfig to be passed to the root module

output "kubeconfig" {
  value = local.kubeconfig
  depends_on = [
    aws_eks_cluster.eks
  ]
}

# Ouput the security group of the nodes

output "node_security_group_id" {
  value = aws_security_group.eks-node.id
}

# Output the target group ARN to be passed to the ALB module

output "target_group_arn" {
  value = aws_lb_target_group.eks.arn
}

# Cluster endpoint

output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

# Certificate authority data

output "certificate_authority_data" {
  value = aws_eks_cluster.eks.certificate_authority.0.data
}
