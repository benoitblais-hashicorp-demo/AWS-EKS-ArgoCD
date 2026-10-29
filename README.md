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

---

## Requirements

The following requirements are needed by this module:

- **Terraform:** `>= 1.5.0`
- **AWS Provider:** `~> 6.0`
- **Helm Provider:** `~> 3.0`
- **Kubernetes Provider:** `~> 3.0`
- **Random Provider:** `~> 3.0`
- **Time Provider:** `~> 0.13.0`

## Modules

The following Modules are called:

- **vpc**: Provisions public and private subnets, NAT gateway, and security groups.
- **eks**: Provisions the EKS cluster, node groups, IAM permissions, and access entries.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `customer_name` | Corresponds to the `cdl-customer-name` tag in AWS | `string` | `"hashicat"` | no |
| `argocd_subdomain` | The subdomain for exposing ArgoCD (e.g. `argocd`) | `string` | `"argocd"` | no |
| `doormat_username` | Doormat username for IAM cluster access integration | `string` | `""` | no |
| `environment` | Environment tag (e.g. `dev`, `prod`) | `string` | `"dev"` | no |
| `instance_type` | EC2 instance type for EKS managed node group | `string` | `"t3.medium"` | no |
| `owner` | Owner email identifier | `string` | `"user@example.com"` | no |
| `public_hosted_zone` | Route 53 public hosted zone for ACM/DNS | `string` | `"benoit-blais.sbx.hashidemos.io"` | no |
| `region` | AWS region to deploy resources | `string` | `"ca-central-1"` | no |
| `repository` | Repository URL for tagging | `string` | `"github.com/hashicorp/terraform-demo"` | no |
| `resources_prefix` | Prefix applied to all resources | `string` | `"argocd"` | no |
| `salesforce_opportunity_id` | Salesforce opportunity ID for resource tagging | `string` | `"N/A"` | no |
| `step_2` | Deploys ArgoCD namespace, Helm chart, Nginx Ingress and DNS | `bool` | `false` | no |
| `step_3` | Exposes ArgoCD via Ingress routing rule | `bool` | `false` | no |
| `uptycs_tags` | Tag list for Uptycs EDR agent | `string` | See variables | no |
| `vpc_cidr` | CIDR block for the AWS VPC | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `argocd_url` | Public URL of the ArgoCD UI dashboard |

<!-- BEGIN_TF_DOCS -->
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

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 6.0)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (3.1.1)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (3.0.1)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.8.1)

