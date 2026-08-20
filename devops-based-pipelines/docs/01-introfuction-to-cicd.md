# Moduuli 01: Johdanto CI/CD-ajatteluun

> Arvioitu opiskeluaika: 2-3 tuntia  
> Ennakkovaatimukset: Git-perusteet, pilviympäristöjen manuaalinen hallinta  
> Seuraava moduuli: GitHub Actions perusteet

---

# Oppimistavoitteet

Tämän moduulin suoritettuaan opiskelija osaa:

- selittää Continuous Integration (CI) -käsitteen
- selittää Continuous Delivery (CD) -käsitteen
- tunnistaa manuaalisten käyttöönottojen ongelmia
- perustella automaation hyödyt pilviympäristöissä
- kuvata GitHub Actionsin roolin CI/CD-putkessa
- tunnistaa Infrastructure as Code -ajattelun merkityksen

---

# Johdanto

Pilvipalveluiden alkuvaiheessa palveluita hallittiin usein suoraan
hallintaportaalista tai komentoriviltä.

Esimerkiksi verkkosivuston julkaisu saattoi sisältää:

1. Virtuaalikoneen luomisen
2. Palomuurisääntöjen määrittämisen
3. Sovelluksen asentamisen
4. Tietokannan käyttöönoton
5. Konfiguraation muuttamisen

Kun ympäristö kasvaa tai muutoksia tehdään usein,
manuaalisesta prosessista muodostuu haastava ylläpitää.

CI/CD-ajattelu syntyi ratkaisemaan tätä ongelmaa.

---

# Esimerkkitilanne

Oletetaan, että organisaatio ylläpitää WordPress-palvelua.

Jokainen julkaisu edellyttää:

- palvelimelle kirjautumista
- tiedostojen kopiointia
- palvelun uudelleenkäynnistystä
- toiminnan testaamista

Kysymyksiä:

- Mitä tapahtuu, jos jokin vaihe unohtuu?
- Miten toinen ylläpitäjä tietää kaikki tarvittavat vaiheet?
- Miten virheellinen julkaisu palautetaan?

Nämä ovat juuri niitä ongelmia, joita CI/CD pyrkii ratkaisemaan.

---

# Mitä CI tarkoittaa?

CI tulee sanoista **Continuous Integration**.

Continuous Integration tarkoittaa käytäntöä, jossa
kehittäjien tekemät muutokset yhdistetään yhteiseen
versionhallintaan usein ja pienissä osissa.

Jokaisen muutoksen yhteydessä suoritetaan automaattisesti:

- käännös
- testit
- laadunvarmistus
- validoinnit

Tavoitteena on havaita virheet mahdollisimman aikaisessa vaiheessa.

---

## Miksi aikainen palautteen saaminen on tärkeää?

Virheen korjaaminen on yleensä sitä halvempaa,
mitä aikaisemmin virhe havaitaan.

Jos virhe havaitaan:

- kehitysvaiheessa → korjaus kestää minuutteja
- testausvaiheessa → korjaus voi kestää tunteja
- tuotannossa → korjaus voi kestää päiviä

CI pyrkii siirtämään virheiden havaitsemisen mahdollisimman lähelle
kehittäjää.

---

# Mitä CD tarkoittaa?

CD voi tarkoittaa kahta eri käsitettä:

## Continuous Delivery

Järjestelmä pidetään jatkuvasti julkaisukelpoisena.

Putki suorittaa automaattisesti:

- testauksen
- validoinnin
- rakentamisen

Mutta lopullinen julkaisu edellyttää ihmisen hyväksyntää.

---

## Continuous Deployment

Continuous Deployment menee pidemmälle.

Kun kaikki tarkastukset läpäistään:

- julkaisu tapahtuu automaattisesti
- erillistä hyväksyntää ei tarvita

Continuous Deployment soveltuu erityisesti
organisaatioihin, joissa automaatiotestauksen laatu on korkea.

---

# CI, Delivery ja Deployment

```text
Continuous Integration

Code
 ↓
 Test
 ↓
 Ready

----------------------------

Continuous Delivery

Code
 ↓
 Test
 ↓
 Approval
 ↓
 Deploy

----------------------------

Continuous Deployment

Code
 ↓
 Test
 ↓
 Deploy
```

---

# Mikä on CI/CD-putki?

CI/CD-putki (Pipeline) on automatisoitu prosessi,
joka suorittaa joukon tehtäviä ennalta määritellyssä järjestyksessä.

Esimerkiksi:

```text
Git Push
   │
   ▼
Terraform Validate
   │
   ▼
Terraform Plan
   │
   ▼
Approval
   │
   ▼
Terraform Apply
   │
   ▼
Deploy
```

