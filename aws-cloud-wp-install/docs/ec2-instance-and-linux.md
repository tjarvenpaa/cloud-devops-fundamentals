# Harjoitus: EC2-instanssin käyttöönotto, SSH-yhteys ja metatiedot AWS-ympäristössä
## Tavoite
Tässä harjoituksessa luot Ubuntu-pohjaisen Amazon EC2 -instanssin AWS Academy Learner Lab -ympäristössä. Harjoituksen aikana muodostat palvelimeen SSH-yhteyden, asennat verkkopalvelimen, haet instanssin metatietoja IMDSv2-menetelmällä ja tuot osan metatiedoista näkyviin verkkosivulle.
Harjoituksen lopuksi automatisoit samat vaiheet User Data -skriptillä.
Harjoituksen jälkeen ymmärrät:

* mitä EC2-instanssi tarkoittaa
* mitä tietoja SSH-yhteyden muodostamiseen tarvitaan
* mikä on SSH-avainpari ja miksi yksityistä avainta suojataan
* miten turvallisuusryhmän säännöt vaikuttavat yhteyksiin
* miten EC2-instanssin metatietopalvelua käytetään
* miksi IMDSv2 on turvallisempi kuin IMDSv1
* miten palvelimen käyttöönottoa voidaan automatisoida User Data -skriptillä

## 1. Luo EC2-testipalvelin
Luo AWS Academy Learner Lab -ympäristöön uusi Ubuntu-pohjainen EC2-instanssi.
Käytä seuraavia asetuksia:
Asetus Valinta
Palvelu EC2
Käyttöjärjestelmä Ubuntu
Instanssityyppi t2.micro tai muu lab-ympäristössä sallittu pieni instanssi
Avainpari vockey
Tallennustila oletusasetus riittää
Turvallisuusryhmä salli SSH ja HTTP
Instanssin nimi esimerkiksi Test host HAMK
Huomio turvallisuusryhmästä
Turvallisuusryhmä toimii instanssin palomuurina. Tässä harjoituksessa tarvitset vähintään:

* SSH, portti 22, jotta voit kirjautua palvelimelle
* HTTP, portti 80, jotta voit testata verkkopalvelinta
Jos käytät julkista HTTP-yhteyttä, portin 80 on oltava sallittu turvallisuusryhmässä. Jos HTTP-yhteys ei toimi lab-ympäristön rajoitusten vuoksi, verkkopalvelinta voidaan testata myös SSH-yhteyden kautta paikallisesti.
### Palautettava näyttö
Ota kuvakaappaus EC2-konsolista, jossa näkyy:
* instanssin nimi
* instanssin tila
* julkinen IP-osoite tai julkinen DNS-nimi
* tilatarkistusten onnistuminen

## 2. SSH-yhteyden muodostaminen EC2-instanssiin
SSH-yhteys tarkoittaa salattua komentoriviyhteyttä palvelimelle. Sen avulla voit hallita Linux-palvelinta komentoriviltä.
SSH-yhteyttä varten tarvitset seuraavat tiedot:
Tarvittava tieto Mistä löydät sen
Palvelimen julkinen IP-osoite tai DNS-nimi EC2-konsolin instanssin tiedoista
Käyttäjätunnus Ubuntu-instanssissa yleensä ubuntu
Yksityinen avain AWS Academy Learner Labin AWS Details -osiosta
Avainparin nimi tässä harjoituksessa vockey
Sallittu SSH-liikenne turvallisuusryhmän portti 22
**Mikä on SSH-avainpari?**
SSH-avainpari koostuu kahdesta osasta:

* julkinen avain, joka liitetään EC2-instanssiin
* yksityinen avain, joka jää käyttäjälle ja jolla yhteys muodostetaan
Yksityistä avainta ei saa jakaa muille. Jos joku muu saa yksityisen avaimen haltuunsa, hän voi mahdollisesti kirjautua palvelimelle.
AWS Academy Learner Labissa avainpari on yleensä valmiiksi nimellä vockey. Opiskelija lataa yksityisen avaimen lab-ympäristöstä.


