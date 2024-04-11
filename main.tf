## Start Terraform Data EKS ----------------------------------------------------
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}
## End Terraform Data EKS ------------------------------------------------------

resource "random_id" "tunnel" {
  byte_length = 35
}

resource "cloudflare_tunnel" "auto_tunnel" {
  for_each = { for r in var.tunnel : r.subdomain => r }
  account_id = var.cloudflare_account_id
  name       = "${each.value.subdomain}-${each.value.zone}"
  secret     = random_id.tunnel.b64_std
  config_src = "cloudflare"
}

data "cloudflare_zone" "this" {
  for_each = { for r in var.tunnel : r.subdomain => r }
  name = each.value.zone
}

resource "cloudflare_record" "http_app" {
  for_each = { for r in var.tunnel : r.subdomain => r }

  zone_id = data.cloudflare_zone.this[each.key].id
  name    = each.value.subdomain
  value   = cloudflare_tunnel.auto_tunnel[each.key].cname
  type    = "CNAME"
  proxied = each.value.proxied
}

resource "cloudflare_tunnel_config" "auto_tunnel" {
  for_each = { for r in var.tunnel : r.subdomain => r }
  tunnel_id = cloudflare_tunnel.auto_tunnel[each.key].id
  account_id = var.cloudflare_account_id

  config {

    dynamic "ingress_rule" {
      for_each = each.value.projects

      content {
        hostname = each.value.subdomain != "" ? "${replace(each.value.subdomain, "@", "")}.${each.value.zone}" : each.value.zone
        service  = "http://${ingress_rule.value.service}"
        path     = ingress_rule.value.path
      }
    }

    ingress_rule {
      service = "http_status:404"
    }    
  }

}

resource "kubernetes_namespace" "this" {
  for_each = { for r in var.tunnel : r.subdomain => r }
  metadata {
    name = "${replace(each.value.subdomain, ".", "-")}-${replace(each.value.zone, ".", "-")}"
  }
}

resource "kubernetes_manifest" "secret_cloudflare_cloudflared" {
  for_each = { for r in var.tunnel : r.subdomain => r }
  
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "token" = "${base64encode(("${cloudflare_tunnel.auto_tunnel[each.key].tunnel_token}"))}"
    }
    "kind" = "Secret"
    "metadata" = {
      "name" = "${replace(each.value.subdomain, "@", "www")}-cloudflare-tunnel"
      "namespace" = "${replace(each.value.subdomain, ".", "-")}-${replace(each.value.zone, ".", "-")}"
    }
    "type" = "Opaque"
  }

  depends_on = [ kubernetes_namespace.this, cloudflare_tunnel.auto_tunnel ]
}

resource "kubernetes_manifest" "deployment_cloudflare_cloudflared_deployment" {
  for_each = { for r in var.tunnel : r.subdomain => r }

  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "cloudflare"
      }
      "name" = "${replace(each.value.subdomain, "@", "www")}-cloudflare-tunnel"
      "namespace" = "${replace(each.value.subdomain, ".", "-")}-${replace(each.value.zone, ".", "-")}"
    }
    "spec" = {
      "replicas" = 2
      "selector" = {
        "matchLabels" = {
          "pod" = "cloudflared"
        }
      }
      "template" = {
        "metadata" = {
          "creationTimestamp" = null
          "labels" = {
            "pod" = "cloudflared"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--token",
                "$(CLOUDFLARE-SECRET)",
              ]
              "command" = [
                "cloudflared",
                "tunnel",
                "--metrics",
                "0.0.0.0:2000",
                "run",
              ]
              "env" = [
                {
                  "name" = "CLOUDFLARE-SECRET"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "token"
                      "name" = "${replace(each.value.subdomain, "@", "www")}-cloudflare-tunnel"
                    }
                  }
                },
              ]
              "image" = "cloudflare/cloudflared:latest"
              "livenessProbe" = {
                "failureThreshold" = 1
                "httpGet" = {
                  "path" = "/ready"
                  "port" = 2000
                }
                "initialDelaySeconds" = 10
                "periodSeconds" = 10
              }
              "name" = "cloudflared"
            },
          ]
        }
      }
    }
  }

  depends_on = [ kubernetes_namespace.this, cloudflare_tunnel.auto_tunnel ]
}