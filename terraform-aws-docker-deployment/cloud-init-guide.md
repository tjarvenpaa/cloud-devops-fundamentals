# Cloud-init pilvipalvelimen automaattisessa konfiguroinnissa

## Johdanto

Cloud-init on työkalu, jonka avulla pilvipalvelussa luotava virtuaalikone voidaan konfiguroida automaattisesti ensimmäisen käynnistyksen yhteydessä. Sen avulla palvelimelle voidaan esimerkiksi asentaa ohjelmistoja, luoda käyttäjiä, kirjoittaa asetustiedostoja ja käynnistää palveluita ilman manuaalista SSH-yhteyttä.

Tässä projektissa vastuut jakautuvat seuraavasti:

- **Terraform** luo AWS-infrastruktuurin.
- **EC2 User Data** välittää käynnistysmäärityksen virtuaalikoneelle.
- **Cloud-init** suorittaa määrityksen palvelimen ensimmäisen käynnistyksen aikana.
- **Docker** suorittaa varsinaisen sovelluksen kontissa.

```text
Terraform
    |
    v
AWS EC2 -instanssi
    |
    v
EC2 User Data
    |
    v
Cloud-init
    |
    +--> päivittää pakettiluettelon
    +--> asentaa Dockerin
    +--> käynnistää Docker-palvelun
    +--> noutaa Docker-kuvan
    +--> käynnistää sovelluskontin
    |
    v
Sovellus on käytettävissä
```

## Oppimistavoitteet

Tämän materiaalin jälkeen opiskelija osaa:

- selittää Terraformin, EC2 User Datan ja cloud-initin välisen työnjaon
- käyttää cloud-initia EC2-instanssin ensimmäiseen konfigurointiin
- välittää erillisen cloud-init-tiedoston Terraformille
- asentaa Dockerin ja käynnistää kontin automaattisesti
- tarkistaa cloud-initin tilan ja lokit
- tunnistaa tavallisimmat automaattisen käyttöönoton virhetilanteet
- käsitellä cloud-init-skriptejä turvallisesti versionhallinnassa

## 1. Mikä cloud-init on?

Cloud-init suorittaa virtuaalikoneelle annetun alustavan määrityksen käyttöjärjestelmän ensimmäisen käynnistyksen aikana. AWS-ympäristössä määritys toimitetaan EC2-instanssille yleensä User Data -kentän kautta.

Cloud-initilla voidaan esimerkiksi:

- päivittää pakettien lähdeluettelo
- asentaa ohjelmistopaketteja
- luoda käyttäjiä ja ryhmiä
- lisätä SSH-avaimia
- kirjoittaa asetustiedostoja
- ottaa systemd-palveluita käyttöön
- käynnistää komentoja ja skriptejä
- rekisteröidä palvelin ulkoiseen hallintajärjestelmään
- käynnistää Docker-kontteja

Cloud-init ei kuitenkaan ole yleiskäyttöinen jatkuvan konfiguraation hallintajärjestelmä. Se soveltuu erityisesti palvelimen alkuasetusten tekemiseen. Myöhemmin tapahtuvaan laajaan ja jatkuvaan konfiguraation hallintaan voidaan käyttää esimerkiksi Ansiblea tai muuta tarkoitukseen soveltuvaa työkalua.

## 2. Terraformin ja cloud-initin työnjako

Terraform ja cloud-init ratkaisevat eri ongelmia.

### Terraform

Terraform kuvaa ja luo infrastruktuurin, kuten:

- VPC-verkon
- aliverkon
- Internet Gatewayn
- reititystaulun
- Security Groupin
- EC2-instanssin
- julkisen IP-osoitteen

### Cloud-init

Cloud-init määrittää EC2-instanssin käyttöjärjestelmän ja sovelluksen, kuten:

- Dockerin asentamisen
- Docker-palvelun käynnistämisen
- Docker-kuvan noutamisen
- sovelluskontin käynnistämisen

Hyvä nyrkkisääntö on:

> Terraform luo palvelimen. Cloud-init valmistelee palvelimen käyttöön.

## 3. EC2 User Data

Terraform välittää cloud-init-määrityksen EC2-instanssille `user_data`-argumentin avulla.