- <a name="requirement_time"></a> [time](#requirement\_time) (0.13.1)

## Modules

The following Modules are called:

### <a name="module_eks"></a> [eks](#module\_eks)

Source: terraform-aws-modules/eks/aws

Version: 21.15.1

### <a name="module_vpc"></a> [vpc](#module\_vpc)

Source: terraform-aws-modules/vpc/aws

Version: ~> 5.16

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_TFC_PROJECT_NAME"></a> [TFC\_PROJECT\_NAME](#input\_TFC\_PROJECT\_NAME)

Description: (Optional) Automatically populated by Terraform Cloud. Corresponds to the cdl-ddr-project tag in AWS.

Type: `string`

Default: `"local-project"`

### <a name="input_TFC_WORKSPACE_NAME"></a> [TFC\_WORKSPACE\_NAME](#input\_TFC\_WORKSPACE\_NAME)

Description: (Optional) Automatically populated by Terraform Cloud. Corresponds to the cdl-ddr-workspace-slug tag in AWS.

Type: `string`

Default: `"local-workspace"`

### <a name="input_argocd_subdomain"></a> [argocd\_subdomain](#input\_argocd\_subdomain)

Description: (Optional) The subdomain to prepend to the public\_hosted\_zone for ArgoCD (e.g., 'argocd').

Type: `string`

Default: `"argocd"`

### <a name="input_customer_name"></a> [customer\_name](#input\_customer\_name)

Description: (Optional) Corresponds to the cdl-customer-name tag in AWS.

Type: `string`

Default: `"hashicat"`

### <a name="input_doormat_username"></a> [doormat\_username](#input\_doormat\_username)

Description: (Optional) Doormat username used to construct the IAM developer role ARN for EKS cluster access and KMS key administration (e.g. firstname.lastname\_company). Leave empty to skip adding the doormat role as a KMS key administrator and EKS access entry.

Type: `string`

Default: `""`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: (Optional) Corresponds to the environment tag in AWS.

Type: `string`

Default: `"dev"`

### <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)

Description: (Optional) EC2 instance type for the EKS managed node group.

Type: `string`

Default: `"t3.medium"`

### <a name="input_owner"></a> [owner](#input\_owner)

Description: (Optional) Owner identifier (e.g., email) used for tagging.

Type: `string`

Default: `"user@example.com"`

### <a name="input_public_hosted_zone"></a> [public\_hosted\_zone](#input\_public\_hosted\_zone)

Description: (Optional) The Route 53 public hosted zone name (e.g., 'example.com') where DNS validation and A records will be published. If set, an ACM certificate will be provisioned directly on the NGINX Network Load Balancer.

Type: `string`

Default: `"benoit-blais.sbx.hashidemos.io"`

### <a name="input_region"></a> [region](#input\_region)

Description: (Optional) AWS region where all resources are provisioned.

Type: `string`

Default: `"ca-central-1"`

### <a name="input_repository"></a> [repository](#input\_repository)

Description: (Optional) The URL of the repository where the codebase resides.

Type: `string`

Default: `"github.com/hashicorp/terraform-demo"`

### <a name="input_resources_prefix"></a> [resources\_prefix](#input\_resources\_prefix)

Description: (Optional) Prefix applied to all resources.

Type: `string`

Default: `"argocd"`

### <a name="input_salesforce_opportunity_id"></a> [salesforce\_opportunity\_id](#input\_salesforce\_opportunity\_id)

Description: (Optional) Corresponds to the salesforce\_id tag in AWS.

Type: `string`

Default: `"N/A"`

### <a name="input_step_2"></a> [step\_2](#input\_step\_2)

Description: (Optional) Set to true after Step 1 completes successfully. Deploys Kubernetes tooling and platforms: NGINX Ingress, Uptycs EDR agent, and ArgoCD in HA mode.

Type: `bool`

Default: `false`

### <a name="input_step_3"></a> [step\_3](#input\_step\_3)

Description: (Optional) Set to true after Step 2 completes successfully. Configures and deploys the ArgoCD Ingress routing rule to expose the ArgoCD UI. Requires step\_2 = true.

Type: `bool`

Default: `false`

### <a name="input_uptycs_tags"></a> [uptycs\_tags](#input\_uptycs\_tags)

Description: (Optional) Comma-separated Uptycs tags in UPDATE/CCODE/UT/OWNER format.

Type: `string`

Default: `"UPDATE/PROD,CCODE/HashiCorp,UT/20A7V,OWNER/owner-email@hashicorp.com"`

### <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr)

Description: (Optional) IPv4 CIDR block for the AWS VPC.

Type: `string`

Default: `"10.1.0.0/16"`

## Resources

The following resources are used by this module:

- [aws_acm_certificate.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) (resource)
- [aws_acm_certificate_validation.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) (resource)
- [aws_route53_record.public_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)
- [aws_route53_record.web_dns_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)
- [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) (resource)
- [helm_release.nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) (resource)
- [helm_release.uptycs_edr](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) (resource)
- [kubernetes_ingress_v1.argocd_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/3.0.1/docs/resources/ingress_v1) (resource)
- [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/3.0.1/docs/resources/namespace_v1) (resource)
- [kubernetes_namespace_v1.edr](https://registry.terraform.io/providers/hashicorp/kubernetes/3.0.1/docs/resources/namespace_v1) (resource)
- [kubernetes_namespace_v1.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/3.0.1/docs/resources/namespace_v1) (resource)
- [random_string.identifier](https://registry.terraform.io/providers/hashicorp/random/3.8.1/docs/resources/string) (resource)
- [time_sleep.helm_wait](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) (resource)
- [time_sleep.nlb_wait](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) (resource)
- [time_sleep.step_2](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) (resource)
- [time_sleep.step_3](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) (resource)
- [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) (data source)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_ec2_instance_type_offerings.supported](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type_offerings) (data source)
- [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) (data source)
- [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
- [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)
- [kubernetes_service_v1.nginx_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/3.0.1/docs/data-sources/service_v1) (data source)

## Outputs

The following outputs are exported:

### <a name="output_argocd_url"></a> [argocd\_url](#output\_argocd\_url)

Description: Public URL of the ArgoCD UI (available after step\_3 = true)

<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->