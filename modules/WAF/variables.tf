variable "waf_name" {
  type = string
}

variable "waf_scope" {
  type = string
  default = "REGIONAL"
}

variable "resource_arn" {
  type        = string
}