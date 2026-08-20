# 2. GitHub Actions

## Oppimistavoitteet

Tämän luvun jälkeen opiskelija osaa:

- kuvata GitHub Actionsin arkkitehtuurin
- kirjoittaa yksinkertaisen workflow'n
- tunnistaa työjonon vaiheet
- lukea workflow-lokeja

---

# Mikä on GitHub Actions?

GitHub Actions on GitHubiin integroitu automaatioalusta.

Sillä voidaan automatisoida:

- testaus
- julkaisu
- dokumentointi
- infrastruktuurin provisiointi

GitHub Actions koostuu workflow-tiedostoista.

Workflow määritellään YAML-muodossa.

---

# Workflow

Workflow on automaattinen prosessi.

Workflow käynnistyy tapahtumasta.

Esimerkkejä tapahtumista:

- push
- pull_request
- release
- workflow_dispatch

---

# Job

Workflow sisältää yhden tai useamman jobin.

Job on joukko toimenpiteitä,
jotka suoritetaan samalla runnerilla.

Jobit voivat:

- suorittua rinnakkain
- suorittua peräkkäin

---

# Step

Job koostuu steppeistä.

Step voi olla:

- shell-komento
- GitHub Action

Esimerkki:

```yaml
- run: echo "Hello World"