resource "aws_route53_zone" "annz_data_hub" {
  name = "annz.datahub.com"
}

resource "aws_route53_zone" "devops" {
  name = "devops.annz.datahub.com"
}

resource "aws_route53_record" "devops" {
  allow_overwrite = true
  name            = "devops.annz.datahub.com"
  ttl             = 300
  type            = "NS"
  zone_id         = aws_route53_zone.annz_data_hub.zone_id

  records = aws_route53_zone.devops.name_servers
}
