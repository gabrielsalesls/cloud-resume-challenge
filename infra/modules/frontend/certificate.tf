resource "aws_acm_certificate" "this" {
  domain_name       = "exemplo.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.gabrielsales.dev"
  ]

  tags = merge(
    module.common.tags,
    {
      description = "Website SSL Certificates"
    }
  )
}

output "certificate_dns_validation_records" {
  description = "Registros DNS a serem criados na Hostinger para validar o certificado"
  value = [
    for dvo in aws_acm_certificate.this.domain_validation_options : {
      domain_name = dvo.domain_name
      name        = dvo.resource_record_name
      type        = dvo.resource_record_type
      value       = dvo.resource_record_value
    }
  ]
}