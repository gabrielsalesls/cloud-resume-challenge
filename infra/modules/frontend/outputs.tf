# ============================================
# OUTPUTS
# ============================================
output "route53_nameservers" {
  description = "Configure estes nameservers na Hostinger para migrar o DNS"
  value       = aws_route53_zone.main.name_servers
}

output "cloudfront_domain" {
  description = "Domínio do CloudFront (para testes antes da migração DNS)"
  value       = aws_cloudfront_distribution.website_s3_distribution.domain_name
}

output "website_url" {
  description = "URL do site"
  value       = "https://${var.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront (útil para invalidações)"
  value       = aws_cloudfront_distribution.website_s3_distribution.id
}