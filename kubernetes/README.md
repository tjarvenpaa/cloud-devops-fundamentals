# Kubernetes

Tämän hakemiston [examples](./examples/)-kansio sisältää luentodiojen mukaiset Nginx Pod-, kolmen replikän Deployment- ja ClusterIP-Service-esimerkit sekä kahden namespacen host-pohjaisen Ingress-demon. [WordPressin Helm-esimerkki](./helm/wordpress/) sisältää myös MariaDB:n, pysyvät PVC-tallennukset ja Ingress-reitin `wordpress.colasloth.com`; erillinen CI/CD-käyttöönottoesimerkki puuttuu vielä.

## Luentomateriaalit

- [Luento 1: Kubernetes-perusteet](./luento-1.md) — klusteri, Podit, Deploymentit, Servicet ja sovelluksen tilan tutkiminen.
- [Luento 2: Namespace, tallennus, Ingress ja Helm](./luento-2.md) — resurssien eristys, pysyvä data, HTTP-reititys ja julkaisujen hallinta.
- [WordPress Helm -esimerkki](./helm/wordpress/README.md) — WordPress, MariaDB, PVC ja `wordpress.colasloth.com`-Ingress.

## Pod

Luo luentoesimerkin mukainen yksittäinen Nginx Pod ja tarkista sen tila:

```powershell
kubectl apply -f examples/pod.yaml
kubectl get pod web -w
```

Poista Pod testin jälkeen:

```powershell
kubectl delete -f examples/pod.yaml
```

## Deployment ja Service

Deployment luo kolme Nginx-replikaa. Service valitsee Deploymentin Podit `app: web` -labelin perusteella ja avaa niille klusterin sisäisen HTTP-osoitteen portissa 80.

```powershell
kubectl apply -f examples/deployment.yaml
kubectl apply -f examples/service.yaml
kubectl get deployment,pod,service
```

Voit skaalata Deploymentia ja tarkistaa tilan näin:

```powershell
kubectl scale deployment web --replicas=3
kubectl rollout status deployment/web
```

Poista esimerkin resurssit:

```powershell
kubectl delete -f examples/service.yaml
kubectl delete -f examples/deployment.yaml
```

## Ingress-demo

Demo luo `colasloth`- ja `fbi`-namespacet, joihin kumpaankin tulee `echo`-Deployment ja ClusterIP-Service. Ingress-resurssit reitittävät hostnamet `colasloth.com` ja `fbi.com` vastaavaan Serviceen; ensin tarvitaan toimiva NGINX Ingress Controller.

Asenna PDF-esimerkissä käytetty F5 NGINX Ingress Controller Helmillä ja odota sen valmistumista:

```powershell
helm install nginx-ingress oci://ghcr.io/nginx/charts/nginx-ingress `
  --version 2.8.0 `
  --namespace nginx-ingress `
  --create-namespace
kubectl rollout status deployment/nginx-ingress-controller -n nginx-ingress
```

Ota demo käyttöön, välitä controllerin portti paikalliseen koneeseen ja testaa molemmat Host-otsakkeet:

```powershell
kubectl apply -f examples/ingress-demo.yaml
kubectl port-forward -n nginx-ingress service/nginx-ingress-controller 8080:80
```

Aja porttivälityksen ollessa käynnissä toisessa terminaalissa:

```powershell
curl.exe -H "Host: colasloth.com" http://127.0.0.1:8080
curl.exe -H "Host: fbi.com" http://127.0.0.1:8080
```

Vastausten tulee olla `Hello from colasloth namespace` ja `Hello from fbi namespace`. Jos käytössä olevan controllerin IngressClass ei ole `nginx`, vaihda manifestin `ingressClassName` sitä vastaavaksi.

Poista demo ja controller testin jälkeen:

```powershell
kubectl delete -f examples/ingress-demo.yaml
helm uninstall nginx-ingress -n nginx-ingress
kubectl delete namespace nginx-ingress
```
