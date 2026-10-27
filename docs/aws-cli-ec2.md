# AWS CLI:n käyttöönotto WSL Ubuntu 24.04:ssa ja EC2-instanssin luominen

Tässä ohjeessa asennetaan AWS CLI v2 WSL Ubuntu 24.04 -ympäristöön, otetaan käyttöön AWS Academy Learner Labin tilapäiset tunnukset ja luodaan AWS CLI:llä julkiseen aliverkkoon Amazon Linux 2023 -EC2-instanssi.

> **AWS Academy -huomio:** Learner Labin oikeudet ja sallitut resurssit voivat vaihdella. Käytä laboratorion sallimaa aluetta ja instanssityyppiä. Tilapäiset tunnukset vanhenevat, joten ne täytyy tarvittaessa päivittää AWS Details -näkymästä.

## Tavoitearkkitehtuuri

```text
VPC 10.0.0.0/16
└── Public subnet 10.0.1.0/24
    ├── Internet Gateway
    ├── Route Table: 0.0.0.0/0 → Internet Gateway
    ├── Security Group: SSH omasta IP-osoitteesta
    └── EC2: Amazon Linux 2023
```

## 1. AWS CLI v2:n asentaminen

Päivitä pakettiluettelo ja asenna tarvittavat työkalut:

```bash
sudo apt update
sudo apt install -y curl unzip
```

Tarkista WSL-ympäristön arkkitehtuuri:

```bash
uname -m
```

### x86_64

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
```

### ARM64 / aarch64

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
```

Tarkista asennus:

```bash
aws --version
```

Poista asennustiedostot:

```bash
rm -rf aws awscliv2.zip
```

## 2. AWS Academy Learner Lab -tunnusten käyttöönotto

Käynnistä Learner Lab ja avaa:

```text
AWS Details → AWS CLI
```

Kopioi sieltä kaikki kolme tilapäistä tunnistetta:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

### Vaihtoehto A: credentials-tiedosto

Luo hakemisto:

```bash
mkdir -p ~/.aws
chmod 700 ~/.aws
```

Muokkaa tiedostoa:

```bash
nano ~/.aws/credentials
```

Lisää Learner Labista saadut arvot:

```ini
[default]
aws_access_key_id = ASIA...
aws_secret_access_key = ...
aws_session_token = ...
```

Suojaa tiedosto:

```bash
chmod 600 ~/.aws/credentials
```

Luo asetustiedosto:

```bash
nano ~/.aws/config
```

Esimerkki:

```ini
[default]
region = us-east-1
output = json
```

### Vaihtoehto B: ympäristömuuttujat

```bash
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
export AWS_DEFAULT_REGION="us-east-1"
```

> Älä lisää oikeita tunnuksia GitHub-repositorioon, skriptiin tai tehtäväpalautukseen.

### Testaa autentikaatio

```bash
aws sts get-caller-identity
```

Jos saat `ExpiredToken`-virheen, käynnistä Learner Lab uudelleen ja päivitä kaikki kolme tunnistetta.

## 3. Ympäristömuuttujat resurssien luontia varten

Valitse laboratorion sallima alue:

```bash
export AWS_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export VPC_CIDR="10.0.0.0/16"
export SUBNET_CIDR="10.0.1.0/24"
export KEY_NAME="lab-key"
```

Valitse automaattisesti ensimmäinen käytettävissä oleva Availability Zone:

```bash
export AZ=$(aws ec2 describe-availability-zones \
  --region "$AWS_REGION" \
  --filters Name=state,Values=available \
  --query 'AvailabilityZones[0].ZoneName' \
  --output text)

echo "$AZ"
```

## 4. VPC:n luominen

```bash
export VPC_ID=$(aws ec2 create-vpc \
  --region "$AWS_REGION" \
  --cidr-block "$VPC_CIDR" \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=lab-vpc}]' \
  --query 'Vpc.VpcId' \
  --output text)

echo "$VPC_ID"
```

Odota VPC:n valmistumista ja ota DNS-ominaisuudet käyttöön:

```bash
aws ec2 wait vpc-available --region "$AWS_REGION" --vpc-ids "$VPC_ID"

aws ec2 modify-vpc-attribute \
  --region "$AWS_REGION" \
  --vpc-id "$VPC_ID" \
  --enable-dns-support '{"Value":true}'

aws ec2 modify-vpc-attribute \
  --region "$AWS_REGION" \
  --vpc-id "$VPC_ID" \
  --enable-dns-hostnames '{"Value":true}'
```

## 5. Julkisen subnetin luominen

