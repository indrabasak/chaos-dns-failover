#aws_region = "us-west-2"
#aws_region_secondary = "us-east-1"
#
#region_secondary = "us-east-1"
#base_name = "chaos-dns"

encrypt = true
bucket = "chaos-dns-failover-sbx-us-west-2"
region = "us-west-2"
key="chaos-dns-failover/terraform.tfstate"

rest_api_name = "api-gateway-chaos-dns"
rest_api_stage_name = "sbx"
root_domain = "indra-sbx.autodesk.com"
subdomain = "chaos-dns.indra-sbx.autodesk.com"
health_check_name = "chas-dns-sbx-us-west-2-healthcheck"
route53_failover_routing_policy = "PRIMARY"
route53_identifier = "chaos-dns-us-west-2"
