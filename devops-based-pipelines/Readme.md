# GitHub Actions CI/CD for Terraform and Kubernetes

## Osan kuvaus

Tässä osassa kurssia rakennetaan käytännöllinen CI/CD-putki GitHub Actionsilla.

Edetään yksinkertaisesta workflow'sta kohti infrastruktuurin automaattista provisiointia Terraformilla sekä WordPress-sovelluksen käyttöönottoa Kubernetes-ympäristöön.

Osa on suunnattu opiskelijoille, jotka hallitsevat:

- Git-versionhallinnan perusteet
- ohjelmistokehityksen perusteet
- pilviympäristöjen manuaalisen käytön

Tavoitteena on että, opiskelija pystyy suunnittelemaan ja toteuttamaan uuden CI/CD-putken itsenäisesti.

---

## Oppimistavoitteet

Osan jälkeen osaat:

✅ Luoda GitHub Actions workflow'n

✅ Toteuttaa Pull Request -pohjaisen CI-putken

✅ Validoida Terraform-infrastruktuurin automaattisesti

✅ Tuottaa Terraform Plan -raportin

✅ Julkaista infrastruktuurin Terraform Apply -vaiheella

✅ Deployata sovelluksen Kubernetes-klusteriin

✅ Toteuttaa smoke testin käyttöönoton jälkeen

✅ Tulkita lokitietoja ja korjata virheitä

✅ Ymmärtää rollback-periaatteen

---

## Arkkitehtuuri

```text
Developer
    │
    ▼
Pull Request
    │
    ▼
GitHub Actions CI
    ├── Terraform Validate
    ├── Terraform Plan
    └── Quality Checks
    │
    ▼
Merge to Main
    │
    ▼
Terraform Apply
    │
    ▼
Google Kubernetes Engine
    │
    ▼
WordPress Deployment
    │
    ▼
Smoke Test
```

---

## Repository-rakenne

```text
.
├── docs/
├── labs/
├── terraform/
├── kubernetes/
├── scripts/
└── .github/
    └── workflows/
```

### docs/

Kurssimateriaali.

### labs/

Harjoitukset ja laboratoriot.

### terraform/

Google Cloud -infrastruktuuri.

### kubernetes/

WordPressiin liittyvät Kubernetes-manifestit.

### .github/workflows/

GitHub Actions -workflow't.

---

## Osan sisältö

| Osio | Aihe |
|----------|----------|
| 1 | GitHub Actions perusteet |
| 2 | CI-putken rakentaminen |
| 3 | Terraform automaatiossa |
| 4 | Kubernetes deployment |
| 5 | Kokonainen CI/CD-putki |

---

## Harjoitukset

### Lab 1 – First Workflow

Luo ensimmäinen GitHub Actions workflow.

Tavoite:

- ymmärtää triggerit
- ymmärtää jobit
- lukea workflow-lokeja

---

### Lab 2 – Continuous Integration

Luo Pull Request -pohjainen CI-putki.

Tavoite:

- terraform fmt
- terraform validate
- automaattinen tarkastus

---

### Lab 3 – Terraform Plan

Toteuta Terraform Plan GitHub Actionsissa.

Tavoite:

- init
- validate
- plan

---

### Lab 4 – Kubernetes Deployment

Julkaise WordPress Kubernetesiin.

Tavoite:

- kubectl apply
- rollout status
- smoke test

---

## Päättötehtävä

Saat lähtöprojektin, jossa on:

- Terraform-koodi
- Kubernetes-manifestit
- tyhjä workflow-rakenne

Tehtävänäsi on rakentaa toimiva CI/CD-putki.

Putken tulee sisältää:

- Terraform Validate
- Terraform Plan
- Terraform Apply
- WordPress Deployment
- Smoke Test

---

## Arviointi

| Osa-alue | Paino |
|-----------|---------:|
| GitHub Actions Workflow | 20 % |
| CI-tarkastukset | 20 % |
| Terraform Automaatio | 25 % |
| Kubernetes Deployment | 25 % |
| Dokumentointi | 10 % |

Hyväksytyn suorituksen edellytys:

- workflow suorittuu onnistuneesti
- Terraform validoidaan automaattisesti
- WordPress deployataan onnistuneesti
- smoke test läpäisee
- dokumentaatio on riittävä

---

## Lisämateriaali

- GitHub Actions Documentation
- Terraform Documentation
- Google Kubernetes Engine Documentation
- Kubernetes Documentation

---

`