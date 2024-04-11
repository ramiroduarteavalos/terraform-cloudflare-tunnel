output "outputs" {
    value = {
        id = cloudflare_tunnel.auto_tunnel[*]
    }
    sensitive = true
}



