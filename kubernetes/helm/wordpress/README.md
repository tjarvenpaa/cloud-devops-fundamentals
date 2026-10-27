# WordPress Helm -esimerkki

Tämä Helm-chart asentaa WordPressin, MariaDB:n, niiden PVC-tallennukset ja Ingress-säännön osoitteeseen `wordpress.colasloth.com`. Esimerkki on opetuskäyttöön: se käyttää yhtä MariaDB-replikaa eikä sisällä tuotantokäyttöön tarvittavia varmistuksia, resurssirajoja tai salaisuuksien ulkoista hallintaa.

## Vaatimukset

- Toimiva Kubernetes-klusteri ja `kubectl`-yhteys.
- Helm 3.
- Klusterin dynaamista PVC-tallennusta tukeva oletus-StorageClass.
- NGINX Ingress Controller, jonka IngressClass on `nginx`.

Jos controlleria ei ole asennettu, käytä hakemiston [Ingress-demo-ohjetta](../../README.md#ingress-demo). Tarkista luokka komennolla `kubectl get ingressclass`.

## Asennus

Aja `kubernetes`-hakemistosta ja vaihda molemmat salasanat ennen asennusta:

```powershell
helm upgrade --install wordpress ./helm/wordpress `
  --namespace colasloth `
  --create-namespace `
  --set-string mariadb.auth.rootPassword='VAIHDA-ROOT-SALASANA' `
  --set-string mariadb.auth.password='VAIHDA-WORDPRESS-SALASANA'
```

Salasanat tallentuvat Kubernetes Secret -resurssiin ja Helm-julkaisun arvoihin. Älä käytä esimerkkisalasanoja tai tallenna oikeita salasanoja versionhallintaan; tuotantokäytössä tunnukset tulee tuoda erillisestä salaisuuksien hallintaratkaisusta.

Odota sovellusten käynnistymistä ja tarkista resurssit:

```powershell
kubectl rollout status deployment/wordpress -n colasloth
kubectl rollout status deployment/wordpress-mariadb -n colasloth
kubectl get pods,services,pvc,ingress -n colasloth
```

## Ingressin testaaminen paikallisesti

Välitä Ingress Controllerin portti paikalliseen koneeseen (toisessa terminaalissa):

```powershell
kubectl port-forward -n nginx-ingress service/nginx-ingress-controller 8080:80
```

Testaa reititys toisessa terminaalissa:

```powershell
curl.exe -H "Host: wordpress.colasloth.com" http://127.0.0.1:8080
```

Voit myös lisätä hosts-tiedostoon rivin `127.0.0.1 wordpress.colasloth.com` ja avata selaimessa `http://wordpress.colasloth.com:8080`. Ingress vastaa ensin WordPressin asennusnäkymällä; viimeistele sivuston käyttöönotto selaimessa.

## Poisto

Poista Helm-julkaisu komennolla:

```powershell
helm uninstall wordpress --namespace colasloth
```

PVC-resurssien poisto voi poistaa myös taustalla olevan datan StorageClassin reclaim policy -asetuksen mukaan. Tarkista ja varmuuskopioi tarvittava data ennen julkaisun poistamista.
