# The security group that is attached to the EKS nodes

resource "aws_security_group" "eks-node" {
  name        = "${var.project_name}-eks-node"
  description = "Security group for nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project_name
  }
}
