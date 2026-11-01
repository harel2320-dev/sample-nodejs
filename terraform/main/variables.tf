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

variable "domain_name" {
  description = "Domain name for the app's Ingress (ACM cert + ALB host rule)"
  type        = string
  default     = "sample-nodejs.catsweather.online"
}

variable "root_domain_name" {
  description = "Root domain (Route53 hosted zone)."
  type        = string
  default     = "catsweather.online"
}

variable "delegation_set_id" {
  description = "Reusable Route53 delegation set - keeps the same 4 NS records across zone recreation, so the registrar's NS delegation never has to change."
  type        = string
  default     = "N0256103CFLBEGIW6CUR"
}
