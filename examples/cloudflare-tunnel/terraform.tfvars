environments = {
  test = {
    cluster_name = "example-test"
    tunnel = [
      {
        zone = "example.com"
        subdomain = "test"
        proxied = true
        projects = [
          {
            service = "frontend.example.svc.cluster.local"
            path = "/"
          },
          {
            service = "backend.example.svc.cluster.local"
            path = "/api"
          }
        ]
      }
    ]

  }
}
