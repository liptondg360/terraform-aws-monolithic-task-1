# OUTPUTS

# Getting the DNS of load balancer
output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-alb-frontend.dns_name
}

# Getting the DNS of load balancer
output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-alb-backend.dns_name
}

output "db_connect_string" {
  description = "MyRDS database connection string"
  value       = "server=${aws_db_instance.test_db.address}; database=ekyc-DB; Uid=${var.db_username}; Pwd=${var.db_password}"
  sensitive   = true
}