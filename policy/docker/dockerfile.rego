package main

import future.keywords.if
import future.keywords.in
import future.keywords.contains

deny contains msg if {
    input[i].Cmd == "from"
    val := input[i].Value
    endswith(val[0], ":latest")
    msg := sprintf("FROM uses :latest tag: '%s'. Pin to specific version.", [val[0]])
}

deny contains msg if {
    input[i].Cmd == "from"
    val := input[i].Value
    not contains(val[0], ":")
    not val[0] == "scratch"
    msg := sprintf("FROM '%s' has no tag - will use :latest implicitly. Pin to specific version.", [val[0]])
}

deny contains msg if {
    input[i].Cmd == "user"
    val := input[i].Value
    val[0] == "root"
    msg := "Dockerfile should not use USER root"
}

warn contains msg if {
    not any_user
    msg := "No USER instruction found - container will run as root"
}

any_user if {
    input[i].Cmd == "user"
}

deny contains msg if {
    input[i].Cmd == "add"
    msg := "Use COPY instead of ADD (ADD has extra features that can be exploited)"
}

warn contains msg if {
    not any_healthcheck
    msg := "No HEALTHCHECK instruction - consider adding one"
}

any_healthcheck if {
    input[i].Cmd == "healthcheck"
}
