output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.sample_nodejs.repository_url
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.sample_nodejs.arn
}

output "acm_validation_record" {
  description = "CNAME to add at the registrar to validate the ACM cert"
  value = {
    name  = tolist(aws_acm_certificate.sample_nodejs.domain_validation_options)[0].resource_record_name
    type  = tolist(aws_acm_certificate.sample_nodejs.domain_validation_options)[0].resource_record_type
    value = tolist(aws_acm_certificate.sample_nodejs.domain_validation_options)[0].resource_record_value
  }
}
