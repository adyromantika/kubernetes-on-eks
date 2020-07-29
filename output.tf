# Output kubeconfig to be used from management machine

output "kubeconfig" {
  value = module.eks.kubeconfig
}

# Outputs the DNS name of the load balancer so that we can use a CNAME in our DNS
# If we use Route 53 we can directly add a record without depending on this output

output "alb_dns_name" {
  value = module.alb.dns_name
}
