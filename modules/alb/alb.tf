# Application load balancer and its listeners

resource "aws_alb" "eks-alb" {
  name            = "eks-alb"
  subnets         = var.public_subnets_ids
  security_groups = [var.node_security_group_id, aws_security_group.alb.id]
  ip_address_type = "ipv4"

  tags = merge(
    {"Name" = "${var.project_name}-eks-alb"},
    {"kubernetes.io/cluster/${var.project_name}-eks" = "owned"}
  )
}

resource "aws_alb_listener" "eks-alb" {
  load_balancer_arn = aws_alb.eks-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type              = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "eks-alb-ssl" {
  load_balancer_arn = aws_alb.eks-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}
