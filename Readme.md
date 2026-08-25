# Cloud & DevOps Fundamentals

Kurssin materiaalit, harjoitukset ja projektit pilvipalveluiden, konttiteknologioiden, Infrastructure as Code -ratkaisujen sekä DevOps-käytäntöjen opiskeluun.

Kurssi etenee vaiheittain pilvipalveluiden perusteista kohti modernia ohjelmisto- ja infrastruktuuriautomaatiota. Harjoitukset muodostavat yhtenäisen oppimispolun, jossa siirrytään manuaalisesta ympäristöjen hallinnasta kohti täysin automatisoituja ratkaisuja.

## Kurssin sisältö

### Viikko 1 - Pilvipalveluiden perusteet

- Cloud Computing -käsitteet
- IaaS, PaaS ja SaaS
- AWS Global Infrastructure
- Shared Responsibility Model
- AWS Pricing Calculator

### Viikko 2 - Verkot ja tietoturva pilvessä

- VPC
- Subnetit
- Reititys
- Security Groups
- IAM
- Vähimmän oikeuden periaate

### Viikko 3 - Tallennus ja tietokannat

- Amazon S3
- Amazon EBS
- Amazon RDS
- Tallennusratkaisujen vertailu
- Kustannusten ja suorituskyvyn arviointi

### Viikko 4 - Linux pilviympäristössä

- EC2-instanssit
- SSH-yhteydet
- Linux-palvelimen hallinta
- EC2 Metadata Service (IMDSv2)
- User Data ja Cloud-Init

### Viikko 5 - Verkkosovelluksen käyttöönotto pilvessä

- Apache
- PHP
- MariaDB
- WordPress
- HTTPS
- AWS-palveluiden hyödyntäminen verkkosovelluksessa

### Viikko 6 - Docker ja sovellusten kontitus

- Docker-arkkitehtuuri
- Docker Images
- Docker Containers
- Dockerfile
- Volumes
- Networks
- Monikonttisovellukset

### Viikko 7 - Infrastructure as Code

- Terraform-perusteet
- Providers
- Resources
- Variables
- Outputs
- Terraform State
- AWS-infrastruktuurin automatisointi

### Viikko 8 - Kubernetes ja CI/CD

- Kubernetes-perusteet
- Pods
- Deployments
- Services
- Ingress
- GitHub Actions
- Continuous Integration
- Continuous Delivery

---

# Oppimispolku

Kurssilla rakennetaan vaiheittain kokonainen pilvipohjainen palveluympäristö.

```text
Pilvipalvelut
    ↓
Verkot ja tietoturva
    ↓
Linux-palvelimet
    ↓
Verkkosovellus AWS:ssä
    ↓
Docker
    ↓
Terraform
    ↓
Kubernetes
    ↓
CI/CD
```

Kurssin lopussa opiskelija osaa suunnitella, toteuttaa, automatisoida ja ylläpitää pilvipohjaista sovellusympäristöä DevOps-periaatteiden mukaisesti.

---

# Harjoitukset

## AWS ja Linux

| Harjoitus | Kuvaus |
|-----------|---------|
| EC2-instanssin käyttöönotto, SSH-yhteys ja metatiedot | EC2-palvelimen käyttöönotto, SSH-hallinta, IMDSv2 sekä User Data -automaatio |
| VPC ja verkkosuunnittelu | Pilviverkon suunnittelu ja toteutus |
| AWS-tallennuspalvelut | S3-, EBS- ja RDS-palveluiden käyttö |

## Docker

| Harjoitus | Kuvaus |
|-----------|---------|
| Docker Basics | Dockerin perusteet |
| Dockerfile | Oman kuvan rakentaminen |
| Monikonttisovellus | Sovelluksen jakaminen useaan konttiin |

## Terraform

| Harjoitus | Kuvaus |
|-----------|---------|
| AWS Infrastructure as Code | AWS-ympäristön automatisointi Terraformilla |
| Docker-palvelun käyttöönotto Terraformilla | Docker-sovelluksen julkaiseminen AWS:ään |

## DevOps

| Harjoitus | Kuvaus |
|-----------|---------|
| GitHub Actions CI/CD | Docker-kuvan automaattinen rakentaminen |
| Terraform osana CI/CD-putkea | Infrastruktuurin automatisoitu hallinta |

---

# Hakemistorakenne

```text
aws-cloud-wp-install/
docker/
terraform-aws-docker-deployment/
kubernetes/
devops-based-pipelines/
```

Jokainen hakemisto sisältää:

- teoriaosuuden
- harjoitukset
- esimerkkiratkaisuja
- mahdolliset lisätehtävät

---

# Esitietovaatimukset

Opiskelijalta odotetaan:

- Linux-perusteiden hallintaa
- komentorivin käyttöä
- Gitin perusteiden tuntemista
- perustason verkkotekniikan ymmärrystä

Aikaisempaa kokemusta AWS:stä, Dockerista, Kubernetesista tai Terraformista ei edellytetä.

---

# Lisenssi

Kurssimateriaali julkaistaan avoimella lisenssillä.

Katso tiedosto:

```text
LICENSE
```

lisätietoja varten.

---

# Tekijä

Teemu Järvenpää  
HAMK Hämeen ammattikorkeakoulu

ICT ja pilvipalvelut