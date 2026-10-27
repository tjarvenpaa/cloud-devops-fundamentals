# WordPressin asentaminen AWS EC2 -instanssille

## Tavoite

Tässä harjoituksessa asennetaan WordPress AWS EC2 -instanssille ja luodaan sille erillinen tietokanta AWS RDS -palvelun avulla. Lopuksi kirjaudutaan WordPressiin, luodaan ensimmäinen julkaisu sekä lisätään siihen kuva S3-ämpäristä (bucket).

---

# Vaihe 1: Yhdistä EC2-instanssille

Yhdistä EC2-instanssille SSH-yhteydellä.

Esimerkki:

```bash
ssh -i mykey.pem ec2-user@PUBLIC-IP
```

Tai Ubuntu-instanssilla:

```bash
ssh -i mykey.pem ubuntu@PUBLIC-IP
```

Varmista yhteyden muodostuminen komennolla:

```bash
hostname
```

---

# Vaihe 2: Asenna WWW-palvelin ja PHP

## Amazon Linux 2023

Päivitä pakettivarastot:

```bash
sudo dnf update -y
```

Asenna Apache, PHP ja tarvittavat lisäosat:

```bash
sudo dnf install -y httpd php php-mysqlnd php-gd php-mbstring php-xml php-json wget unzip
```

Käynnistä Apache:

```bash
sudo systemctl enable httpd
sudo systemctl start httpd
```

Tarkista palvelun tila:

```bash
sudo systemctl status httpd
```

---

# Vaihe 3: Määritä Security Group

Varmista, että EC2-instanssin Security Group sallii seuraavat yhteydet:

| Portti | Protokolla | Käyttötarkoitus |
|----------|----------|----------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |

Testaa selainyhteys avaamalla:

```
http://EC2-PUBLIC-IP
```

Apache-oletussivun pitäisi näkyä selaimessa.

---

# Vaihe 4: Luo tietokanta AWS RDS -palvelussa

## 4.1 Luo RDS-instanssi

AWS Console → **RDS** → **Create Database**

Valitse:

- Engine type: **MySQL**
- Templates: **Free tier**
- DB instance identifier: `wordpress-db`
- Master username: `wpadmin`
- Master password: määritä vahva salasana

Tallenna seuraavat tiedot:

- Database endpoint
- Database name
- Username
- Password

Näitä tarvitaan myöhemmin WordPressissa.

---

## 4.2 Luo tietokanta

Kun RDS-instanssi on valmis, yhdistä siihen EC2-instanssilta.

Asenna MySQL-asiakas:

```bash
sudo dnf install -y mariadb105
```

Yhdistä tietokantaan:

```bash
mysql -h YOUR-RDS-ENDPOINT \
-u wpadmin -p
```

Esimerkki:

```bash
mysql -h wordpress-db.abc123xyz.eu-north-1.rds.amazonaws.com \
-u wpadmin -p
```

---

## 4.3 Luo WordPress-tietokanta

Kirjaudu MySQL-konsoliin ja suorita:

