# 5. Kokonainen CI/CD-putki

## Oppimistavoitteet

- hahmottaa koko automaatioketju
- ymmärtää deploymentin riskit
- ymmärtää rollback-periaate

---

# Kokonaisarkkitehtuuri

Developer

↓

Pull Request

↓

GitHub Actions

↓

Terraform Plan

↓

Approval

↓

Terraform Apply

↓

GKE

↓

WordPress

↓

Smoke Test

---

# Ympäristöt

Tyypilliset ympäristöt:

- Development
- Test
- Production

Ympäristöt vähentävät virheiden vaikutuksia.

---

# Secrets

CI/CD-putket tarvitsevat tunnuksia.

Tunnuksia ei koskaan tallenneta:

- Git-repositorioon
- Terraform-koodiin
- Kubernetes-manifesteihin

Ne säilytetään salaisuuksien hallintajärjestelmässä.

---

# Smoke Test

Smoke Test on kevyt tarkistus.

Esimerkiksi:

- HTTP 200 vastaus
- etusivu latautuu

Tarkoitus on havaita ilmeiset virheet nopeasti.

---

# Rollback

Käyttöönotto voi epäonnistua.

Rollback tarkoittaa:

palautusta viimeiseen toimivaan versioon.

Kubernetes mahdollistaa
Deployment-version palauttamisen.

---

# Mitä opiskelijan tulee osata?

Opiskelijan tulee osata:

1. Kirjoittaa workflow.
2. Rakentaa CI-vaihe.
3. Luoda Terraform-plan.
4. Suorittaa Terraform-apply.
5. Julkaista Kubernetesiin.
6. Tarkistaa käyttöönoton onnistuminen.
7. Korjata epäonnistunut julkaisu.

Tämä muodostaa modernin CI/CD-putken perustan.