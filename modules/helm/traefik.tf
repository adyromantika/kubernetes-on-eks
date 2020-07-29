resource "helm_release" "traefik" {
  name      = "traefik-ingress-controller"
  chart     = "stable/traefik"
  namespace = "kube-system"

  set {
    name  = "rbac.enabled"
    value = "true"
  }

  set {
    name  = "serviceType"
    value = "NodePort"
  }

  set {
    name  = "replicas"
    value = "2"
  }

  set {
    name  = "service.nodePorts.http"
    value = "32080"
  }
}
