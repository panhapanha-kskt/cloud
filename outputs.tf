output "s3_static_website_url" {
  description = "S3 Website URL (HTTP only)"
  value       = aws_s3_bucket_website_configuration.static_assets.website_endpoint
}

output "cloudfront_url" {
  description = "CloudFront HTTPS CDN"
  value       = "https://${aws_cloudfront_distribution.static_site.domain_name}"
}

output "alb_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app_alb.dns_name
}
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mydb.endpoint
}