### SSH-yhteys Windowsista
Jos käytät Windowsia, voit muodostaa SSH-yhteyden esimerkiksi PowerShellillä, Windows Terminalilla tai PuTTYllä.
Vaihtoehto A: PowerShell tai Windows Terminal
Jos sinulla on käytössä .pem-avain, yhteyden rakenne on seuraava:
1     ssh -i avaintiedosto.pem ubuntu@JULKINEN_IP_OSOITE
Esimerkissä:

* ssh käynnistää SSH-yhteyden
* -i kertoo, mitä yksityistä avainta käytetään
* avaintiedosto.pem on ladattu yksityinen avain
* ubuntu on käyttäjätunnus Ubuntu-palvelimelle
* JULKINEN_IP_OSOITE korvataan EC2-instanssin julkisella IP-osoitteella
Jos saat virheen avaimen oikeuksista, tarkista, että avaintiedosto on tallennettu turvalliseen paikkaan eikä muilla käyttäjillä ole siihen oikeuksia.

### Vaihtoehto B: PuTTY
Jos käytät PuTTYä, tarvitset yleensä .ppk-muotoisen avaimen.
PuTTY-yhteydessä tarvitset:
* host name: ubuntu@JULKINEN_IP_OSOITE
* portti: 22
* connection type: SSH
* private key file: ladattu .ppk-avain
PuTTYssä yksityinen avain valitaan yleensä kohdasta:
1     Connection → SSH → Auth → Credentials
Tämän jälkeen avaat yhteyden ja hyväksyt ensimmäisellä kirjautumiskerralla palvelimen avaimen.

### SSH-yhteys macOS- tai Linux-ympäristöstä
macOS- ja Linux-ympäristöissä SSH toimii yleensä suoraan terminaalista.
Siirry ensin kansioon, johon tallensit avaimen. Varmista sen jälkeen, että yksityisen avaimen oikeudet ovat riittävän tiukat:
1     chmod 400 avaintiedosto.pem

Muodosta sitten yhteys:
1     ssh -i avaintiedosto.pem ubuntu@JULKINEN_IP_OSOITE
Ensimmäisellä yhteyskerralla SSH kysyy, luotatko palvelimen avaimeen. Vastaa yes, jos IP-osoite vastaa omaa EC2-instanssiasi.
### Palautettava näyttö
Ota kuvakaappaus onnistuneesta SSH-yhteydestä. Kuvakaappauksesta tulee näkyä, että olet kirjautunut Ubuntu-palvelimelle.

## Palvelimen perusasetukset
Kun olet kirjautunut palvelimelle, tarkista ensin, millä käyttäjällä olet kirjautuneena:
```console
whoami
```
Tämän pitäisi yleensä palauttaa:
```console
ubuntu
```
Päivitä pakettilistat:
```console
sudo apt update
```
Tarkista, ilmoittaako järjestelmä päivitettäviä paketteja. Kirjaa ylös, kuinka monta pakettia järjestelmä ilmoittaa päivitettäväksi.
Voit asentaa harjoituksessa tarvittavia paketteja Ubuntu-palvelimen paketinhallinnan avulla. Tarvitset myöhemmin ainakin:

* verkkopalvelimen
* työkalun HTTP-pyyntöihin
* mahdollisesti komentorivipohjaisen selaimen testaamista varten

### Palautettava näyttö

Palauta:

* käytetyt keskeiset komennot
* tieto päivitettävien pakettien määrästä
* lyhyt kuvaus siitä, mitä teit palvelimen valmistelussa

## 6. Swap-tilan tarkistaminen ja lisääminen

Tarkista ensin, onko palvelimella swap-tilaa:

```console
cat /proc/swaps
```

Voit tarkistaa muistin ja swapin tilanteen myös komennolla:

```console
free -h
```

