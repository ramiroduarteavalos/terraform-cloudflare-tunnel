variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster to obtain credentials for helm connection"
  type        = string
}

variable "tunnel" {
  description = "Tunnel exposes applications running"
  type = list(object({
    zone = string
    subdomain  = string
    proxied = bool
    projects = list(object({
      service  = string
      path     = string
    }))
  }))
}