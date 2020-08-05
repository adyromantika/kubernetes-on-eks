# Kubernetes on EKS [![Build Status](https://travis-ci.org/adyromantika/kubernetes-on-eks.svg?branch=master)](https://travis-ci.org/adyromantika/kubernetes-on-eks)

Launch a working Kubernetes cluster on Amazon EKS

Warning: Running this will incur cost in the AWS account

## Quickstart

Copy [terraform.tfvars.example](terraform.tfvars.example) to `terraform.tfvars` and update the variables. Example:

```hcl
project_name = "my-kubernetes"
aws_region = "ap-southeast-1"
acm_certificate_arn = "arn:aws:acm:ap-southeast-1:XXXXXXXXXXXX:certificate/273a87ea-094b-4f40-b2d2-29fbddab401b"
```

* project_name - an identifier where the resources will be named and tagged with
* aws_region - the region where the cluster will be launched
* acm_certificate_arn - the ARN of the certificate in ACM to be attached to the default load balancer. Preferably a wildcard certificate so that many subdomains can be served. More certificates can be added to the listener using `aws_lb_listener_certificate` in Terraform if needed in the future.

Make sure awscli is configured using `aws configure`, or the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are properly exported into the environment.

Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

### Terraform Backend

S3 bucket is used for the backend, and it needs to be changed in [main.tf](main.tf). Unfortunately variables are not allowed in the backend block in Terraform, so another way to do it is to pass backend information when running `terraform init` as shown below.

```bash
terraform init \
  -backend-config="key=terraform.tfstate" \
  -backend-config="bucket=<s3_bucket_name>" \
  -backend-config="region=<aws_region>" \
```

In non-interactive mode or automation, it can be called from a script, to make the code reusable for other environments or regions.

### Load Balancing

The default ALB provided is to handle requests for Kubernetes services with type `ClusterIP` where traffic is [via virtual IP](https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies). This is a popular implementation to save load balancer resource cost where traffic would be managed by the ingress controller.

To launch an external load balancer dedicated to a service, use type `LoadBalancer`. For example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: example-service
  annotations:
     service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:xx-xxxx-x:xxxxxxxxx:xxxxxxx/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxx
     service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
spec:
  selector:
    app: example
  ports:
    - port: 8765
      targetPort: 9376
  type: LoadBalancer
```

The `service.beta.kubernetes.io/aws-load-balancer-ssl-cert` annotation above is used to attach a certificate from ACM to the load balancer.

More reading about external load balancers:

* [Create an External Load Balancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/)
* [EKS: Load balancing](https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html)

## DNS Related

### Certificate

This repository assumes external DNS is used so no Route 53 resources are included. If Route 53 is used, we can create the certificate using `aws_acm_certificate` and validate it using `aws_acm_certificate_validation`.

When external DNS is used, the validation record must be created manually and the ARN for the certificate will also need to be added as a variable.

### DNS Record

The DNS name for the load balancer can be obtained with `terraform output alb_dns_name` and this is what we need to add as a new CNAME every time we have a new hostname.

### Kubernetes Endpoint

The cluster endpoint URL is hard to remember, it looks something like `7ECA2EBD80286C4B6F9E834834406D57.gr7.ap-southeast-1.eks.amazonaws.com` so another benefit if we're using Route 53 is that we can create an easy-to-remember endpoint that uses our own domain, from within Terraform.

Note: Since I use Cloudflare for all my DNS needs, Terraform can also manage DNS entries there so we can achieve the same result if I add it to this repository.

## kubectl Configuration

To connect to the cluster initially as admin, we will need to populate `~/.kube/config`

```bash
terraform output kubeconfig > ~/.kube/config
```

## Security

In [sg_rules.tf](modules/eks/sg_rules.tf), the `cidr_blocks` for security group rule `aws_security_group_rule.eks-cluster-ingress-workstation-https` should be updated to a narrower set to allow only specific IP or range to avoid access attempts from the public.
