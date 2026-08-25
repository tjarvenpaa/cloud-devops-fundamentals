# Cloud-init-esimerkki: Docker-sovelluksen automaattinen käyttöönotto

Tässä esimerkissä Terraform luo Ubuntu-pohjaisen EC2-instanssin ja välittää sille erillisen `cloud-init.sh`-skriptin. Skripti asentaa Dockerin ja käynnistää Nginx-kontin automaattisesti.

## Hakemistorakenne

```text
starter-code/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars.example
└── cloud-init.sh
```

## 1. `cloud-init.sh`

```bash
#!/bin/bash
set -euxo pipefail

# Päivitetään pakettien lähdeluettelo ja asennetaan Docker.
apt-get update -y
apt-get install -y docker.io

# Otetaan Docker käyttöön ja käynnistetään palvelu heti.
systemctl enable --now docker

# Varmistetaan, että Docker-palvelu on toimintavalmis.
for attempt in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

docker info >/dev/null 2>&1

# Noudetaan sovelluksen Docker-kuva.
docker pull nginx:latest

# Poistetaan mahdollinen aiempi samanniminen kontti.
docker rm -f webapp 2>/dev/null || true

# Käynnistetään sovellus palvelimen portissa 80.
docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  nginx:latest

# Tallennetaan käyttöönoton onnistuminen lokiin.
echo "Cloud-init deployment completed at $(date --iso-8601=seconds)" \
  | tee /var/log/webapp-deployment.log
```

## 2. Skriptin liittäminen EC2-instanssiin

Lisää EC2-resurssiin `user_data`:

```hcl
resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/cloud-init.sh")

  tags = {
    Name = "terraform-docker-web"
  }
}
```

## 3. Tarvittavat muuttujat

```hcl
variable "ami_id" {
  description = "Ubuntu AMI ID used by the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

Esimerkkitiedosto `terraform.tfvars.example`:

```hcl
ami_id        = "REPLACE_WITH_UBUNTU_AMI_ID"
instance_type = "t3.micro"
```

Kopioi esimerkkitiedosto paikalliseksi asetustiedostoksi:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Päivitä `ami_id` käytössä olevan AWS-alueen ja ympäristön mukaiseksi. Älä tallenna ympäristökohtaisia tunnuksia tai salaisuuksia `terraform.tfvars`-tiedostoon.

## 4. Security Group

Sovelluksen käyttämiseksi Security Groupin tulee sallia HTTP-liikenne porttiin 80. SSH kannattaa rajata opiskelijan omaan julkiseen IP-osoitteeseen.

```hcl
resource "aws_security_group" "web" {
  name        = "terraform-docker-web"
  description = "Allow HTTP and restricted SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from the student's public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_source_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Lisää muuttuja:

```hcl
variable "ssh_source_cidr" {
  description = "Public source address allowed to use SSH, for example 203.0.113.10/32"
  type        = string
}
```

## 5. Outputit

```hcl
output "public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "application_url" {
  description = "URL of the deployed application"
  value       = "http://${aws_instance.web.public_ip}"
}
```

## 6. Käyttöönotto

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Näytä sovelluksen URL:

```bash
terraform output -raw application_url
```

Huomaa, että cloud-init voi edelleen suorittaa asennuksia, vaikka Terraform olisi jo ilmoittanut EC2-instanssin valmistuneeksi.

## 7. Käyttöönoton todentaminen

Yhdistä instanssiin ja odota cloud-initin valmistumista:

```bash
ssh -i PRIVATE_KEY.pem ubuntu@PUBLIC_IP
```

```bash
sudo cloud-init status --wait
```

Tarkista Docker ja kontti:

```bash
sudo systemctl status docker --no-pager
sudo docker ps
sudo docker logs webapp
```

Tarkista paikallinen HTTP-vastaus:

```bash
curl -I http://localhost
```

Tarkista käyttöönoton oma loki:

```bash
sudo cat /var/log/webapp-deployment.log
```

Avaa lopuksi selaimessa:

```text
http://PUBLIC_IP
```

## 8. Vianmääritys

Cloud-initin tulosteet:

```bash
sudo less /var/log/cloud-init-output.log
```

Cloud-initin tila:

```bash
sudo cloud-init status --long
```

Kaikki kontit, myös pysähtyneet:

```bash
sudo docker ps -a
```

Konttiloki:

```bash
sudo docker logs webapp
```

Jos `curl http://localhost` toimii mutta sovellus ei avaudu selaimessa, tarkista:

- Security Groupin TCP-portti 80
- EC2-instanssin julkinen IP-osoite
- aliverkon reitti Internet Gatewaylle
- reititystaulun liitos oikeaan aliverkkoon

## 9. Oman Docker-kuvan käyttäminen

Vaihda molemmat `nginx:latest`-viittaukset omaan julkiseen Docker-kuvaasi:

```bash
docker pull DOCKERHUB_USERNAME/my-webapp:latest

docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  DOCKERHUB_USERNAME/my-webapp:latest
```

Varmista, että:

- kuva on Docker Hubissa julkinen
- kuvan nimi ja tagi ovat oikein
- sovellus kuuntelee kontin sisällä portissa 80

Jos sovellus kuuntelee esimerkiksi portissa 3000, muuta porttijulkaisu muotoon:

```bash
-p 80:3000
```

## 10. Jatkoversio `templatefile()`-funktiolla

Kun perustehtävä toimii, Docker-kuvan nimi voidaan välittää Terraform-muuttujana.

Nimeä skripti uudelleen:

```text
cloud-init.sh.tftpl
```

Muuta Docker-komennot:

```bash
docker pull "${docker_image}"

docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  "${docker_image}"
```

Terraform:

```hcl
variable "docker_image" {
  description = "Docker image deployed to the EC2 instance"
  type        = string
  default     = "nginx:latest"
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/cloud-init.sh.tftpl", {
    docker_image = var.docker_image
  })

  tags = {
    Name = "terraform-docker-web"
  }
}
```

Tämän jälkeen Docker-kuva voidaan vaihtaa `terraform.tfvars`-tiedostossa ilman cloud-init-mallipohjan muokkaamista.

## 11. Ympäristön poistaminen

Kun harjoitus on valmis, poista resurssit kustannusten välttämiseksi:

```bash
terraform destroy
```

Varmista AWS-konsolista, että harjoituksessa luodut maksulliset resurssit on poistettu.
