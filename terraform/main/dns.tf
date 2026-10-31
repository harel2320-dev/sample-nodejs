resource "aws_route53_zone" "root" {
  name              = var.root_domain_name
  delegation_set_id = var.delegation_set_id
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.root.zone_id
  name    = tolist(aws_acm_certificate.sample_nodejs.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.sample_nodejs.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.sample_nodejs.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "sample_nodejs" {
  certificate_arn         = aws_acm_certificate.sample_nodejs.arn
  validation_record_fqdns = [aws_route53_record.acm_validation.fqdn]
}
