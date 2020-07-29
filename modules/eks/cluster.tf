# The EKS Cluster

resource "aws_eks_cluster" "eks" {
  name            = "${var.project_name}-eks"
  role_arn        = aws_iam_role.eks-master.arn
  version         = "1.17"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-master.id}"]
    subnet_ids         = var.private_subnets_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}