Lisää palvelimelle 1 Gt swap-tilaa AWS:n dokumentaation tai muun luotettavan ohjeen avulla. Tavoitteena ei ole vain kopioida komentoja, vaan ymmärtää mitä vaiheissa tehdään.

Kun swap on lisätty, varmista tilanne uudelleen:

```console
free -h
cat /proc/swaps
```

### Pohdintakysymys

Miksi swap-tilasta voi olla hyötyä pienellä virtuaalipalvelimella, kuten t2.micro-instanssilla?

### Palautettava näyttö

Palauta:

* kuvakaappaus swap-tilanteesta ennen muutosta
* kuvakaappaus swap-tilanteesta muutoksen jälkeen
* lyhyt vastaus pohdintakysymykseen

## 7. EC2-instanssin metatietopalvelu

EC2-instanssilla on käytettävissä metatietopalvelu. Sen avulla instanssi voi kysyä tietoja itsestään ilman, että tietoja tarvitsee kirjoittaa käsin.
Metatietopalvelun osoite on:

```text
http://169.254.169.254/latest/meta-data/
```

Tämä osoite toimii vain EC2-instanssin sisältä. Sitä ei siis avata omalta tietokoneelta selaimella, vaan palvelimelta SSH-yhteyden kautta.
Metatiedoista voi löytyä esimerkiksi:

* instanssin tunniste
* instanssityyppi
* paikallinen IP-osoite
* saatavuusalue
* julkinen avain
* verkkoasetuksia

### IMDSv1 ja IMDSv2
EC2-metatietoja voidaan hakea kahdella tavalla:

| Menetelmä | Kuvaus |
| --- | --- |
| IMDSv1 | Vanhempi tapa, jossa metatietoja voidaan kysyä suoraan HTTP-pyynnöllä |
| IMDSv2 | Uudempi ja turvallisempi tapa, jossa ensin haetaan istuntokohtainen token |

IMDSv2 on turvallisempi, koska metatietojen lukeminen vaatii erillisen tokenin. Tämä vähentää riskiä, että jokin palvelimella toimiva haavoittuva sovellus pääsisi hakemaan metatietoja liian helposti.

### IMDSv2:n perusidea

IMDSv2 toimii kahdessa vaiheessa:

1. pyydetään metatietopalvelulta token
2. käytetään tokenia varsinaisessa metatietokyselyssä

Token voidaan tallentaa muuttujaan, jotta sitä voidaan käyttää myöhemmin samassa komentotulkissa.
Esimerkki rakenteesta:

```bash
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
```

Tämän jälkeen tokenia käytetään metatiedon hakemisessa:

```bash
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/
```

Instanssin tunniste voidaan hakea polusta:

```text
/latest/meta-data/instance-id
```

### Tehtävä

Hae IMDSv2-menetelmällä ainakin seuraava tieto:

* EC2-instanssin tunniste
Voit halutessasi hakea myös muita tietoja, kuten:
* instanssityyppi
* saatavuusalue
* paikallinen IP-osoite

### Palautettava näyttö

Palauta komentorivin tuloste, josta näkyy, että sait haettua instanssin tunnisteen IMDSv2-menetelmällä.

1. Apache-verkkopalvelimen asentaminen
Asenna palvelimelle Apache-verkkopalvelin. Apache tarjoaa oletuksena verkkosivun hakemistosta:

```text
/var/www/html/
```

Tiedosto:

```text 
/var/www/html/index.html
```

on verkkopalvelimen oletusetusivu.
Kun Apache toimii, voit testata sitä palvelimen sisältä esimerkiksi osoitteella:

```console 
curl <http://localhost>
```

tai komentorivipohjaisella selaimella, jos sellainen on asennettu:

```console 
www-browser <http://localhost>
```

Jos julkinen HTTP-yhteys toimii, voit testata sivua myös omalta tietokoneeltasi selaimella:

```url 
http://JULKINEN_IP_OSOITE
```

Jos selain ei saa yhteyttä, tarkista:

