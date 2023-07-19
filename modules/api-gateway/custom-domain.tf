data "aws_route53_zone" "root_domain" {
  name         = var.root_domain
  private_zone = false
}

# Find a certificate that is issued
data "aws_acm_certificate" "certificate" {
  domain   = var.subdomain
  statuses = ["ISSUED"]
}

# The domain name to use with api-gateway
resource "aws_api_gateway_domain_name" "domain_name" {
  domain_name = var.subdomain
  regional_certificate_arn = data.aws_acm_certificate.certificate.arn
  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.rest_api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.domain_name.domain_name
}

resource "aws_route53_health_check" "health_check" {
#  fqdn              = var.subdomain
#  fqdn              = aws_api_gateway_stage.rest_api_stage.invoke_url
# https://vvzfruna93.execute-api.us-west-2.amazonaws.com/sbx
# aws_api_gateway_rest_api.rest_api.id
  fqdn              = "${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.region}.amazonaws.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "${var.rest_api_stage_name}/v1/health"
  failure_threshold = "2"
  request_interval  = "10"
  regions = ["us-west-2", "us-east-1", "us-west-1"]
  tags = {
    Name = var.health_check_name
  }
}

resource "aws_route53_record" "sub_domain" {
  name    = var.subdomain
  type    = "A"
  zone_id = data.aws_route53_zone.root_domain.zone_id
  alias {
    name                   = aws_api_gateway_domain_name.domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name.regional_zone_id
    evaluate_target_health = false
    }
#  ttl     = 60
#  records = [var.subdomain]
  failover_routing_policy {
    type = var.route53_failover_routing_policy
  }
  set_identifier = var.route53_identifier
  health_check_id = aws_route53_health_check.health_check.id
}
