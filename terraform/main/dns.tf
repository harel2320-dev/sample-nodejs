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

# ALB hostname is hardcoded: the ALB is provisioned by the in-cluster
# Load Balancer Controller, not a Terraform resource, so there's no
# data source for it. Stale if the Ingress is ever deleted/recreated -
# an external-dns controller would keep this in sync automatically.
resource "aws_route53_record" "sample_nodejs_app" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "sample-nodejs.catsweather.online"
  type    = "CNAME"
  ttl     = 300
  records = ["k8s-sampleno-sampleno-dcfbd56095-302454131.il-central-1.elb.amazonaws.com"]
}
