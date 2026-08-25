#!/bin/bash
set -euxo pipefail

# Päivitetään pakettien lähdeluettelo ja asennetaan Docker.
apt-get update -y
apt-get install -y docker.io

# Otetaan Docker käyttöön ja käynnistetään palvelu heti.
systemctl enable --now docker

# Varmistetaan, että Docker-palvelu on toimintavalmis.
for attempt in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

docker info >/dev/null 2>&1

# Noudetaan sovelluksen Docker-kuva.
docker pull nginx:latest

# Poistetaan mahdollinen aiempi samanniminen kontti.
docker rm -f webapp 2>/dev/null || true

# Käynnistetään sovellus palvelimen portissa 80.
docker run -d \
  --name webapp \
  --restart unless-stopped \
  -p 80:80 \
  nginx:latest

# Tallennetaan käyttöönoton onnistuminen lokiin.
echo "Cloud-init deployment completed at $(date --iso-8601=seconds)" \
  | tee /var/log/webapp-deployment.log