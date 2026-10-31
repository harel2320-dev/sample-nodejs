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

# Points the app's subdomain at the ALB the in-cluster AWS Load Balancer
# Controller provisions for the Ingress. Hostname is hardcoded, not
# looked up dynamically - the ALB is Kubernetes-controller-managed, not
# a Terraform resource, so there's no data source for it without adding
# the Kubernetes provider just for this one value. Known gap, same
# shape as the earlier vpc_id hardcode: stable in practice (the ALB
# only changes if the Ingress is deleted/recreated, not on every
# deploy), but would silently go stale if that ever happens. The real
# fix is an external-dns controller watching Ingress resources and
# keeping this record in sync automatically - not installed yet.
resource "aws_route53_record" "sample_nodejs_app" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "sample-nodejs.catsweather.online"
  type    = "CNAME"
  ttl     = 300
  records = ["k8s-sampleno-sampleno-dcfbd56095-302454131.il-central-1.elb.amazonaws.com"]
}
