encrypt = true
bucket = "chaos-dns-failover-sbx-us-east-1"
region = "us-east-1"

rest_api_name = "api-gateway-chaos-dns"
rest_api_stage_name = "sbx"
root_domain = "indra-sbx.autodesk.com"
subdomain = "chaos-dns.indra-sbx.autodesk.com"
health_check_name = "chas-dns-sbx-us-east-1-healthcheck"
route53_failover_routing_policy = "SECONDARY"
route53_identifier = "chaos-dns-us-east-1"
