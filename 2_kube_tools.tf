# Copyright IBM Corp. 2024, 2026

# ==============================================================================
# KUBERNETES TOOLING & INGRESS INFRASTRUCTURE
# ==============================================================================
# This file provisions essential Kubernetes tooling including namespaces for the 
# application and ingress, AWS Elastic IPs for stable load balancer IP addresses, 
# the NGINX Ingress Controller Helm chart, and Kubernetes Service Account 
# resources (RBAC, Secret) required for Vault Kubernetes authentication.
# This execution is gated by the step_2 variable.
# ==============================================================================

# ------------------------------------------------------------------------------
# KUBERNETES NAMESPACES
# ------------------------------------------------------------------------------

# 1. Create the 'argocd' namespace where ArgoCD will run
resource "kubernetes_namespace_v1" "argocd" {
  count      = var.step_2 ? 1 : 0
  depends_on = [time_sleep.step_2]
  metadata {
    name = "argocd"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

# 2. Create the 'ingress-nginx' namespace for the Ingress Controller
resource "kubernetes_namespace_v1" "ingress_nginx" {
  count      = var.step_2 ? 1 : 0
  depends_on = [time_sleep.step_2]
  metadata {
    name = "ingress-nginx"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

# ------------------------------------------------------------------------------
# NGINX INGRESS CONTROLLER & LOAD BALANCING
# ------------------------------------------------------------------------------

# 3. Wait temporarily to let Kubernetes settle before applying Helm
resource "time_sleep" "helm_wait" {
  count = var.step_2 ? 1 : 0
  depends_on = [
    kubernetes_namespace_v1.argocd,
  ]
  create_duration = "10s"
}

# 4. Deploy the NGINX Ingress Controller mapped to an AWS NLB
resource "helm_release" "nginx_ingress" {
  count = var.step_2 ? 1 : 0
  depends_on = [
    time_sleep.step_2,
    time_sleep.helm_wait,
    kubernetes_namespace_v1.ingress_nginx,
  ]
  name            = "ingress-nginx"
  repository      = "https://kubernetes.github.io/ingress-nginx"
  chart           = "ingress-nginx"
  namespace       = kubernetes_namespace_v1.ingress_nginx[0].metadata.0.name
  upgrade_install = true
  values = [<<-EOT
controller:
  config:
    use-forwarded-headers: "false"
  service:
    ${var.public_hosted_zone != "" ? "targetPorts:\n      https: http" : ""}
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      ${var.public_hosted_zone != "" ? format("service.beta.kubernetes.io/aws-load-balancer-ssl-cert: \"%s\"", try(aws_acm_certificate_validation.public[0].certificate_arn, "")) : "# TLS disabled"}
      ${var.public_hosted_zone != "" ? "service.beta.kubernetes.io/aws-load-balancer-ssl-ports: \"443\"" : ""}
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: true
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
    type: LoadBalancer
defaultBackend:
  enabled: true
EOT
  ]
}

