provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  /*-- Below section is not needed if `tflocal` is used --*/
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    route53        = "http://localhost:4566"
  }
  /*-- Above section is not needed if `tflocal` is used --*/
}

//Create Hosted Zone
resource "aws_route53_zone" "dns" {
  name = "hellochaos.com"
}

resource "aws_route53_health_check" "primary_hlth" {
  fqdn              = "example.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"
}

resource "aws_route53_record" "subdmntst_pri" {
  zone_id = aws_route53_zone.dns.zone_id
  name    = "test.hellochaos.com"
  type    = "A"
  ttl     = 60
  records = ["22.33.44.51"]
  failover_routing_policy {
    type = "PRIMARY"
  }
  set_identifier = "test-ue1"
  health_check_id = aws_route53_health_check.primary_hlth.id
}

resource "aws_route53_record" "subdmntst_sec" {
  zone_id = aws_route53_zone.dns.zone_id
  name    = "test.hellochaos.com"
  type    = "A"
  ttl     = 60
  records = ["22.33.44.52"]
  failover_routing_policy {
    type = "SECONDARY"
  }
  set_identifier = "test-uw2"
}

output "r53_dns_id" {
  value = aws_route53_zone.dns.zone_id
}
output "r53_dns_ns" {
  value = aws_route53_zone.dns.name_servers
}

output "r53_subdmntst_pri_id" {
  value = aws_route53_record.subdmntst_pri.id
}
output "r53_subdmntst_pri_fqdn" {
  value = aws_route53_record.subdmntst_pri.fqdn
}
output "r53_subdmntst_pri_rcds" {
  value = aws_route53_record.subdmntst_pri.records
}
output "r53_subdmntst_sec_id" {
  value = aws_route53_record.subdmntst_sec.id
}
output "r53_subdmntst_sec_fqdn" {
  value = aws_route53_record.subdmntst_sec.fqdn
}
output "r53_subdmntst_sec_rcds" {
  value = aws_route53_record.subdmntst_sec.records
}