* onko Apache käynnissä
* salliiko turvallisuusryhmä HTTP-liikenteen porttiin 80
* onko instanssilla julkinen IP-osoite
* rajoittaako AWS Academy Learner Lab julkisia yhteyksiä

1. IMDSv2-metatiedon vieminen verkkosivulle
Tässä vaiheessa tavoitteena on, että verkkosivulla näkyy EC2-instanssin tunniste. Tunnistetta ei saa kirjoittaa käsin, vaan se haetaan metatietopalvelusta IMDSv2-menetelmällä.
Yksi mahdollinen toimintaperiaate on:
1. hae IMDSv2-token
1. hae instanssin tunniste tokenin avulla
1. tallenna tunniste muuttujaan
1. luo tai päivitä /var/www/html/index.html
1. lisää sivulle teksti, jossa instanssin tunniste näkyy
1. testaa sivu selaimella tai komentoriviltä
Esimerkinomaisesti voit ajatella toteutuksen näin:

```console
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
     -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
     EC2ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
     <http://169.254.169.254/latest/meta-data/instance-id>)
```

Tämän jälkeen muuttujassa EC2ID on instanssin tunniste.
Voit käyttää muuttujaa HTML-sivun luomisessa esimerkiksi siten, että kirjoitat tiedostoon otsikon ja tunnisteen. Lopullisen sivun tulee näyttää käyttäjälle selkeästi, minkä EC2-instanssin sivu on kyseessä.
HTML-sivun sisältö voi olla yksinkertainen, esimerkiksi:

```html
<h1>EC2-instanssin tiedot</h1>
<p>Tämä sivu on tuotettu EC2-instanssilla.</p>
<p>Instanssin tunniste: INSTANCE_ID_TAHAN</p>
```

Toteutuksessa INSTANCE_ID_TAHAN korvataan palvelimelta haetulla oikealla instanssitunnisteella.

**Tärkeä huomio**
Kun kirjoitat tiedostoon /var/www/html/index.html, tarvitset yleensä pääkäyttäjän oikeudet. Pelkkä sudo echo ... > tiedosto ei aina toimi odotetulla tavalla, koska uudelleenohjaus tehdään komentotulkin oikeuksilla.
Voit ratkaista tämän esimerkiksi:

* siirtymällä väliaikaisesti pääkäyttäjäksi
* käyttämällä komentoa, joka kirjoittaa sisällön pääkäyttäjän oikeuksilla
* luomalla tiedoston ensin omaan kotihakemistoon ja kopioimalla sen sitten oikeaan paikkaan
Valitse tapa, jonka ymmärrät ja jonka pystyt selittämään palautuksessa.

### Palautettava näyttö

Palauta:

* kuvakaappaus tai tuloste, jossa näkyy haettu instanssitunniste
* kuvakaappaus verkkosivusta, jossa instanssitunniste näkyy
* lyhyt selitys siitä, miten tieto siirtyi metatietopalvelusta verkkosivulle

## 11. User Data -skriptillä automatisointi

Tässä vaiheessa luot uuden EC2-instanssin, jonka käyttöönotto tehdään automaattisesti User Data -skriptillä.
User Data on EC2-instanssin käynnistyksen yhteydessä suoritettava skripti. Sen avulla voidaan esimerkiksi:

* päivittää pakettilistat
* asentaa ohjelmia
* käynnistää palveluita
* luoda tiedostoja
* hakea metatietoja
* tuottaa verkkosivun sisältö

### User Data -skriptin tavoite
Luo uusi Ubuntu-pohjainen EC2-instanssi. Lisää sen käynnistyksen yhteyteen User Data -skripti, joka tekee vähintään seuraavat asiat:

1. päivittää pakettilistat
2. asentaa Apache-verkkopalvelimen
3. käynnistää Apachen
4. määrittää Apachen käynnistymään automaattisesti
5. hakee EC2-instanssin tunnisteen IMDSv2-menetelmällä
6. luo verkkosivun, jossa instanssin tunniste näkyy
7. asentaa tarvittaessa komentorivipohjaisen selaimen testausta varten

