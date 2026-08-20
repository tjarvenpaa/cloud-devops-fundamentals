# 4. Kubernetes ja WordPress

## Oppimistavoitteet

- ymmärtää Kubernetes-julkaisun peruskäsitteet
- ymmärtää Deploymentin tarkoituksen
- ymmärtää WordPress-julkaisun osat

---

# Mikä on Kubernetes?

Kubernetes on konttipohjainen orkestrointialusta.

Sen tehtäviä ovat:

- sovellusten suorittaminen
- skaalautuminen
- kuormantasaus
- itsekorjautuvuus

---

# Pod

Pod on Kubernetesin pienin suoritettava yksikkö.

Tyypillisesti yksi kontti
suoritetaan yhdessä Podissa.

---

# Deployment

Deployment hallitsee Podien elinkaarta.

Deployment:

- luo Podit
- päivittää Podit
- palauttaa Podit epäonnistumisen jälkeen

---

# Service

Podin IP-osoite vaihtuu.

Service tarjoaa pysyvän päätepisteen.

---

# Persistent Volume

WordPress tallentaa käyttäjien sisältöä.

Podit ovat lähtökohtaisesti tilattomia.

Persistent Volume mahdollistaa
datan säilymisen Podin uudelleenkäynnistyksissä.

---

# WordPress käyttöönottokohteena

WordPress sisältää useita käytännön elementtejä:

- verkkopalvelun
- tietokannan
- pysyvän tallennuksen
- ympäristömuuttujat

Tämän vuoksi se soveltuu hyvin CI/CD-opetukseen.

---

# GKE

Google Kubernetes Engine (GKE)
on hallittu Kubernetes-palvelu.

GKE mahdollistaa:

- klusterien automaattisen hallinnan
- päivitykset
- monitoroinnin