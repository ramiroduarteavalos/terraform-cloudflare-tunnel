## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudflare"></a> [cloudflare](#module\_cloudflare) | git::git@github.com:ramiroduarteavalos/terraform-cloudflare-tunnel.git | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_account_id"></a> [cloudflare\_account\_id](#input\_cloudflare\_account\_id) | Account ID for your Cloudflare account | `string` | n/a | yes |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API token | `string` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | Tunnel exposes applications running | <pre>map(object({<br>    cluster_name = string<br>    tunnel = list(object({<br>      zone = string<br>      domain = string<br>      proxied = bool<br>      namespace = string<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