User Data -skriptin tulee alkaa esimerkiksi Bash-skriptin aloitusrivillä:

```console
     #!/bin/bash
```

Vinkki skriptin rakentamiseen
Älä yritä kirjoittaa koko skriptiä kerralla. Rakenna ratkaisu ensin käsin toimivaksi SSH-yhteyden kautta. Kun komennot toimivat käsin, muuta ne User Data -skriptiksi.
Hyvä etenemistapa:

1. testaa Apache-asennus käsin
2. testaa IMDSv2-tokenin haku käsin
3. testaa instanssitunnisteen haku käsin
4. testaa HTML-tiedoston luonti käsin
5. yhdistä toimivat komennot User Data -skriptiin
6. luo uusi instanssi ja testaa toistuuko lopputulos automaattisesti

### User Data -skriptin tarkistaminen

Jos lopputulos ei näy, selvitä ensin:

* käynnistyikö instanssi oikein
* käynnistyikö Apache
* luotiinko /var/www/html/index.html
* näkyykö User Data -skriptin suoritus lokitiedostoissa
* onnistuiko IMDSv2-tokenin haku
* onnistuiko instanssitunnisteen haku

### Testaaminen ilman julkista HTTP-yhteyttä
Jos et saa yhteyttä selaimella julkisesta IP-osoitteesta, voit testata palvelinta instanssin sisältä:

```console
  curl <http://localhost>
```

tai komentorivipohjaisella selaimella:

```console
www-browser <http://localhost>
```

Tämä riittää osoittamaan, että verkkopalvelin toimii instanssissa, vaikka julkinen verkkoyhteys olisi lab-ympäristössä rajoitettu.

### Palautettava näyttö

Palauta:

* käyttämäsi User Data -skripti
* kuvakaappaus uudesta instanssista
* kuvakaappaus tai tuloste verkkosivusta
* tieto siitä, näkyykö sivu julkisen IP-osoitteen kautta vai testasitko sen paikallisesti palvelimelta
* lyhyt selitys siitä, mitä skripti tekee vaiheittain

## 12. Valinnainen lisätehtävä: Tailscale-integraatio

Tämä osio on vapaaehtoinen.
Selvitä, miten EC2-instanssi voidaan liittää Tailscale-verkkoon automaattisesti User Data -skriptin avulla.
Tavoitteena on ymmärtää:

* mikä on Tailscale
* mikä on pre-auth key eli esihyväksytty todennusavain
* miksi avaimelle kannattaa asettaa lyhyt voimassaoloaika
* miksi avainta ei pidä jakaa julkisesti
* miten palvelin voidaan liittää verkkoon ilman interaktiivista kirjautumista

Tailscale oma ohje asiaan: <https://tailscale.com/kb/1293/cloud-init>

### Palautettava näyttö

Palauta:

* lyhyt kuvaus toteutuksesta
* kuvakaappaus tai tuloste, josta näkyy, että instanssi liittyi Tailscale-verkkoon
* pohdinta siitä, mitä turvallisuusriskejä liittyy pre-auth key -avaimen käyttöön User Data -skriptissä

## Palautuksen yhteenveto

Palauta yksi dokumentti, joka sisältää seuraavat osat:

1. EC2-instanssin perustiedot ja kuvakaappaus
2. SSH-yhteyden muodostamisen dokumentointi
3. palvelimen perusasetusten dokumentointi
4. swap-tilan tarkistus ja lisääminen
5. IMDSv2-metatietojen hakeminen
6. verkkosivu, jossa instanssitunniste näkyy
7. User Data -skripti ja sen toiminnan selitys
8. mahdollinen Tailscale-lisätehtävä

Palautuksesta tulee käydä ilmi:

* mitä teit
* millä komennoilla tai asetuksilla teit sen
* miten varmistit, että ratkaisu toimii
* mitä opit EC2-instanssien, SSH-yhteyksien ja metatietopalvelun käytöstä
