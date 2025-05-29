output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.public_subnet.subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.private_subnet.subnet_ids
}

output "external_alb_dns" {
  description = "DNS name of external load balancer"
  value       = module.external_alb.alb_dns_name
}

output "internal_alb_dns" {
  description = "DNS name of internal load balancer"
  value       = module.internal_alb.alb_dns_name
}

output "nginx_public_ips" {
  description = "Public IP addresses of Nginx proxies"
  value       = module.nginx_proxies.public_ips
}

output "apache_private_ips" {
  description = "Private IP addresses of Apache servers"
  value       = module.apache_servers.private_ips
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = module.state_backend.bucket_arn
}
