# Output the DNS name for the load balancer

output "dns_name" {
  value = aws_alb.eks-alb.dns_name
}