Lyhyt skripti voidaan kirjoittaa suoraan Terraform-resurssiin:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
  EOF
}
```

Tämä toimii pienessä esimerkissä, mutta pidempi skripti tekee Terraform-tiedostosta vaikeasti luettavan. Tässä projektissa cloud-init pidetään erillisessä tiedostossa.

## 4. Suositeltu projektirakenne

```text
terraform-aws-docker-deployment/
├── README.md
├── resources/
│   ├── cloud-init-guide.md
│   └── cloud-init-example.md
└── starter-code/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── terraform.tfvars.example
    ├── cloud-init.sh
    └── .gitignore
```

Tässä rakenteessa:

- `resources/cloud-init-guide.md` sisältää teoria- ja vianmääritysmateriaalin
- `resources/cloud-init-example.md` selittää projektissa käytettävän esimerkin
- `starter-code/cloud-init.sh` sisältää suoritettavan Bash-skriptin
- `main.tf` liittää skriptin EC2-instanssin User Dataksi

## 5. Erillisen cloud-init-tiedoston käyttäminen

Terraformin `file()`-funktio lukee tiedoston sellaisenaan:

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

`${path.module}` viittaa sen Terraform-moduulin hakemistoon, jossa määritys sijaitsee. Tämä tekee tiedostopolusta riippumattoman siitä, mistä hakemistosta Terraform-komento suoritetaan.

### Muuttujien välittäminen cloud-initiin

Jos skriptiin halutaan välittää Terraform-muuttujia, käytetään `templatefile()`-funktiota.

Terraform:

```hcl
variable "docker_image" {
  description = "Docker image deployed to the EC2 instance"
  type        = string
  default     = "nginx:latest"
}

variable "application_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 80
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/cloud-init.sh.tftpl", {
    docker_image    = var.docker_image
    application_port = var.application_port
  })
}
```

Mallipohja `cloud-init.sh.tftpl`:

```bash
#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y docker.io
systemctl enable --now docker

docker pull "${docker_image}"
docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p ${application_port}:80 \
  "${docker_image}"
```

Yksinkertaisessa perustehtävässä `file()` riittää. `templatefile()` sopii jatkotehtäväksi, kun Docker-kuva ja portti halutaan määrittää Terraform-muuttujilla.

## 6. Bash-pohjainen cloud-init-skripti

Tässä projektissa käytetään tavallista Bash-skriptiä:

```bash
#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y docker.io
systemctl enable --now docker

