# Luento 2: Namespace, tallennus, Ingress ja Helm

Tässä luvussa perehdytään sovellusten eristämiseen Namespacella, Podien elinkaaren ylittävään tallennukseen, HTTP-liikenteen reititykseen ja Kubernetes-resurssien paketointiin Helmillä.

## Namespacet

Namespace jakaa klusterin nimialueita ja auttaa ryhmittelemään resursseja esimerkiksi tiimin tai harjoituksen mukaan. Eri Namespacessa voi olla samannimisiä Deploymenteja ja Servicejä. Namespace-eristys helpottaa resurssien hallintaa, mutta ei yksinään korvaa käyttöoikeuksien tai verkkopolitiikkojen määrittelyä.

## Pysyvä tallennus: PVC, PV ja StorageClass

Kontin oma tiedostojärjestelmä ei ole luotettava paikka datalle, jonka pitää säilyä Podin vaihtuessa. Pod liittää tallennuksen käyttöönsä `volumeMount`-määrityksellä ja viittaa tallennuspyyntöön eli PersistentVolumeClaimiin (PVC).

PVC pyytää tallennustilaa, kuten kapasiteettia ja käyttötilaa. PersistentVolume (PV) vastaa klusterissa saatavilla olevaa tallennusresurssia, ja StorageClass määrittää, miten sopiva tallennus voidaan luoda dynaamisesti. Kun sovellus kirjoittaa tiedoston PVC:n kautta liitettyyn hakemistoon, tiedosto voi säilyä Podin poistamisen jälkeen. Säilyminen riippuu kuitenkin tallennuspalvelusta, StorageClass-asetuksista ja PV:n elinkaarikäytännöistä.

Harjoituksessa kannattaa luoda PVC, kirjoittaa sen kautta tiedosto ja käynnistää sen jälkeen uusi Pod, joka lukee saman tiedoston. Tarkista myös PVC:n tila sekä sen ja PV:n välinen sidonta ennen kuin teet johtopäätöksiä datan elinkaaresta.

## Ingress ja HTTP-reititys

Ingress-resurssi määrittää HTTP(S)-pyynnöille reitityssääntöjä, kuten hostname- ja polkukohtaisia kohteita. Ingress ei itsessään välitä liikennettä: klusterissa täytyy olla Ingress Controller, joka tunnistaa säännöt ja toteuttaa reitityksen. `ingressClassName` yhdistää resurssin sopivaan controlleriin.

Ingressin backend-palvelun on oltava samassa Namespacessa kuin Ingress-resurssin. Palvelun puolestaan täytyy valita käynnissä olevat, valmiit Podit. Siksi ongelmaa selvitettäessä kannattaa tarkistaa controllerin toiminta, Ingress-luokka ja -säännöt sekä backendin Service, EndpointSlice ja Podien valmiustila.

Tämän repositorion [Ingress-demossa](./examples/ingress-demo.yaml) kaksi Namespacea tarjoavat omat vastauspalvelunsa, joihin reititetään eri hostnamet. [README:n käyttöohje](./README.md#ingress-demo) kertoo controllerin käynnistämisestä ja demon testaamisesta.

## Helm

Helm kokoaa sovelluksen Kubernetes-resurssit Chart-paketiksi. Chartin asetuksia voidaan muuttaa arvoilla, jolloin samaa pakettia voi käyttää eri ympäristöissä tai eri replikoiden ja konttikuvien kanssa. Asennettu Chart on release, jonka tilaa, versiohistoriaa, päivityksiä ja palautuksia Helm hallitsee.

Tyypillinen elinkaari sisältää Chartin asentamisen, arvojen muuttamisen päivityksessä, tarvittaessa aiempaan revisioon palaamisen ja lopuksi releasen poistamisen. Releasen poistaminen ei välttämättä poista kaikkia Chartin luomia tai erikseen säilytettäviä resursseja, joten tila on hyvä tarkistaa ennen siivousta.

## Harjoituksen yhteenveto

Luvun harjoituksissa sovelluksen eristys, datan pysyvyys, liikenteen reititys ja julkaisun elinkaari tarkastellaan erillisinä ongelmina. Näiden osien yhteisvaikutuksen ymmärtäminen helpottaa sekä Kubernetes-sovelluksen suunnittelua että vianmääritystä.
