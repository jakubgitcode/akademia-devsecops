package main

import future.keywords.if
import future.keywords.in
import future.keywords.contains

# Regula 1: Zakaz uzywania tagu :latest w FROM
deny contains msg if {
    input[i].Cmd == "from"
    val := input[i].Value
    endswith(val[0], ":latest")
    msg := sprintf("FROM uses :latest tag: '%s'. Pin to specific version.", [val[0]])
}

# Regula 2: Zakaz FROM bez tagu (implicit :latest)
deny contains msg if {
    input[i].Cmd == "from"
    val := input[i].Value
    not contains(val[0], ":")
    not val[0] == "scratch"
    msg := sprintf("FROM '%s' has no tag - will use :latest implicitly. Pin to specific version.", [val[0]])
}

# Regula 3: Zakaz USER root
deny contains msg if {
    input[i].Cmd == "user"
    val := input[i].Value
    val[0] == "root"
    msg := "Dockerfile should not use USER root"
}

# Regula 4: Ostrzezenie gdy brak instrukcji USER
warn contains msg if {
    not any_user
    msg := "No USER instruction found - container will run as root"
}

any_user if {
    input[i].Cmd == "user"
}

# Regula 5: Zakaz ADD (preferuj COPY)
deny contains msg if {
    input[i].Cmd == "add"
    msg := "Use COPY instead of ADD (ADD has extra features that can be exploited)"
}

# Regula 6: Ostrzezenie gdy brak HEALTHCHECK
warn contains msg if {
    not any_healthcheck
    msg := "No HEALTHCHECK instruction - consider adding one for production readiness"
}

any_healthcheck if {
    input[i].Cmd == "healthcheck"
}

# Regula 7: Zakaz przechowywania sekretow w zmiennych ENV
deny contains msg if {
    input[i].Cmd == "env"
    val := input[i].Value
    key := lower(val[_])
    suspicious_env_keys[key]
    msg := sprintf("ENV instruction may contain a secret (key: '%s'). Use build secrets or runtime secrets instead.", [val[0]])
}

suspicious_env_keys := {
    "password", "secret", "token", "api_key", "apikey", "private_key",
    "aws_secret_access_key", "db_password", "database_password",
    "auth_token", "oauth_token"
}

# Regula 8: Zakaz uruchamiania apt/apk bez --no-cache lub flagi pin version w RUN
deny contains msg if {
    input[i].Cmd == "run"
    val := input[i].Value
    cmd := concat(" ", val)
    contains(cmd, "apt-get install")
    not contains(cmd, "--no-install-recommends")
    msg := "apt-get install should use --no-install-recommends to minimize image size and attack surface"
}

# Regula 9: Zakaz EXPOSE portu 22 (SSH)
deny contains msg if {
    input[i].Cmd == "expose"
    val := input[i].Value
    val[0] == "22"
    msg := "EXPOSE 22 (SSH) is not allowed in containers - use kubectl exec or similar instead"
}

# Regula 10: Zakaz wieloetapowego budowania z rootem
deny contains msg if {
    input[i].Cmd == "run"
    val := input[i].Value
    cmd := concat(" ", val)
    contains(cmd, "chmod 777")
    msg := "chmod 777 grants excessive permissions - use more restrictive permissions"
}

# Regula 11: Wymagaj WORKDIR (nie uruchamiac z /)
deny contains msg if {
    not any_workdir
    msg := "No WORKDIR instruction found - working directory defaults to / which is insecure"
}

any_workdir if {
    input[i].Cmd == "workdir"
}
