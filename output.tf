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

#DynamoDB Outputs
output "arn" {
  value       = aws_dynamodb_table.main.arn
  sensitive   = false
  description = "The arn of the table"
  depends_on  = []
}

output "id" {
  value       = aws_dynamodb_table.main.id
  sensitive   = false
  description = "The name of the table"
  depends_on  = []
}

output "stream_arn" {
  value       = lookup(aws_dynamodb_table.main, "stream_arn", null)
  sensitive   = false
  description = "The ARN of the Table Stream. Only available when stream_enabled = true"
  depends_on  = []
}

output "stream_label" {
  value       = lookup(aws_dynamodb_table.main, "stream_label", null)
  sensitive   = false
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true"
  depends_on  = []
}