docker pull nginx:latest
docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  nginx:latest
```

### Skriptin osat

#### Shebang

```bash
#!/bin/bash
```

Shebang määrittää, että skripti suoritetaan Bash-komentotulkilla. Sen on oltava tiedoston ensimmäisellä rivillä.

#### Tiukempi virheenkäsittely

```bash
set -euxo pipefail
```

Asetukset helpottavat virheiden havaitsemista:

- `-e` keskeyttää skriptin virheeseen
- `-u` käsittelee määrittelemättömän muuttujan virheenä
- `-x` kirjoittaa suoritetut komennot lokiin
- `pipefail` palauttaa putkitetun komentoketjun virheen oikein

Huomaa, että `-x` voi tulostaa komentojen sisältämiä arvoja lokiin. Salaisuuksia ei tule käsitellä suoraan skriptissä.

#### Pakettien asennus

```bash
apt-get update -y
apt-get install -y docker.io
```

Automaattisessa, ei-interaktiivisessa skriptissä käytetään yleensä `apt-get`-komentoa. `-y` hyväksyy asennuksen ilman käyttäjän syötettä.

#### Docker-palvelu

```bash
systemctl enable --now docker
```

Komento ottaa Docker-palvelun käyttöön tulevia käynnistyksiä varten ja käynnistää sen heti.

#### Kontin käynnistäminen

```bash
docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  nginx:latest
```

Asetukset tarkoittavat:

- `-d` suorittaa kontin taustalla
- `--name webapp` antaa kontille nimen
- `--restart unless-stopped` käynnistää kontin uudelleen palvelimen käynnistyessä
- `-p 80:80` julkaisee kontin portin 80 palvelimen portissa 80

## 7. Cloud-initin suorittaminen ja käyttöönoton tarkistaminen

Suorita Terraform-työnkulku:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Terraformin valmistuminen ei välttämättä tarkoita, että cloud-init on jo suorittanut kaikki asennukset. EC2-instanssi voi olla AWS:n näkökulmasta käynnissä samalla, kun pakettien asennus tai Docker-kuvan lataaminen on vielä kesken.

Yhdistä palvelimeen SSH:lla ja odota cloud-initin valmistumista:

```bash
ssh -i PRIVATE_KEY.pem ubuntu@PUBLIC_IP
```

```bash
sudo cloud-init status --wait
```

Tarkista lopuksi:

```bash
sudo systemctl status docker --no-pager
sudo docker ps
curl http://localhost
```

Sovelluksen tulee vastata myös selaimessa:

```text
http://PUBLIC_IP
```

## 8. Lokit ja vianmääritys

### Cloud-initin tila

```bash
sudo cloud-init status --long
```

### Cloud-initin tulosteloki

```bash
sudo less /var/log/cloud-init-output.log
```

Tämä on yleensä ensimmäinen tarkistettava tiedosto, koska se sisältää skriptin komentojen tulosteet ja virheilmoitukset.

### Cloud-initin varsinainen loki

```bash
sudo less /var/log/cloud-init.log
```

### User Data instanssissa

```bash
sudo cat /var/lib/cloud/instance/user-data.txt
```

Tarkista, että AWS:lle välitetty sisältö vastaa odotettua skriptiä.

### Docker-palvelu

```bash
sudo systemctl status docker --no-pager
sudo journalctl -u docker --no-pager
```

### Kontit ja niiden lokit

```bash
sudo docker ps -a
sudo docker logs webapp
```

### Kuuntelevat portit

```bash
sudo ss -lntp
```

### Paikallinen HTTP-testi

```bash
curl -v http://localhost
```

Jos paikallinen testi toimii mutta sovellus ei avaudu internetistä, tarkista erityisesti AWS Security Group, reititys, julkinen IP-osoite ja aliverkon asetukset.

## 9. Tavallisimmat virhetilanteet

### Skripti ei käynnisty

Mahdollisia syitä:

- `#!/bin/bash` ei ole ensimmäisellä rivillä
- tiedosto sisältää Windows-tyyliset CRLF-rivinvaihdot
- skriptissä on syntaksivirhe
- `user_data` osoittaa väärään tiedostopolkuun

Tarkista skripti paikallisesti:

```bash
bash -n cloud-init.sh
```

### Docker ei asennu

Tarkista verkkoyhteys ja DNS:

```bash
ping -c 3 1.1.1.1
getent hosts archive.ubuntu.com
```

Tarkista myös, että:

- aliverkolla on reitti Internet Gatewaylle
- EC2-instanssilla on julkinen IP-osoite
- Security Group sallii ulospäin lähtevän liikenteen

### Kontti ei käynnisty

```bash
sudo docker ps -a
sudo docker logs webapp
```

Tavallisia syitä ovat:

- virheellinen Docker-kuvan nimi tai tagi
- Docker-kuva on yksityinen
- kontin sisäinen portti ei ole 80
- samalla nimellä oleva kontti on jo olemassa

### HTTP-yhteys ei toimi ulkopuolelta

Tarkista:

- Security Group sallii TCP-portin 80
- EC2-instanssilla on julkinen IPv4-osoite
- public subnetin reititystaulussa on oletusreitti Internet Gatewaylle
- kontti on käynnissä
- porttijulkaisu vastaa sovelluksen todellista kuunteluporttia

### Muutettu cloud-init ei suoriteta uudelleen

EC2 User Data suoritetaan tavallisesti ensimmäisen käynnistyksen yhteydessä. Pelkkä skriptin muuttaminen Terraform-koodissa ei aina johda siihen, että jo olemassa oleva instanssi konfiguroidaan uudelleen halutulla tavalla.

Harjoituksessa selkein ratkaisu on luoda instanssi uudelleen:

```bash
terraform apply -replace=aws_instance.web
```

Vaihtoehtoisesti koko ympäristö voidaan tuhota ja luoda uudelleen:

```bash
terraform destroy
terraform apply
```

Muista varmistaa resurssin nimi omasta Terraform-koodista ennen `-replace`-valinnan käyttöä.

## 10. Turvallisuus

Cloud-init-skripti ja EC2 User Data eivät ole sopiva paikka salaisuuksille.

Älä tallenna skriptiin:

