variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "il-central-1"
}

variable "cluster_name" {
  description = "Name for the EKS cluster and related resources"
  type        = string
  default     = "sample-nodejs"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.37"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
