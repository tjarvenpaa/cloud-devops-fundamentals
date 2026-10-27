# Luento 1: Kubernetes-perusteet

Tässä luvussa tutustutaan Kubernetes-klusterin perusrakenteeseen ja siihen, miten sovellus tuodaan klusteriin, pidetään käynnissä ja tehdään verkon kautta tavoitettavaksi.

## Klusterin osat

Klusteri koostuu ohjaustasosta ja yhdestä tai useammasta työsolmusta eli Nodesta. Ohjaustaso ylläpitää klusterin tilaa ja ajoittaa työkuormia, kun taas Nodeilla suoritetaan Podit. `kubectl` on komentorivityökalu, jolla käyttäjä tutkii klusteria ja pyytää siihen muutoksia Kubernetes API:n kautta.

## Pod, Deployment ja ReplicaSet

Pod on Kubernetesin ajettava yksikkö: se sisältää yhden tai useamman samaan sovelluskokonaisuuteen kuuluvan kontin. Podien nimet ja osoitteet eivät ole pysyviä, joten tavallisesti sovellusta ei hallita yksittäisinä, irrallisina Podeina.

Deployment kuvaa halutun sovellustilan, kuten käytettävän konttikuvan ja replikojen määrän. Deploymentin hallitsema ReplicaSet luo ja korvaa Podeja, jotta toteutunut tila vastaa määriteltyä tavoitetta. Replikojen määrää muuttamalla sovellusta voidaan skaalata; poistettu Pod korvataan automaattisesti, jos Deploymentin tavoitemäärä ei muuten täyty.

## Service ja verkkoyhteydet

Service tarjoaa vakaan klusterinsisäisen osoitteen vaihtuville Podeille. Se valitsee kohde-Podit niiden labeleiden perusteella ja ohjaa liikenteen valittuihin kohteisiin.

Yleisiä Service-tyyppejä ovat:

- `ClusterIP`: palvelu on käytettävissä klusterin sisältä; tämä on oletus.
- `NodePort`: palveluun voidaan yhdistää Node-osoitteella ja avattavalla portilla.
- `LoadBalancer`: klusterin ympäristö voi luoda palvelulle ulkoisen kuormantasaajan.

HTTP- ja HTTPS-liikenteen reititys useille palveluille voidaan toteuttaa Ingressillä; sitä käsitellään [toisessa luennossa](./luento-2.md).

## Sovelluksen tilan tutkiminen

`kubectl`-komennolla voi tarkastella klusterin resursseja, Podien tilaa ja sovelluksen tulosteita. Kun julkaisu ei toimi odotetusti, selvitä ensin resurssin tila ja tapahtumat ja tarkista sen jälkeen kontin lokit.

```shell
kubectl get nodes
kubectl get deployments,replicasets,pods
kubectl describe pod <podin-nimi>
kubectl logs <podin-nimi>
kubectl get events --sort-by=.lastTimestamp
```

Yksittäiselle sovellukselle voi luoda oman Namespacen, jolloin sen resurssit on helpompi löytää ja poistaa. Tarkista ennen muutoksia, että `kubectl` käyttää oikeaa klusteria ja kontekstia.

## Harjoittelun eteneminen

Käytännön harjoituksen voi tehdä seuraavassa järjestyksessä:

1. Tarkista klusteriyhteys ja Nodejen tila; eristä harjoitus omaan Namespaceen.
2. Julkaise Nginx Deployment ja tarkastele sen luomia ReplicaSet- ja Pod-resursseja.
3. Skaalaa Deploymentia ja seuraa, miten Podien määrä muuttuu.
4. Poista yksi Pod ja havainnoi, miten ohjauskerros palauttaa tavoitellun replikoiden määrän.
5. Luo Deploymentille Service ja testaa yhteys esimerkiksi porttivälityksellä.

Tässä repositoriossa vastaavat manifestit löytyvät [esimerkkien hakemistosta](./examples/): [Pod](./examples/pod.yaml), [Deployment](./examples/deployment.yaml) ja [Service](./examples/service.yaml).
