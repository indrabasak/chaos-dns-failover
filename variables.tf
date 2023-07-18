variable "encrypt" {
  type = bool
}

variable "bucket" {
  type = string
}

variable "region" {
  type = string
}

variable "key" {
  type = string
}

# ////////////////////////////////////////////////////////////////////
variable "rest_api_name" {
  type = string
  description = "Chaos DNS Failover Example"
  default = ""
}

variable "rest_api_stage_name" {
  type        = string
  description = "Chaos DNS Failover Example API Gateway stage"
  default     = ""
}

variable "root_domain" {
  type        = string
  description = "The domain name to associate with the API"
  default = ""
}

variable "subdomain" {
  type        = string
  description = "The subdomain for the API"
  default = ""
}

variable "health_check_name" {
  type        = string
  description = "The name of health check"
  default = ""
}

variable "route53_failover_routing_policy" {
  type        = string
  description = "Failover Routing policy - PRIMARY, SECONDARY"
  default = ""
}

variable "route53_identifier" {
  type = string
  description = "Unique identifier"
  default = ""
}
