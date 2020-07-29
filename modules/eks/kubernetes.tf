# Setup provider for kubernetes

data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.project_name}-eks | jq -r -c .status"]
}

provider "kubernetes" {
  host                      = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate    = base64decode(aws_eks_cluster.eks.certificate_authority.0.data)
  token                     = data.external.aws_iam_authenticator.result.token
  load_config_file          = false
}

# Allow worker nodes to join cluster via config map
# https://aws.amazon.com/premiumsupport/knowledge-center/eks-worker-nodes-cluster/

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.eks-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }

  depends_on = [
    aws_eks_cluster.eks
  ]
}
