# AWS WordPress Lab

Harjoituksessa asennetaan WordPress AWS EC2 -instanssille, luodaan tietokanta AWS RDS -palvelulla, tallennetaan kuvia AWS S3 -palveluun sekä otetaan HTTPS käyttöön Let's Encrypt -sertifikaatin avulla.

## Oppimistavoitteet

Harjoituksen jälkeen opiskelija osaa:

- Luoda ja hallita AWS EC2 -instansseja
- Asentaa Apache HTTP Serverin
- Asentaa ja konfiguroida WordPressin
- Luoda ja käyttää AWS RDS MySQL -tietokantaa
- Yhdistää WordPressin ulkoiseen tietokantaan
- Tallentaa ja käyttää sisältöä AWS S3 -palvelussa
- Konfiguroida HTTPS-yhteyden Let's Encryptillä
- Ymmärtää verkkosovelluksen perusarkkitehtuurin AWS-ympäristössä

## Arkkitehtuuri

```text
Internet
    |
    v
+------------+
| Route 53   |
+------------+
    |
    v
+------------+
| EC2        |
| Apache     |
| WordPress  |
+------------+
    |
    +---------> RDS MySQL
    |
    +---------> S3 Bucket
```

## Sisältö

- WordPress-asennus EC2-instanssille
- AWS RDS -tietokannan käyttöönotto
- AWS S3 -integraatio
- HTTPS ja SSL-sertifikaatit
- Raportointiohjeet

## Vaatimukset

- AWS-tili
- EC2-instanssi
- RDS-tietokanta
- S3 Bucket
- Verkkotunnus (HTTPS-osuutta varten)
- SSH-yhteys Linux-palvelimeen

## Harjoituksen vaiheet

1. EC2-instanssin luonti
2. Apache- ja PHP-asennus
3. RDS-tietokannan luonti
4. WordPressin asennus
5. WordPressin yhdistäminen RDS-tietokantaan
6. HTTPS:n käyttöönotto
7. S3-kuvien käyttö WordPressissa
8. Raportointi

## Hakemistorakenne

```text
.
├── README.md
├── docs
│   └── wordpress-installation.md
└── LICENSE
```

## Raportointi

Palauta vähintään seuraavat kuvakaappaukset:

- EC2-instanssi
- RDS-instanssi
- S3 Bucket
- WordPressin etusivu
- WordPress-hallintapaneeli
- HTTPS-yhteys
- Julkaisu, jossa näkyy S3:sta ladattu kuva

## Lisätietoja

Virallinen WordPress-dokumentaatio:

https://wordpress.org/documentation/

AWS-dokumentaatio:

https://docs.aws.amazon.com/

---
## License

This work is licensed under a Creative Commons Attribution 4.0 International License (CC BY 4.0).

© Hämeen ammattikorkeakoulu / HAMK / Teemu Järvenpää