Jokainen vaihe toimii laatuporttina seuraavalle vaiheelle.

---

# Miksi CI/CD on tärkeää pilviympäristöissä?

Pilviympäristöissä infrastruktuuria voidaan muuttaa nopeasti.

Tämä on sekä etu että riski.

Esimerkki:

Terraform-konfiguraation virhe voi:

- poistaa verkkoyhteydet
- poistaa tietokannan
- luoda ylimääräisiä kustannuksia

Siksi muutokset halutaan tarkastaa ennen käyttöönottoa.

CI/CD mahdollistaa tämän automaattisesti.

---

# DevOps-ajattelu

DevOps ei ole yksittäinen työkalu.

DevOps on toimintamalli, jonka tavoitteena on
yhdistää ohjelmistokehitys ja operatiivinen ylläpito.

DevOps korostaa:

- yhteistyötä
- automaatiota
- mittaamista
- jatkuvaa oppimista

CI/CD on yksi tärkeimmistä DevOpsin teknisistä käytännöistä.

---

# Infrastructure as Code

Pilviympäristöjä voidaan hallita kahdella tavalla.

## Manuaalinen hallinta

```text
Klikkaa → Tallenna → Muista dokumentoida
```

Tämän lähestymistavan ongelmat:

- virheet
- dokumentaation vanheneminen
- heikko toistettavuus

---

## Infrastructure as Code

```text
Kirjoita koodi
↓
Versionhallinta
↓
Automaatio
↓
Toistettava lopputulos
```

Infrastructure as Code (IaC) tarkoittaa,
että infrastruktuuri määritellään tiedostoissa samalla tavalla kuin ohjelmistokoodi.

Kurssilla käytämme tähän Terraformia.

---

# Kurssin päätapaus

Tämän kurssimoduulin aikana rakennetaan seuraava automaatio:

```text
Developer
    │
    ▼
Pull Request
    │
    ▼
GitHub Actions
    │
    ├── Validate
    ├── Plan
    └── Tests
    │
    ▼
Terraform Apply
    │
    ▼
Google Kubernetes Engine
    │
    ▼
WordPress
    │
    ▼
Smoke Test
```

Tämän ensimmäisen moduulin jälkeen ymmärrät,
miksi tällainen automaatio on hyödyllinen.

Seuraavassa moduulissa rakennetaan ensimmäinen
GitHub Actions -workflow.

---

# Pohdintatehtävä

Vastaa seuraaviin kysymyksiin:

1. Mitä hyötyä automaattisesta käyttöönotosta on verrattuna manuaaliseen julkaisuun?
2. Mitä riskejä täysin automaattiseen julkaisuun liittyy?
3. Missä tilanteessa käyttäisit Continuous Deliveryä Continuous Deploymentin sijasta?
4. Mitä ongelmia Infrastructure as Code ratkaisee?

Kirjaa vastaukset omaan oppimispäiväkirjaasi.

---

# Tarkistuskysymykset

✅ Osaan selittää Continuous Integration -käsitteen.

✅ Osaan erottaa Continuous Deliveryn ja Continuous Deploymentin.

✅ Ymmärrän miksi automaatio on tärkeää pilviympäristöissä.

✅ Ymmärrän mitä tarkoitetaan CI/CD-putkella.

✅ Tunnistan Infrastructure as Code -ajattelun perusteet.

---

# Yhteenveto

Tässä moduulissa opittiin:

- mitä CI tarkoittaa
- mitä CD tarkoittaa
- miten CI/CD-putki toimii
- miksi automaatio on tärkeää
- mikä on Infrastructure as Code

Seuraavassa moduulissa siirrytään teoriasta käytäntöön
ja rakennetaan ensimmäinen GitHub Actions -workflow.

---

# Lähteet

## Virallinen dokumentaatio

GitHub Documentation.

Understanding GitHub Actions.

https://docs.github.com/en/actions/get-started/understand-github-actions

---

GitHub Documentation.

About Continuous Integration.

https://docs.github.com/en/actions/automating-builds-and-tests/about-continuous-integration

---

HashiCorp Documentation.

Terraform Documentation.

https://developer.hashicorp.com/terraform/docs

---

Google Cloud Documentation.

Infrastructure as Code with Terraform.

https://cloud.google.com/docs/terraform

---

## Kirjallisuus

Humble, Jez & Farley, David.

Continuous Delivery:
Reliable Software Releases through Build, Test and Deployment Automation.

Addison-Wesley.

---

Kim, Gene,
Humble, Jez,
Debois, Patrick,
Willis, John.

The DevOps Handbook.

IT Revolution Press.

---

Forsgren, Nicole,
Humble, Jez,
Kim, Gene.

Accelerate:
Building and Scaling High Performing Technology Organizations.

IT Revolution Press.