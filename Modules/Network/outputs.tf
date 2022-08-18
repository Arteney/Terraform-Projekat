output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main-vpc.id
}

output "public_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.PositiveTech-subnet-public
}

output "private_subnet1" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.PositiveTech-subnet-private-1
}

output "private_subnet2" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.PositiveTech-subnet-private-2
}

output "db-subnet-group-name" {
  description = "List of IDs of public subnets"
  value       = aws_db_subnet_group.private.id
}