```bash
export SUBNET_ID=$(aws ec2 create-subnet \
  --region "$AWS_REGION" \
  --vpc-id "$VPC_ID" \
  --cidr-block "$SUBNET_CIDR" \
  --availability-zone "$AZ" \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=public-subnet}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "$SUBNET_ID"
```

Ota julkisten IPv4-osoitteiden automaattinen jako käyttöön:

```bash
aws ec2 modify-subnet-attribute \
  --region "$AWS_REGION" \
  --subnet-id "$SUBNET_ID" \
  --map-public-ip-on-launch
```

## 6. Internet Gatewayn luominen

```bash
export IGW_ID=$(aws ec2 create-internet-gateway \
  --region "$AWS_REGION" \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=lab-igw}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --region "$AWS_REGION" \
  --internet-gateway-id "$IGW_ID" \
  --vpc-id "$VPC_ID"

echo "$IGW_ID"
```

## 7. Reititystaulun luominen

```bash
export ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --region "$AWS_REGION" \
  --vpc-id "$VPC_ID" \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route \
  --region "$AWS_REGION" \
  --route-table-id "$ROUTE_TABLE_ID" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$IGW_ID"

export ROUTE_ASSOC_ID=$(aws ec2 associate-route-table \
  --region "$AWS_REGION" \
  --route-table-id "$ROUTE_TABLE_ID" \
  --subnet-id "$SUBNET_ID" \
  --query 'AssociationId' \
  --output text)
```

## 8. Security Groupin luominen

Selvitä ensin oman verkkoyhteytesi julkinen IPv4-osoite:

```bash
export MY_IP=$(curl -4 -s https://checkip.amazonaws.com)/32
echo "$MY_IP"
```

Luo Security Group:

```bash
export SG_ID=$(aws ec2 create-security-group \
  --region "$AWS_REGION" \
  --group-name lab-sg \
  --description "SSH access to lab EC2" \
  --vpc-id "$VPC_ID" \
  --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=lab-sg}]' \
  --query 'GroupId' \
  --output text)

echo "$SG_ID"
```

Salli SSH vain omasta julkisesta IP-osoitteestasi:

```bash
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=$MY_IP,Description='SSH from my IP'}]"
```

Jos myöhemmin asennat verkkopalvelimen, avaa HTTP erikseen:

```bash
aws ec2 authorize-security-group-ingress \
  --region "$AWS_REGION" \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

## 9. SSH-avainparin luominen

```bash
umask 077
aws ec2 create-key-pair \
  --region "$AWS_REGION" \
  --key-name "$KEY_NAME" \
  --key-type ed25519 \
  --query 'KeyMaterial' \
  --output text > "${KEY_NAME}.pem"

chmod 400 "${KEY_NAME}.pem"
```

> Jos samalla nimellä oleva avainpari on jo olemassa, käytä uutta nimeä tai poista vanha avainpari hallitusti. AWS ei anna yksityistä avainta uudelleen ladattavaksi.

## 10. Amazon Linux 2023 AMI:n selvittäminen

Hae ajantasainen x86_64 AMI AWS Systems Manager Parameter Storesta:

```bash
export AMI_ID=$(aws ssm get-parameter \
  --region "$AWS_REGION" \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query 'Parameter.Value' \
  --output text)

echo "$AMI_ID"
```

ARM64-instanssityypille käytä vastaavaa ARM64-parametria ja yhteensopivaa instanssityyppiä.

## 11. EC2-instanssin käynnistäminen

AWS Academy voi rajoittaa sallittuja instanssityyppejä. Tässä käytetään esimerkkinä `t2.micro`-tyyppiä:

```bash
export INSTANCE_ID=$(aws ec2 run-instances \
  --region "$AWS_REGION" \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --subnet-id "$SUBNET_ID" \
  --metadata-options 'HttpEndpoint=enabled,HttpTokens=required,HttpPutResponseHopLimit=1' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=lab-server}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "$INSTANCE_ID"
```

Odota, että instanssi on käynnissä:

```bash
aws ec2 wait instance-running \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID"
```

Hae julkinen IP-osoite:

```bash
export PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "$PUBLIC_IP"
```

## 12. SSH-yhteys Amazon Linuxiin

```bash
ssh -i "${KEY_NAME}.pem" ec2-user@"$PUBLIC_IP"
```

Ensimmäisellä yhteyskerralla hyväksy palvelimen host key vain, jos IP-osoite vastaa juuri luomaasi instanssia.

## 13. Instanssin metadatan käyttäminen

Amazon Linux 2023 käyttää IMDSv2:ta. Luo ensin istuntotunnus EC2-instanssin sisällä:

```bash
TOKEN=$(curl -sS -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)
```

Hae esimerkiksi instanssin ID, paikallinen IP ja Availability Zone:

```bash
curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id

