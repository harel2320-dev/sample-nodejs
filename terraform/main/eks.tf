module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public-only endpoint access (AWS's own documented default for new
  # clusters).
  endpoint_public_access  = true
  endpoint_private_access = false

  enable_cluster_creator_admin_permissions = true

  # No IRSA anywhere in this project - EKS Pod Identity is used instead.
  # Without this, the module creates an OIDC provider for IRSA
  # regardless, which this project deliberately avoided needing.
  enable_irsa = false

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
    }

    # Isolates high-privilege platform tooling (ArgoCD, ALB controller)
    # from the app workload - a compromised app pod shares a node (kernel,
    # node-level IAM/Pod Identity credential access) with whatever else
    # runs there. Tainted so only pods with a matching toleration land
    # here; nothing schedules here by default.
    platform = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1

      # Stable label for nodeSelector - unlike eks.amazonaws.com/nodegroup
      # (which embeds a random suffix that changes if this node group is
      # ever replaced), this value never changes.
      labels = {
        role = "platform"
      }

      taints = {
        critical_addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
}
