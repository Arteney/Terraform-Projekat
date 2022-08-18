output "vpc-security-group-ids" {
  description = "List of IDs of public subnets"
  value       = aws_security_group.allow-internal-mysql.id
}