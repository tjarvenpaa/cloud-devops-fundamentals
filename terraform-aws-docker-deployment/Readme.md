# Infrastructure as Code AWS:llä Terraformin avulla

## Tavoite

Tämän harjoituksen tavoitteena on tutustua Infrastructure as Code (IaC) -ajatteluun sekä Terraformin käyttöön AWS-infrastruktuurin automatisoinnissa.

Harjoituksen aikana toteutetaan AWS-ympäristö Terraformilla siten, että aiemmin käsin rakennettu infrastruktuuri luodaan automaattisesti koodin avulla. Lopputuloksena AWS:ään käynnistyy EC2-palvelin, joka asentaa Dockerin ja julkaisee verkkosovelluksen automaattisesti.

Harjoitus toimii valmistavana vaiheena kurssin seuraavalle osuudelle, jossa Terraformia ja Dockeria hyödynnetään osana GitHub Actions -pohjaista CI/CD-putkea.

---

# Oppimistavoitteet

Harjoituksen jälkeen opiskelija osaa:

- selittää Infrastructure as Code -ajattelun perusperiaatteet
- käyttää Terraformia AWS-resurssien hallintaan
- hyödyntää Terraformin provider-, resource-, variable- ja output-rakenteita
- luoda AWS-infrastruktuuria koodin avulla
- käyttää cloud-init- tai user_data-mekanismia palvelimen automaattiseen konfigurointiin
- ottaa Docker-sovelluksen käyttöön automaattisesti EC2-palvelimella
- hallita Terraformin tilatiedostoa (state)

---

# Ympäristö

Harjoituksessa käytetään:

- AWS Academy Learner Lab
- Terraform
- Git
- Docker Hub
- Ubuntu EC2 -instanssia

---

# Harjoituksen kokonaisuus

Terraformilla luodaan seuraava ympäristö:

```text
AWS
│
├── VPC
│   └── Public Subnet
│
├── Internet Gateway
│
├── Route Table
│
├── Security Group
│
└── EC2
    └── Docker Container
```

---

# Tehtävä 1: Luo Terraform-projekti

Luo projektikansio.

```bash
mkdir terraform-aws-webapp
cd terraform-aws-webapp
```

Luo vähintään seuraavat tiedostot:

```text
terraform-aws-webapp/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
```

---

# Tehtävä 2: Määritä AWS Provider

Määritä Terraform käyttämään AWS-palvelua.

Esimerkki:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

Määritä käytettävä AWS-alue muuttujan avulla.

---

# Tehtävä 3: Luo verkkoresurssit

Terraformin tulee luoda:

- VPC
- Public subnet
- Internet Gateway
- Route Table
- Route Table Association

Vaatimukset:

- VPC CIDR: 10.0.0.0/16
- Subnet CIDR: 10.0.1.0/24
- Julkinen IP käytössä

---

# Tehtävä 4: Luo Security Group

Luo Security Group, joka sallii:

### Sisääntuleva liikenne

| Portti | Protokolla | Tarkoitus |
|----------|----------|----------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |

### Ulosmenevä liikenne

- Kaikki sallittu

---

# Tehtävä 5: Luo EC2-instanssi

Luo:

- Ubuntu Server
- t3.micro tai vastaava
- Julkinen IP-osoite

Varmista, että instanssi käynnistyy onnistuneesti Terraformin avulla.

---

# Tehtävä 6: Automatisoi palvelimen asennus

Käytä Terraformin `user_data`-ominaisuutta.

Palvelimen tulee automaattisesti:

1. Päivittää pakettiluettelo
2. Asentaa Docker
3. Käynnistää Docker-palvelu
4. Julkaista verkkosovellus

Esimerkkisovellus:

```bash
docker run -d -p 80:80 nginx
```

---

# Tehtävä 7: Käytä muuttujia

Siirrä vähintään seuraavat arvot Terraform-muuttujiksi:

- AWS Region
- EC2-instanssin tyyppi
- SSH-avainpari
- Sovelluksen portti

Esimerkki:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

---

# Tehtävä 8: Lisää Outputit

Tulosta Terraform-ajon lopuksi:

- palvelimen julkinen IP
- palvelimen URL

Esimerkki:

```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}
```

---

# Tehtävä 9: Käytä omaa Docker-kuvaa

Korvaa Nginx-opetuskuva omalla Docker Hubiin julkaistulla sovelluksellasi.

Esimerkiksi:

```bash
docker run -d -p 80:80 oma-kayttaja/webapp:latest
```

Tämän tehtävän tarkoituksena on hyödyntää Docker-osuudessa rakennettua sovellusta.

---

# Terraformin käyttö

Alusta projekti:

```bash
terraform init
```

Tarkista syntaksi:

```bash
terraform validate
```

Muotoile tiedostot:

```bash
terraform fmt
```

Näytä muutokset:

```bash
terraform plan
```

Luo infrastruktuuri:

```bash
terraform apply
```

Poista infrastruktuuri:

```bash
terraform destroy
```

---

# Palautettavat materiaalit

Palauta GitHub-repositorion linkki, joka sisältää:

- Terraform-koodit
- README.md
- Kuvakaappauksen onnistuneesta Terraform Apply -ajosta
- Kuvakaappauksen toimivasta verkkosovelluksesta
- Kuvauksen käytetystä Docker-kuvasta

---

# Arviointi

## Arvosana 1-2

- Terraform toimii
- EC2-instanssi käynnistyy

## Arvosana 3

- Muuttujat käytössä
- Outputit käytössä
- Koodi dokumentoitu

## Arvosana 4

- Docker asennetaan automaattisesti
- Sovellus käynnistyy automaattisesti
- Terraform-rakenne on selkeä

## Arvosana 5

- Käytössä oma Docker-sovellus
- Terraform jaettu loogisiin tiedostoihin tai moduuleihin
- Dokumentaatio on kattava
- Toteutus noudattaa Infrastructure as Code -parhaita käytäntöjä

---

# Pohdinta

Vastaa README-tiedostossa seuraaviin kysymyksiin:

1. Mitä hyötyjä Infrastructure as Code tuo verrattuna käsin tehtäviin asennuksiin?
2. Mitkä osat ympäristöstä automatisoitiin?
3. Mitä tapahtuu Terraform State -tiedostossa?
4. Millaisia riskejä liittyy Terraform State -tiedoston hallintaan?
5. Miten tämä harjoitus liittyy DevOps- ja CI/CD-ajatteluun?

---

# Seuraava vaihe

Kurssin seuraavassa osiossa tätä infrastruktuuria hyödynnetään osana automatisoitua julkaisuprosessia, jossa GitHub Actions rakentaa Docker-kuvan, julkaisee sen Docker Hubiin ja käyttää Terraformia infrastruktuurin hallintaan.