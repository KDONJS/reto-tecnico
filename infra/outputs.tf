output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
  description = "El DNS del Load Balancer para acceder al servicio"
}