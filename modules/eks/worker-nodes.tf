########################################################################################
# Setup AutoScaling Group for worker nodes

# Data source to get amazon-provided AMI for EKS nodes

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# Utilize local to simplify Base64 encode userdata information and write it into the AutoScaling Launch Configuration.

locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.project_name}-eks'
USERDATA
}

# Launch configuration that determines what we launch as nodes

resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m5a.large"
  name_prefix                 = "${var.project_name}-eks"
  security_groups             = ["${aws_security_group.eks-node.id}"]
  user_data_base64            = base64encode(local.eks-node-userdata)
  key_name                    = "kubernetes-on-eks"

  lifecycle {
    create_before_destroy = true
  }
}

# Create a target group for our autoscaling group to be used by load balancer

resource "aws_lb_target_group" "eks" {
  name = "terraform-eks-nodes"
  port = 32080
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/ping"
    port                = 32080
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# Create the autoscaling group

resource "aws_autoscaling_group" "eks" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.eks.id
  max_size             = 3
  min_size             = 1
  name                 = "${var.project_name}-eks"
  vpc_zone_identifier  = var.private_subnets_ids
  target_group_arns    = [aws_lb_target_group.eks.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.project_name}-eks"
    value               = "owned"
    propagate_at_launch = true
  }
}
