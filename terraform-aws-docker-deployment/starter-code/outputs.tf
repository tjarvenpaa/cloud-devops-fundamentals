output "instance_hostname" {
  description = "EC2-instanssin yksityinen DNS-nimi."
  value       = aws_instance.app_server.private_dns
}
output "instance_ip" {
  description = "EC2-instanssin yksityinen IP-osoite."
  value       = aws_instance.app_server.private_ip
}
output "web_instance_ip" {
  description = "Verkkopalvelininstanssin julkinen IP-osoite."
  value       = aws_instance.web_server.public_ip
}