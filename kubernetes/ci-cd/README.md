# Kubernetes CI/CD -esimerkki

Tämä esimerkki näyttää, miten tämän repositorion WordPress Helm -chart validoidaan GitHub Actionsissa ja julkaistaan hallitusti Kubernetes-klusteriin. CI toimii pull requesteissa ja `main`-haaran muutoksissa; CD käynnistetään erikseen GitHub Actionsin **Run workflow** -toiminnolla, jotta tuotantoon tai jaettuun klusteriin ei julkaista automaattisesti jokaista muutosta.

## Rakenne

```text
kubernetes/
├── ci-cd/
│   ├── README.md
│   └── rbac.yaml
└── helm/wordpress/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/

.github/workflows/
├── kubernetes-ci.yml
└── kubernetes-deploy.yml
```

### CI: tarkista ennen julkaisua

Workflow [kubernetes-ci.yml](../../.github/workflows/kubernetes-ci.yml) käynnistyy pull requesteissa ja `main`-haaraan tehdyissä muutoksissa, kun Kubernetes-materiaali muuttuu. Se ajaa Helm-lintin ja renderöi chartin testitunnuksilla, tarkistaa halutun Ingress-isäntänimen sekä resurssipyyntöjen ja -rajojen sisältymisen tuotettuihin manifesteihin.

CI ei tarvitse Kubernetes-klusteria, pilvitunnuksia tai oikeita tietokantasalaisuuksia. Testitunnukset ovat vain renderöinnin validointia varten eikä niitä julkaista.

### CD: hallittu käyttöönotto

Workflow [kubernetes-deploy.yml](../../.github/workflows/kubernetes-deploy.yml) on tarkoituksella manuaalinen ja sallii ajon vain `main`-haarasta. Se lukee GitHub Environmentin tunnukset, päivittää erillisen tietokanta-Secretin, asentaa chartin `wordpress`-namespaceen, odottaa WordPressin ja MariaDB:n valmistumista ja testaa Ingress-reitin.

Julkaisu odottaa, että klusteri, `wordpress`-namespace, `nginx`-IngressClass ja NGINX Ingress Controller ovat jo olemassa. Helm-chartin oletusosoite on `wordpress.colasloth.com`. Kehityskoneen Docker Desktop -klusteri ei tavallisesti ole GitHubin hosted runnerista saavutettavissa: paikalliseen klusteriin testataan käsin [WordPress-chartin ohjeiden](../helm/wordpress/README.md) mukaan tai käytetään omaa GitHub Actions self-hosted runneria. Älä avaa paikallisen koneen Kubernetes API:a internetiin pelkästään CI:tä varten.

## GitHubin käyttöönotto

### 1. Valmistele klusteri ylläpitäjänä

