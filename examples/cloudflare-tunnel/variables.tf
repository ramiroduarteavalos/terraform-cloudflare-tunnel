variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
}

variable "environments" {
  description = "Tunnel exposes applications running"
  type = map(object({
    cluster_name = string
    tunnel = list(object({
      zone = string
      domain = string
      proxied = bool
      namespace = string
    }))
  }))

}
