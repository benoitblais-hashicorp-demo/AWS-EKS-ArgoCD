# Copyright IBM Corp. 2024, 2026

# ==============================================================================
# ARGOCD DEPLOYMENT (HA HIGH AVAILABILITY)
# ==============================================================================
# This file deploys ArgoCD in High Availability (HA) mode as a three-node cluster
# using the official argo-cd Helm chart.
# This execution is gated by the step_2 variable.
# ==============================================================================

resource "helm_release" "argocd" {
  count = var.step_2 ? 1 : 0
  depends_on = [
    time_sleep.step_2,
    time_sleep.helm_wait,
    kubernetes_namespace_v1.argocd,
  ]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace_v1.argocd[0].metadata[0].name
  version          = "7.6.12"
  create_namespace = false

  values = [
    yamlencode({
      # Disable TLS on the ArgoCD Server container to let NGINX Ingress controller terminate TLS cleanly
      configs = {
        params = {
          "server.insecure" = "true"
        }
      }

      # Enable High Availability (HA) Mode
      ha = {
        enabled = true
      }

      # Ensure exactly a 3-replica deployment for high availability & horizontal scaling
      server = {
        replicas = 3
        autoscaling = {
          enabled = false
        }
      }

      repoServer = {
        replicas = 3
        autoscaling = {
          enabled = false
        }
      }

      # HA Redis Sentinel configuration
      redis-ha = {
        enabled = true
        redis = {
          replicas = 3
        }
      }
    })
  ]
}
