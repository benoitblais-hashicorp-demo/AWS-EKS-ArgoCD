# Copyright IBM Corp. 2024, 2026

# ==============================================================================
# ARGOCD INGRESS ROUTING ARCHITECTURE
# ==============================================================================
# This file provisions the Kubernetes Ingress resource for ArgoCD.
# It configures the routing rules for the NGINX Ingress Controller to direct
# external web traffic into the ArgoCD Server service.
# This execution is gated by the step_3 variable.
# ==============================================================================

# ------------------------------------------------------------------------------
# KUBERNETES INGRESS ROUTING
# ------------------------------------------------------------------------------

# 1. Create an Ingress resource to route external traffic to the ArgoCD Server service
resource "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.step_3 ? 1 : 0
  depends_on = [
    time_sleep.step_3,
    helm_release.argocd,
  ]
  metadata {
    name      = "argocd-server-ingress"
    namespace = kubernetes_namespace_v1.argocd[0].metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                  = "nginx"
      "ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.public_hosted_zone != "" ? "${var.argocd_subdomain}.${var.public_hosted_zone}" : null
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
