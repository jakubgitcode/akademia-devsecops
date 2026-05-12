# Lab0 - Terraform bez chmury (provider random)

Cel tego labu:
- zrozumiec jak dzialaja variables,
- zobaczyc po co sa locals,
- nauczyc sie czytac i wykorzystywac outputs,
- wykonac pelny lifecycle init -> plan -> apply bez tworzenia zasobow w cloudzie.

## Co tu jest

- main.tf: terraform block, locals i zasoby random,
- variables.tf: zmienne wejsciowe z walidacja,
- outputs.tf: outputy (w tym sensitive),
- skrypt.sh: pomocniczy skrypt do uruchomienia labu.

## Instalacja Terraform

Jeśli nie masz zainstalowanego Terraform na Linux Mint, użyj przygotowanego skryptu:

```bash
chmod +x setup-terraform.sh
./setup-terraform.sh
```

**Skrypt automatycznie:**
- Automatycznie mapuje Linux Mint do Ubuntu base (rozwiązuje błąd z repozytorium)
- Dodaje klucz GPG HashiCorp (rozwiązuje błąd `NO_PUBKEY AA16FCBCA621E701`)
- Rejestruje repozytorium HashiCorp
- Instaluje Terraform
- Weryfikuje instalację

**Notatka:** Wiadomości o architekturze i386 są bezpieczne do zignorowania.

### Instalacja manualna (jeśli skrypt nie działa)

Jeśli wolisz zainstalować ręcznie, wykonaj te kroki:

```bash
# 1. Zainstaluj wymagane pakiety
sudo rm -f /etc/apt/sources.list.d/hashicorp.list /etc/apt/sources.list.d/hashicorp.sources
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 2. Dodaj klucz GPG HashiCorp (rozwiązuje GPG error)
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
sudo chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 3. Ustal poprawny codename Ubuntu dla Linux Mint
DISTRO=$(lsb_release -cs)
if [ -f /etc/linuxmint/info ]; then
	UBUNTU_CODENAME=$(grep "UBUNTU_CODENAME=" /etc/linuxmint/info | cut -d'=' -f2)
	[ -n "$UBUNTU_CODENAME" ] && DISTRO="$UBUNTU_CODENAME"
fi

# Fallback (Mint 22.2 zara -> Ubuntu noble)
[ "$DISTRO" = "zara" ] && DISTRO="noble"

# 4. Dodaj repozytorium HashiCorp
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $DISTRO main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# 5. Zaktualizuj listę pakietów
sudo apt-get update

# 6. Zainstaluj Terraform
sudo apt-get install -y terraform

# 7. Weryfikuj instalację
terraform version
```

## Jak uruchomić lab

```bash
cd iaac_w_terraform/lab0
terraform init
terraform plan
terraform apply -auto-approve
terraform output
```

Albo skrotem (po zainstalowaniu Terraform):

```bash
./skrypt.sh
```

## Co omawiac krok po kroku

1. Variables
- Zobacz deklaracje w variables.tf.
- Zmien np. environment lub owner przez plik tfvars albo -var.
- Pokaz walidacje (np. pet_words poza zakresem).

2. Locals
- local.normalized_owner i local.name_prefix upraszczaja budowanie nazw.
- To dobra praktyka: trzymac logike transformacji danych w locals.

3. Random resources
- random_pet: czytelna nazwa,
- random_string: alfanumeryczny suffix,
- random_integer: przykladowa liczba replik,
- random_password: token (bez chmury, ale juz z konsekwencjami security).

4. Outputs
- deployment_id: normalny string output,
- deployment_config: output jako obiekt,
- api_token: output oznaczony sensitive = Terraform ukrywa wartosc.

## Przykladowe scenariusze na zajeciach

```bash
# 1) baseline
terraform apply -auto-approve

# 2) zmiana wejscia
terraform apply -auto-approve -var='environment=test' -var='owner=Platform Team'

# 3) tylko output JSON (np. pod CI)
terraform output -json
```

## Sprzatanie

```bash
terraform destroy -auto-approve
```
