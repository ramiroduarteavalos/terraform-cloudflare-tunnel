module "cloudflare" {
  source = "git::git@github.com:ramiroduarteavalos/terraform-cloudflare-tunnel.git"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_account_id = var.cloudflare_account_id
  cluster_name = var.environments[terraform.workspace].cluster_name
  tunnel = var.environments[terraform.workspace].tunnel
}
