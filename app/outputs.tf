output "lb_ip" {
  value = "${kubernetes_service.app_service.load_balancer_ingress.0.ip}"
}