Asenna NGINX Ingress Controller ensin [Ingress-demo-ohjeen](../README.md#ingress-demo) mukaan. Luo sen jälkeen WordPress-namespace ja asenna esimerkin käyttöoikeudet:

```powershell
kubectl create namespace wordpress
kubectl apply -f kubernetes/ci-cd/rbac.yaml
```

Varmista ennen RBAC-manifestin asentamista, että molemmat `wordpress`- ja `nginx-ingress`-namespacet ovat olemassa. Manifesti luo `github-actions`-ServiceAccountin, WordPress-julkaisun hallintaan vain `wordpress`-namespaceen rajatun Rolen ja Ingress-smoke-testiä varten erillisen, vain luku- ja porttivälitysoikeuksia sisältävän Rolen `nginx-ingress`-namespaceen. Käyttöoikeudet eivät salli namespacejen, klusteriroolien tai muiden sovellusresurssien hallintaa.

Käytä GitHubissa klusterin saavutettavuuteen ja käyttöoikeuksiin sopivaa tunnistautumista. Suositeltavaa on pilvipalvelun OIDC/workload identity tai muu lyhytikäinen tunniste. Jos harjoituksessa käytetään staattista kubeconfig-tunnusta, rajaa se tämän ServiceAccountin oikeuksiin, säilytä se vain GitHub Secretissä ja vaihda se säännöllisesti. GitHub Environmentin suojaussäännöt ja hyväksynnät kannattaa ottaa käyttöön ennen julkaisua.

`wordpress`- ja `nginx-ingress`-namespacet sekä Ingress Controller on valmisteltava ylläpitäjänä ennen CD-workflow'n ajoa, koska julkaisun tunnukselle ei anneta oikeutta namespacejen tai klusteritason resurssien luontiin.

### 2. Aseta GitHub Environment ja salaisuudet

Luo repositorioon GitHub Environment nimeltä `kubernetes-demo` ja lisää sinne seuraavat Environment secrets:

| Secret | Sisältö |
|---|---|
| `KUBE_CONFIG_B64` | Base64-koodattu kubeconfig, jonka tunnuksella on yllä kuvatun Rolen oikeudet. |
| `MARIADB_ROOT_PASSWORD` | MariaDB:n ylläpitäjän vahva salasana. |
| `MARIADB_PASSWORD` | WordPress-tietokantakäyttäjän vahva salasana. |

Tarkista kubeconfig ennen sen tallentamista: sen API-palvelimen osoitteen pitää olla saavutettavissa GitHub Actions -runnerilta ja tunnuksen käyttöoikeuksien tulee olla rajatut. Windows PowerShellissä tiedoston voi koodata Base64-muotoon näin:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("kubeconfig"))
```

Älä tulosta tunnuksia workflow-lokeihin, lisää niitä YAML-tiedostoihin tai tallenna kubeconfigia repositorioon. `KUBE_CONFIG_B64`-sisältö kirjoitetaan runnerilla väliaikaiseen, rajatuin oikeuksin suojattuun tiedostoon.

### 3. Käynnistä julkaisu

Kun CI on hyväksytty ja `main` sisältää julkaistavan muutoksen:

1. Avaa GitHubissa **Actions**.
2. Valitse **Deploy WordPress to Kubernetes**.
3. Valitse `main` ja käynnistä **Run workflow**.
4. Tarkista työjonon lokista rollout- ja HTTP-smoke-testin tulos.

Käyttöönotossa workflow luo `wordpress-database-ci`-Secretin klusteriin suoraan GitHubin salaisuuksista. Helm saa vain Secretin nimen `existingSecret`-asetuksena; varsinaiset salasanat eivät tällöin päädy Helm-julkaisun arvoihin. Erillinen nimi pitää ulkoisen Secretin erillään chartin paikallisesta Secretistä ja estää Helm-julkaisua käsittelemästä sitä omana resurssinaan. Workflow testaa `wordpress.colasloth.com`-hostin Ingress Controllerin kautta ja tarkistaa WordPressin asennusnäkymän HTTP 200 -vastauksen.

Jos julkaisu on epäonnistunut tai uusi versio täytyy palauttaa, tarkista ensin julkaisuhistoria ja palauta edellinen revisio:

```powershell
helm history wordpress --namespace wordpress
helm rollback wordpress <REVISION> --namespace wordpress --wait
kubectl rollout status deployment/wordpress --namespace wordpress
```

Helm rollback palauttaa chartin hallitsemat Kubernetes-resurssit aiempaan revisioon. Se ei palauta tietokantaan tehtyjä muutoksia eikä poista ulkoisesti hallittua `wordpress-database-ci`-Secretiä.

## Resurssipyyntöjen ja -rajojen merkitys

WordPress-chart asettaa kummallekin kontille `resources.requests`- ja `resources.limits`-arvot. Nykyiset opetusesimerkin lähtöarvot ovat:

| Kontti | Request CPU / muisti | Limit CPU / muisti |
|---|---:|---:|
| WordPress | `100m` / `128Mi` | `500m` / `512Mi` |
| MariaDB | `100m` / `256Mi` | `500m` / `1Gi` |

`requests` on varaus ja aikatauluttajan käyttämä vähimmäistarve Podia sijoitettaessa: Node tarvitsee riittävästi vapaata CPU- ja muistiresurssia. CPU-request ei varaa yksinomaista suoritinta, vaan kertoo aikatauluttajalle ja kuormanhallinnalle odotetun osuuden. `limits` puolestaan rajoittaa kontin kulutusta ajon aikana; CPU-rajan ylitys rajoittaa suoritusnopeutta, ja muistirajan ylittävä kontti voidaan päättää muistipulan vuoksi.

Resurssien *asemointi* Nodeille tehdään eri mekanismeilla kuin request/limit-arvoilla. NodeSelector, affinity ja tolerations vaikuttavat siihen, mille Nodeille Pod voidaan sijoittaa; niitä ei lisätä tähän yhden Noden Docker Desktop -esimerkkiin, koska ne eivät parantaisi sijoittelua ja voisivat estää Podin käynnistymisen. Pienessä laboratoriossa käytä arvoja oppimiseen ja säädä niitä klusterin todellisen kapasiteetin sekä sovelluksen mittausten mukaan; liian suuret request-arvot voivat jättää Podit Pending-tilaan.

## Käyttöönotto paikallisessa Docker Desktopissa

Hosted runner ei yleensä saa yhteyttä koneesi paikalliseen klusteriin. Paikallinen testi tehdään käsin, kun Docker Desktop Kubernetes on käynnissä ja NGINX Ingress Controller on asennettu:

```powershell
kubectl create namespace wordpress
helm upgrade --install wordpress ./kubernetes/helm/wordpress `
  --namespace wordpress `
  --set-string mariadb.auth.rootPassword='VAIHDA-ROOT-SALASANA' `
  --set-string mariadb.auth.password='VAIHDA-WORDPRESS-SALASANA'
kubectl rollout status deployment/wordpress-mariadb -n wordpress
kubectl rollout status deployment/wordpress -n wordpress
```

Tämä paikallinen komento käyttää chartin omaa Secret-templaattia. Se on harjoitteluun; yhteisessä tai tuotantokäytössä suosi ulkoisesti hallittua Secretiä ja GitHub-workflow'n `existingSecret`-tapaa.

Poista paikallinen testijulkaisu tarvittaessa:

```powershell
helm uninstall wordpress --namespace wordpress
kubectl delete namespace wordpress
```

Namespaceen sidotun PVC:n poistaminen voi poistaa myös tallennetun WordPress-sisällön ja tietokannan StorageClassin reclaim policy -asetuksen mukaisesti.