echo

curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4

echo

curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone

echo
```

Jos instanssille on liitetty IAM-rooli, AWS CLI voi hakea roolin tilapäiset tunnukset automaattisesti instanssin metadatasta. Älä kopioi Learner Labin omia tunnuksia EC2-palvelimelle.

## 14. Resurssien tarkistaminen

```bash
aws ec2 describe-vpcs \
  --region "$AWS_REGION" \
  --vpc-ids "$VPC_ID" \
  --output table

aws ec2 describe-subnets \
  --region "$AWS_REGION" \
  --subnet-ids "$SUBNET_ID" \
  --output table

aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,Id:InstanceId,State:State.Name,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}' \
  --output table
```

## 15. Resurssien siivoaminen

Poista resurssit käänteisessä järjestyksessä.

### 15.1 Lopeta EC2-instanssi

```bash
aws ec2 terminate-instances \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID"

aws ec2 wait instance-terminated \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID"
```

### 15.2 Poista avainpari ja paikallinen avaintiedosto

```bash
aws ec2 delete-key-pair --region "$AWS_REGION" --key-name "$KEY_NAME"
rm -f "${KEY_NAME}.pem"
```

### 15.3 Poista Security Group

```bash
aws ec2 delete-security-group --region "$AWS_REGION" --group-id "$SG_ID"
```

### 15.4 Irrota ja poista reititystaulu

```bash
aws ec2 disassociate-route-table \
  --region "$AWS_REGION" \
  --association-id "$ROUTE_ASSOC_ID"

aws ec2 delete-route-table \
  --region "$AWS_REGION" \
  --route-table-id "$ROUTE_TABLE_ID"
```

### 15.5 Irrota ja poista Internet Gateway

```bash
aws ec2 detach-internet-gateway \
  --region "$AWS_REGION" \
  --internet-gateway-id "$IGW_ID" \
  --vpc-id "$VPC_ID"

aws ec2 delete-internet-gateway \
  --region "$AWS_REGION" \
  --internet-gateway-id "$IGW_ID"
```

### 15.6 Poista subnet ja VPC

```bash
aws ec2 delete-subnet --region "$AWS_REGION" --subnet-id "$SUBNET_ID"
aws ec2 delete-vpc --region "$AWS_REGION" --vpc-id "$VPC_ID"
```

## Vianmääritys

### `ExpiredToken`

Learner Labin tilapäinen sessio on vanhentunut. Käynnistä laboratorio, kopioi uudet tunnukset ja päivitä kaikki kolme arvoa.

### `UnauthorizedOperation` tai `AccessDenied`

Learner Labin IAM-rooli ei salli komentoa tai resurssia. Tarkista laboratorion ohjeista sallittu alue, instanssityyppi ja resurssit.

### SSH-yhteys aikakatkaistaan

Tarkista:

- instanssin tila on `running`
- instanssilla on julkinen IPv4-osoite
- subnetin reititystaulussa on reitti `0.0.0.0/0` Internet Gatewaylle
- Security Group sallii TCP/22-liikenteen nykyisestä julkisesta IP-osoitteestasi
- käytät käyttäjätunnusta `ec2-user`
- käytät oikeaa `.pem`-avainta

### `InvalidKeyPair.NotFound`

Avainpari ei ole samalla AWS-alueella kuin EC2-instanssi. Luo avainpari käyttämällä samaa `--region`-arvoa.

## Oppimistavoitteet

Harjoituksen jälkeen opiskelija osaa:

- asentaa ja konfiguroida AWS CLI v2:n
- käyttää AWS Academy Learner Labin tilapäisiä tunnuksia
- luoda VPC:n, subnetin, Internet Gatewayn ja reititystaulun
- rajata SSH-liikenteen Security Groupilla
- käynnistää Amazon Linux 2023 -EC2-instanssin
- käyttää IMDSv2-instanssimetadataa
- tarkistaa ja poistaa luodut AWS-resurssit

## Lähteet

- [AWS CLI v2:n asennus Linuxiin](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS CLI:n asetukset ja tunnusten käsittely](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [EC2-instanssien käynnistäminen AWS CLI:llä](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instances.html)
- [aws ec2 run-instances -komentoviite](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)
- [EC2-instanssimetadatan käyttäminen AWS CLI:n tunnuslähteenä](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-metadata.html)
