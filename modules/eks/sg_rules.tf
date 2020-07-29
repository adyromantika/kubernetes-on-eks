# Allow inbound traffic from external IP addresses
# cidr_blocks should be replaced by office IP or a list of allowed IPs/subnets for security
resource "aws_security_group_rule" "tf-eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/32"]
  description       = "Allow external machines to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-master.id
  to_port           = 443
  type              = "ingress"
}

# Worker node security groups

resource "aws_security_group_rule" "eks-node-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-master.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker nodes to access EKS master

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-master.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-master" {
  description              = "Allow cluster control to receive communication from the worker Kubelets"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-master.id
  source_security_group_id = aws_security_group.eks-node.id
  to_port                  = 443
  type                     = "ingress"
}

