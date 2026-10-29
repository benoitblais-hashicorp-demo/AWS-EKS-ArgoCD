# AWS EKS with ArgoCD (HA)

## What this demo demonstrates

This demo provisions a production-oriented AWS EKS cluster and deploys ArgoCD in High Availability (HA) mode as a three-node cluster, exposed securely to the internet behind an NGINX Ingress Controller with SSL/TLS termination.

## Demo Value Proposition

- **High Availability (HA) ArgoCD Deployment**: Showcases industry-standard practices for running ArgoCD in production. Deploys multiple replicas of the ArgoCD Server and Repo Server, combined with a 3-replica HA Redis Sentinel setup.
- **Enterprise-ready Ingress Controller**: Uses NGINX Ingress Controller mapped to an AWS Network Load Balancer (NLB) to handle inbound web traffic efficiently.
- **Automated SSL/TLS Termination**: Deploys an AWS Certificate Manager (ACM) public certificate on the Network Load Balancer, routing traffic securely to the ArgoCD Server.
- **Three-Run Phased Architecture**: Preserves the progressive infrastructure building pattern: VPC and EKS, followed by Namespaces and Helm deployments, ending with Ingress routing and DNS resolution.

## Demo Components

- **AWS Networking:** VPC with private/public subnets across multiple Availability Zones, Internet Gateway, and NAT-based outbound connectivity for EKS worker nodes.
- **Compute:** EKS cluster (v1.34) with a managed node group (t3.medium, 1–3 nodes) and core addons (CoreDNS, kube-proxy, VPC CNI, EKS Pod Identity Agent).
- **Ingress:** Nginx ingress controller backed by an internet-facing AWS Network Load Balancer (NLB) with 3 pre-allocated Elastic IPs.
- **ArgoCD HA Cluster:** Helm release of ArgoCD configured in HA mode with 3 replicas for the Server, 3 replicas for the Repo Server, and a 3-node HA Redis Sentinel.
- **DNS Mapping:** Map the public Route 53 subdomain directly to the NLB's DNS name with automatic ACM certificate validation.

## How this demo works

1. Terraform provisions the AWS VPC and the EKS cluster (Step 1).
2. Terraform deploys the NGINX Ingress Controller Helm chart (Step 2).
3. Terraform deploys the ArgoCD Helm chart in High Availability mode (Step 2).
4. Terraform requests and validates an ACM certificate for the subdomain, and registers a CNAME record in Route 53 mapping to the NLB (Step 2).
5. Terraform configures the Ingress resource in the `argocd` namespace to route external HTTPS traffic safely to the ArgoCD Server (Step 3).

## How to Conduct the Demo

### Provisioning prerequisites

Before provisioning, configure the workspace with the required inputs:

1. Terraform variables `owner` and `repository` (optional, but highly recommended for resource tagging).
2. Terraform variable `doormat_username` (optional, but recommended to grant your AWS SSO role access to the EKS cluster).
3. HCP Terraform AWS Dynamic Provider Credentials enabled for the workspace (`TFC_AWS_PROVIDER_AUTH=true` and `TFC_AWS_RUN_ROLE_ARN` set).

After variables are configured, trigger runs from the workspace.

### Step 1 — Provision the infrastructure

1. Set `step_2 = false` and `step_3 = false` (default values).
2. Trigger Run #1.
3. Confirm the EKS cluster is healthy:
   - Open the **AWS Console → EKS → Clusters** and verify `<resources_prefix>-<random_id>-eks` shows **Active** status.

### Step 2 — Deploy Kubernetes tooling & ArgoCD HA

1. Set `step_2 = true` in the workspace variables.
2. Trigger Run #2.
3. Confirm the Ingress and ArgoCD pods are running:
   - Go to EKS Console → Clusters.
   - Under Workloads → Pods, select the `argocd` namespace and verify that you see 3 replicas of the `argocd-server`, `argocd-repo-server`, and the `redis-ha` pods running.

### Step 3 — Deploy Ingress Routing & Expose ArgoCD

1. Set `step_3 = true` in the workspace variables.
2. Trigger Run #3.
3. Confirm the ingress is created successfully.
4. Open the ArgoCD UI using the `argocd_url` Terraform output (e.g. `https://argocd.yourzone.com`).