- AWS Access Key -avaimia
- AWS Secret Access Key -avaimia
- Docker Hub -salasanaa
- henkilökohtaisia käyttöoikeustunnuksia
- tietokantojen salasanoja
- yksityisiä SSH-avaimia

User Data voi olla luettavissa instanssin sisältä, näkyä lokeissa tai päätyä Terraformin state-tiedostoon. Salaisuuksien hallintaan käytetään esimerkiksi pilvipalvelun salaisuuksien hallintapalvelua ja EC2-instanssille annettua IAM-roolia.

Security Groupin SSH-sääntöä ei myöskään tule tuotantoympäristössä avata koko internetille. Harjoituksessa opiskelijan kannattaa rajata portti 22 omaan julkiseen IP-osoitteeseensa.

## 11. Idempotenssi ja uudelleen suoritettavuus

Hyvä automaatio pyrkii siihen, että sama määritys voidaan suorittaa turvallisesti uudelleen. Tätä kutsutaan idempotenssiksi.

Esimerkiksi seuraava komento epäonnistuu, jos samanniminen kontti on jo olemassa:

```bash
docker run --name webapp nginx:latest
```

Uudelleen suoritettavuutta voidaan parantaa poistamalla mahdollinen vanha kontti ennen uuden käynnistämistä:

```bash
docker rm -f webapp 2>/dev/null || true

docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  nginx:latest
```

Perustehtävässä cloud-init suoritetaan uuden instanssin ensimmäisellä käynnistyksellä, mutta uudelleen suoritettavuuden huomioiminen on hyödyllinen DevOps-periaate.

## 12. Harjoitustehtävä

Toteuta EC2-instanssin automaattinen konfigurointi erillisellä `cloud-init.sh`-tiedostolla.

### Pakolliset vaatimukset

Skriptin tulee:

1. käyttää Bash-komentotulkkia
2. päivittää pakettien lähdeluettelo
3. asentaa Docker
4. ottaa Docker-palvelu käyttöön ja käynnistää se
5. noutaa Docker-kuva
6. käynnistää sovelluskontti taustalla
7. julkaista sovellus EC2-instanssin portissa 80
8. määrittää kontille uudelleenkäynnistyskäytäntö

Terraform-koodin tulee:

1. lukea skripti `file()`- tai `templatefile()`-funktiolla
2. välittää se EC2-instanssin `user_data`-argumentille
3. tulostaa vähintään instanssin julkinen IP-osoite ja sovelluksen URL

### Todentaminen

Dokumentoi raporttiin:

- onnistunut `terraform apply`
- `cloud-init status --long`
- `docker ps`
- selaimessa toimiva sovellus
- lyhyt kuvaus Terraformin ja cloud-initin työnjaosta

### Jatkohaasteet

- Vaihda Nginx omaan Docker Hubissa julkaistuun Docker-kuvaan.
- Käytä `templatefile()`-funktiota ja välitä Docker-kuvan nimi Terraform-muuttujana.
- Lisää yksinkertainen `/health`-terveystarkistus sovellukseen.
- Lisää Docker-kontille healthcheck.
- Kirjoita käyttöönoton lopputulos erilliseen lokitiedostoon.
- Selvitä, kuinka yksityinen Docker-kuva voidaan ottaa käyttöön ilman salasanan tallentamista Git-repositorioon.

## 13. Pohdintakysymykset

1. Mitä eroa on infrastruktuurin provisioinnilla ja palvelimen konfiguroinnilla?
2. Miksi cloud-init kannattaa pitää erillisessä tiedostossa?
3. Miksi Terraformin valmistuminen ei välttämättä tarkoita, että sovellus on heti valmis?
4. Mistä lokista aloittaisit vianmäärityksen, jos Docker ei asennu?
5. Miksi salaisuuksia ei tule tallentaa User Dataan?
6. Mitä idempotenssi tarkoittaa automaatiossa?
7. Milloin käyttäisit cloud-initia ja milloin erillistä konfiguraationhallintatyökalua?

## Yhteenveto

Cloud-init yhdistää infrastruktuurin luonnin ja palvelimen automaattisen käyttöönoton. Terraform luo AWS-resurssit, minkä jälkeen cloud-init asentaa EC2-instanssille Dockerin ja käynnistää sovelluksen. Lopputuloksena ympäristö voidaan rakentaa uudelleen versionhallintaan tallennetun koodin perusteella ilman palvelimen manuaalista konfigurointia.
