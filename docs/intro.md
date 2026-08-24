# Cloud Infrastructure and DevOps Fundamentals (10 op)
## Kurssin kuvaus
Kurssilla tutustutaan pilvipalveluiden, infrastruktuurin hallinnan sekä DevOps-ajattelun perusteisiin. Kurssin ensimmäisessä osassa keskitytään pilviympäristöihin AWS:n avulla, minkä jälkeen siirrytään kohti moderneja DevOps-käytäntöjä, kuten konttiteknologioita, Infrastructure as Codea (IaC), Kubernetesia sekä CI/CD-automaatiota.
Kurssin tavoitteena on antaa opiskelijalle valmiudet ymmärtää ja toteuttaa nykyaikaisia pilvipohjaisia ratkaisuja sekä automatisoituja käyttöönottoprosesseja.
Kurssin aikana tehdyt harjoitukset muodostavat yhtenäisen oppimispolun, jossa siirrytään manuaalisesti rakennetuista ympäristöistä kohti automatisoituja ratkaisuja.

## Osaamistavoitteet
Kurssin suoritettuaan opiskelija osaa:
* selittää pilvipalveluiden keskeiset palvelumallit ja käyttötarkoitukset
* hyödyntää AWS:n keskeisiä infrastruktuuripalveluita
* suunnitella turvallisen ja korkean käytettävyyden pilviarkkitehtuurin
* käyttää Linux-palvelimia pilviympäristössä
* ottaa käyttöön verkkosovelluksen pilvipalvelussa
* hyödyntää Docker-kontteja sovellusten paketointiin
* toteuttaa infrastruktuuria Infrastructure as Code -periaatteella Terraformin avulla
* käyttää Kubernetesia konttisovellusten hallintaan
* ymmärtää CI/CD-putkien toimintaperiaatteet ja automatisoinnin merkityksen DevOps-ympäristöissä
* tunnistaa keskeiset erot eri pilvipalvelualustojen välillä

**Viikko 1**: Pilvipalveluiden perusteet
Sisältö
* Pilvipalveluiden peruskäsitteet. Käyttäen AWS Cloud foundations sertifikaattiin johtavaa koulutusta materiaalina
* IaaS, PaaS ja SaaS
* Public, Private ja Hybrid Cloud
* AWS Global Infrastructure
* Shared Responsibility Model
* Pilvipalveluiden kustannusmallit
Harjoitukset
* AWS Pricing Calculator
* Pilvipalveluiden kustannusten arviointi eri käyttöskenaarioissa
Osaamistavoite
Opiskelija ymmärtää pilvipalveluiden toimintamallit, hinnoittelun perusteet sekä AWS:n keskeisen palvelurakenteen.

**Viikko 2:** Verkot ja tietoturva pilvessä
Sisältö
* VPC
* CIDR
* Subnetit
* Reititys
* Internet Gateway
* NAT Gateway
* Security Groups
* IAM-perusteet
Harjoitukset
* VPC-arkkitehtuurin suunnittelu
* IAM-politiikkojen analysointi ja koventaminen
Osaamistavoite
Opiskelija osaa suunnitella pilviympäristön verkkoarkkitehtuurin sekä soveltaa vähimmän oikeuden periaatetta käyttöoikeuksien hallinnassa.

**Viikko 3:** Tallennus ja tietokannat
Sisältö
* Amazon S3
* Amazon EBS
* Amazon RDS
* Tallennustekniikoiden valinta
* Kustannukset ja suorituskyky
Harjoitukset
* Tallennusratkaisujen suunnittelu erilaisiin käyttötapauksiin
* AWS Academy -harjoitukset
Osaamistavoite
Opiskelija osaa valita käyttötarkoitukseen soveltuvan tallennusratkaisun sekä perustella valintansa.

**Viikko 4:** Linux pilviympäristössä
Sisältö
* Linux-palvelimen hallinta
* SSH-yhteydet
* Pakettienhallinta
* Cloud-init
* EC2-metatiedot
* Palveluiden ylläpito
Harjoitukset
* AWS Academy -harjoitukset
* Linux-palvelimen hallintatehtävät
Osaamistavoite
Opiskelija osaa käyttää Linux-palvelinta pilviympäristössä sekä suorittaa yleisiä ylläpitotehtäviä.

**Viikko 5:** Verkkosovelluksen käyttöönotto pilvessä
Sisältö
* LAMP-ympäristö
* Apache
* PHP
* MySQL / MariaDB
* Amazon RDS
* Amazon S3
* HTTPS ja SSL-sertifikaatit
Projekti
* WordPress-sivuston käyttöönotto AWS:ssä
Osaamistavoite
Opiskelija osaa ottaa käyttöön pilvessä toimivan verkkosovelluksen hyödyntäen useita AWS-palveluita.

**Viikko 6:** Docker ja sovellusten kontitus
Sisältö
* Docker-arkkitehtuuri
* Docker Images
* Docker Containers
* Dockerfile
* Volumes
* Networks
* Monikonttisovellukset
Harjoitukset
* Docker-perusteet
* Dockerfilejen luonti
* Frontend- ja backend-sovellusten kontitus
* Docker-projekti
Osaamistavoite
Opiskelija osaa paketoida sovelluksia Docker-konteiksi ja käyttää niitä paikallisessa kehitysympäristössä.

**Viikko 7:** Infrastructure as Code (Terraform)
Sisältö
* Infrastructure as Code -ajattelu
* Terraform-arkkitehtuuri
* Providers
* Resources
* Variables
* Outputs
* State-tiedostot
Harjoitukset
* AWS-resurssien luonti Terraformilla
* Aiemmin käsin luodun infrastruktuurin automatisointi
Osaamistavoite
Opiskelija ymmärtää Infrastructure as Code -periaatteet ja osaa luoda infrastruktuuria Terraformin avulla.

**Viikkojen 7 ja 8 välissä**
Itsenäinen työskentely
Opiskelijat viimeistelevät Terraform-harjoituksia ja valmistautuvat kurssin loppuosioon.

**Viikko 8:** Kubernetes ja CI/CD
Sisältö
Kubernetes
* Pods
* Deployments
* Services
* Ingress
* Konttien orkestrointi
CI/CD
* DevOps-ajattelu
* Continuous Integration
* Continuous Delivery
* GitHub Actions
* Automaattiset build- ja tarkastusprosessit
Harjoitukset
* Sovelluksen käyttöönotto Kubernetes-ympäristöön
* GitHub Actions -putken rakentaminen
* Docker-kuvan automaattinen rakentaminen ja julkaisu
Osaamistavoite
Opiskelija ymmärtää modernin DevOps-putken rakenteen ja osaa hyödyntää automatisointia sovellusten julkaisuprosessissa.

**Kurssin punainen lanka**
Kurssi etenee seuraavan kehityspolun mukaisesti:
![timeline-iac.png](https://github.com/tjarvenpaa/cloud-devops-fundamentals/blob/main/docs/images/timeline-IaC.png)
Kurssin lopussa opiskelija ymmärtää, kuinka moderni pilvipohjainen sovellusympäristö suunnitellaan, toteutetaan, automatisoidaan ja ylläpidetään DevOps-periaatteiden mukaisesti.

# **Arviointi**
Arviointi tapahtuu asteikolla 0-5, perusteena tehdyt harjoitukset, projektit, itsearviointi ja tentti. Tarkempi arviointi / pisteytys päivittyy tähän myöhemmin.