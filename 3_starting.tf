# Copyright IBM Corp. 2024, 2026

# ==============================================================================
# STEP 3 DEPENDENCY GATE
# ==============================================================================
# This file provisions a time_sleep resource that acts as a dependency gate
# for all Step 3 resources. It ensures that Step 2 Kubernetes tooling
# (Ingress Controller, Vault Secrets Operator, authentication roles) is fully 
# deployed and stable before deploying the demo application.
# This execution is gated by the step_3 variable.
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 3 GATE
# ------------------------------------------------------------------------------

# 1. Act as a barrier: Wait for Step 2 dependencies, then add a 10s buffer to stabilize the environment
resource "time_sleep" "step_3" {
  count = var.step_3 ? 1 : 0
  depends_on = [
    helm_release.nginx_ingress,
    helm_release.argocd,
  ]
  create_duration  = "10s"
  destroy_duration = "10s"
}
