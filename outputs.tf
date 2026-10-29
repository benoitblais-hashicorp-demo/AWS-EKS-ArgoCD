# Copyright IBM Corp. 2024, 2026

output "argocd_url" {
  description = "Public URL of the ArgoCD UI (available after step_3 = true)"
  value       = var.step_2 && var.step_3 ? (var.public_hosted_zone != "" ? "https://${var.demo_subdomain}.${var.public_hosted_zone}" : "http://${try(data.kubernetes_service_v1.nginx_ingress[0].status[0].load_balancer[0].ingress[0].hostname, "load-balancer-pending")}") : ""
}
