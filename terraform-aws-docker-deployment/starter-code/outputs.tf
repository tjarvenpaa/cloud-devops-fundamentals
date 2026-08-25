# -----------------------------------------------------------------------------
# Käyttöönoton tulokset
# -----------------------------------------------------------------------------

output "instance_id" {
  description = "EC2-instanssin ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "EC2-instanssin julkinen IPv4-osoite"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "EC2-instanssin julkinen DNS-nimi"
  value       = aws_instance.web.public_dns
}

output "application_url" {
  description = "Käyttöönotetun konttisovelluksen HTTP-URL-osoite"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "Esimerkki SSH-komennosta. Korvaa PRIVATE_KEY.pem paikallisella yksityisellä avaimella"
  value       = "ssh -i PRIVATE_KEY.pem ubuntu@${aws_instance.web.public_ip}"
}

output "vpc_id" {
  description = "VPC:n ID, joka on luotu käyttöönottoa varten"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Julkisen aliverkon ID, joka on luotu käyttöönottoa varten"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Web-palvelimen turvallisuusryhmän ID, joka on luotu käyttöönottoa varten"
  value       = aws_security_group.web.id
}