```sql
CREATE DATABASE wordpress
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

Tarkista tietokanta:

```sql
SHOW DATABASES;
```

Poistu:

```sql
EXIT;
```

---

# Vaihe 5: Salli yhteydet EC2-instanssilta RDS:ään

RDS:n Security Groupiin tulee lisätä sääntö:

| Portti | Lähde |
|----------|----------|
| 3306 | EC2 Security Group |

Suositeltavaa on sallia yhteys vain EC2-instanssin Security Groupilta eikä koko Internetistä.

Tarkista yhteys:

```bash
mysql -h YOUR-RDS-ENDPOINT \
-u wpadmin \
-p
```

Mikäli yhteys toimii, saat MySQL-kehotteen näkyviin.

---

# Vaihe 6: Lataa WordPress

Siirry verkkopalvelimen juurihakemistoon:

```bash
cd /var/www/html
```

Lataa WordPress:

```bash
sudo wget https://wordpress.org/latest.zip
```

Pura paketti:

```bash
sudo unzip latest.zip
```

Siirrä tiedostot oikeaan hakemistoon:

```bash
sudo cp -r wordpress/* /var/www/html/
```

Poista tarpeettomat tiedostot:

```bash
sudo rm -rf wordpress
sudo rm latest.zip
```

---

# Vaihe 7: Aseta tiedostojen käyttöoikeudet

Määritä Apache käyttäjäksi:

```bash
sudo chown -R apache:apache /var/www/html
```

Aseta oikeudet:

```bash
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;
```

---

# Vaihe 8: Määritä wp-config.php

Siirry WordPress-hakemistoon:

```bash
cd /var/www/html
```

Kopioi mallipohja:

```bash
sudo cp wp-config-sample.php wp-config.php
```

Muokkaa tiedostoa:

```bash
sudo nano wp-config.php
```

Päivitä seuraavat rivit:

```php
define( 'DB_NAME', 'wordpress' );

define( 'DB_USER', 'wpadmin' );

define( 'DB_PASSWORD', 'YOUR_PASSWORD' );

define( 'DB_HOST', 'wordpress-db.abc123xyz.eu-north-1.rds.amazonaws.com' );

define( 'FS_METHOD', 'direct' );
```

Tallenna muutokset.

---

# Vaihe 9: Suorita WordPress-asennus

Avaa selain:

```
http://EC2-PUBLIC-IP
```

Tai:

```
http://DOMAIN-NAME
```

WordPressin asennusvelho käynnistyy.

Täytä seuraavat tiedot:

## Sivuston tiedot

**Site Title**

Esim.

```
My AWS WordPress Site
```

**Username**

WordPress-pääkäyttäjä.

**Password**

Vahva salasana.

**Your Email**

Oma sähköpostiosoitteesi.

**Search Engine Visibility**

Valitse haluatko hakukoneiden löytävän sivuston.

Paina:

```
Install WordPress
```

---
# Vaihe 10: Ota HTTPS käyttöön Let's Encryptillä

HTTPS suojaa liikenteen käyttäjän selaimen ja palvelimen välillä sekä on käytännössä välttämätön nykyaikaiselle verkkosivulle.

## Vaatimukset

Ennen HTTPS:n käyttöönottoa varmista, että:

- Sinulla on toimiva verkkotunnus (esim. `example.com`), Voit tähän hakea ilmaisen domain nimen esim. [GitHub Student Developer Pack](https://education.github.com/pack) kautta. Tällöin eri palvelun tarjoajat (kuten NameCheap, name.com ja muut) tarjoavat ilmaisen domain rekisteröinnin .me, .live, .studio, .dev yms tld nimissä. 
- DNS-tietue osoittaa EC2-instanssin julkiseen IP-osoitteeseen. Voit toteuttaa tämän joko domain rekisteröinti firman dns palvelun kautta, tai käyttää [cloudflaren](https://www.cloudflare.com/plans/) ilmaista palvelua
- Security Group sallii liikenteen porteissa:
  - TCP 80 (HTTP)
  - TCP 443 (HTTPS)

---

## 10.1 Tarkista DNS

Varmista, että verkkotunnus osoittaa EC2-instanssille.

Esimerkki:

```bash
nslookup example.com
```

Tuloksen tulisi näyttää EC2-instanssin julkinen IP-osoite. Tämä on kriittinen vaihe, etenkin jos siirsit dns rekisteröitymisen Cloudflaren hallittavaksi. Tarkista aina ennen kuin jatkat.

---

## 10.2 Asenna Certbot

Amazon Linux 2023:

```bash
sudo dnf install -y certbot python3-certbot-apache
```

Tarkista asennus:

```bash
certbot --version
```

---

## 10.3 Hae SSL-sertifikaatti

Suorita:

```bash
sudo certbot --apache
```

Tai usealle verkkotunnukselle:

```bash
sudo certbot --apache \
-d example.com \
-d www.example.com
```

Asennus kysyy:

- sähköpostiosoitetta
- hyväksynnän käyttöehdoille
- halutaanko HTTP-ohjaus HTTPS:ään

Valitse:

```
Redirect HTTP to HTTPS
```

Tämä pakottaa kaiken liikenteen HTTPS-yhteyden kautta.

---

## 10.4 Testaa HTTPS

Avaa selaimella:

```
https://example.com
```

Selaimen osoiterivillä pitäisi näkyä lukkoikoni.

Tarkista myös:

```
https://www.ssllabs.com/ssltest/
```

Anna verkkotunnuksesi analysoitavaksi.

---

## 10.5 Testaa sertifikaatin uusinta

Let's Encrypt -sertifikaatit ovat voimassa 90 päivää.

Testaa uusinta:

```bash
sudo certbot renew --dry-run
```

Onnistuneen testin jälkeen saat ilmoituksen, että uusiminen toimii.

---

## 10.6 Päivitä WordPress käyttämään HTTPS:ää

Kirjaudu WordPressiin.

Siirry:

```
Settings → General
```

Päivitä seuraavat kentät:

**WordPress Address (URL)**

```
https://example.com
```

**Site Address (URL)**

```
https://example.com
```

Tallenna muutokset.

---

## 10.7 Pakota HTTPS WordPressissa (valinnainen)

Mikäli sivusto edelleen lataa sisältöä HTTP:n kautta, lisää tiedostoon:

```bash
sudo nano /var/www/html/wp-config.php
```

Seuraava rivi ennen kohtaa:

```php
/* That's all, stop editing! */
```

```php
define('FORCE_SSL_AD*IN', true);
```

Tämä pak*ttaa WordPressin hallintapane*lin käyttämään HTTPS-yhteyttä.

--*

#*HTTPS-tarkistuslista

V*rm*sta lopuksi, että:

- [ * Ver*kotunnus osoittaa EC2-instanss*lle.
- [ ] Portit 80 ja 443*ovat*avoinna Security Groupissa.
-*[*] Let's Encrypt -sertifikaatti on *sennettu.
- [ ] HTTP oh*autuu automaattisesti HTTPS:ään*
- [ ] WordPress käyttää HTTPS-oso*tte*ta.
- [ ] Selain näyttää*luk*oikonin.
- [ ] `*ert*ot renew --dry-run` toimii onnistu*eesti.

# Vaihe 11: Kirjaudu WordPressiin

Avaa:

```
https://EC2-PUBLIC-IP/wp-admin
```

Kirjaudu tunnuksilla, jotka loit edellisessä vaiheessa.

---

# Vaihe 12: Luo S3 Bucket kuvia varten

Avaa AWS Console.

Siirry:

```
S3 → Create Bucket
```

Esimerkki:

```
wordpress-images-yourname
```

Lataa vähintään yksi kuva bucketiin.

---

# Vaihe 13: Tee kuva julkiseksi

Valitse kuva bucketista.

Kopioi kuvan URL-osoite:

```
https://bucket-name.s3.amazonaws.com/image.jpg
```

Tarvittaessa lisää bucket policy tai määritä objekti julkisesti luettavaksi.

Varmista, että kuva avautuu selaimessa.

---

# Vaihe 14: Luo ensimmäinen julkaisu

WordPressissa:

**Posts → Add New**

Luo julkaisu nimeltä:

```
My First AWS WordPress Post
```

Julkaisun tulee sisältää:

- Lyhyt esittelyteksti
- Vähintään yksi kuva S3-bucketista
- Vähintään yksi hyperlinkki

Esimerkkikuva HTML-muodossa:

```html
https://bucket-name.s3.amazonaws.com/image.jpg
```

Julkaise artikkeli painamalla:

```
Publish
```

---

# Tarkistuslista

Varmista lopuksi, että:

- [ ] EC2-instanssi on käynnissä.
- [ ] Apache-palvelu toimii.
- [ ] WordPress näkyy selaimessa.
- [ ] RDS-tietokanta on käytössä.
- [ ] WordPress käyttää RDS-tietokantaa.
- [ ] WordPress käyttää HTTPS protokollaa
- [ ] S3-bucket on luotu.
- [ ] Julkaisussa on vähintään yksi S3-kuva.
- [ ] Sivustolle voidaan kirjautua `/wp-admin`-osoitteessa.
- [ ] Ensimmäinen julkaisu on julkaistu onnistuneesti.

