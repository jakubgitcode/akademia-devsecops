package main

import future.keywords.if
import future.keywords.in
import future.keywords.contains

# -------------------------------------------------------
# Regula 1: Kontenery musza miec limity zasobow
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits
    msg := sprintf("Container '%s' must have resource limits", [container.name])
}

# -------------------------------------------------------
# Regula 2: Kontenery musza miec resource requests
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.requests
    msg := sprintf("Container '%s' must have resource requests", [container.name])
}

# -------------------------------------------------------
# Regula 3: Zakaz uruchamiania jako root (runAsNonRoot)
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.runAsNonRoot
    not input.spec.template.spec.securityContext.runAsNonRoot
    msg := sprintf("Container '%s' must set runAsNonRoot: true", [container.name])
}

# -------------------------------------------------------
# Regula 4: Zakaz privilege escalation
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
    msg := sprintf("Container '%s' must not allow privilege escalation", [container.name])
}

# -------------------------------------------------------
# Regula 5: Zakaz tagu :latest w obrazach
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("Container '%s' uses :latest tag - pin to specific version", [container.name])
}

# -------------------------------------------------------
# Regula 6: Zakaz obrazow bez tagu (implicit :latest)
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("Container '%s' has no image tag - will use :latest", [container.name])
}

# -------------------------------------------------------
# Regula 7: Wymagaj etykiety 'app'
# -------------------------------------------------------
deny contains msg if {
    not input.metadata.labels.app
    msg := "Deployment must have 'app' label"
}

# -------------------------------------------------------
# Regula 8: Wymagaj etykiety 'team'
# -------------------------------------------------------
deny contains msg if {
    not input.metadata.labels.team
    msg := "Deployment must have 'team' label"
}

# -------------------------------------------------------
# Regula 9: Zakaz hostNetwork
# -------------------------------------------------------
deny contains msg if {
    input.spec.template.spec.hostNetwork == true
    msg := "hostNetwork is not allowed - exposes host network namespace"
}

# -------------------------------------------------------
# Regula 10: Zakaz hostPID
# -------------------------------------------------------
deny contains msg if {
    input.spec.template.spec.hostPID == true
    msg := "hostPID is not allowed - exposes host process namespace"
}

# -------------------------------------------------------
# Regula 11: Zakaz automountServiceAccountToken (chyba ze wyraznie wylaczone)
# -------------------------------------------------------
deny contains msg if {
    input.spec.template.spec.automountServiceAccountToken == true
    msg := "automountServiceAccountToken should be false unless explicitly required"
}

# -------------------------------------------------------
# Regula 12: Wymagaj readOnlyRootFilesystem
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem
    msg := sprintf("Container '%s' must have readOnlyRootFilesystem: true", [container.name])
}

# -------------------------------------------------------
# Regula 13: Wymagaj drop ALL capabilities
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    dropped := container.securityContext.capabilities.drop
    not "ALL" in dropped
    msg := sprintf("Container '%s' must drop ALL capabilities", [container.name])
}

# -------------------------------------------------------
# Regula 14: Zakaz uprzywilejowanych kontenerow (privileged)
# -------------------------------------------------------
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf("Container '%s' must not run as privileged", [container.name])
}

# -------------------------------------------------------
# Regula 15: Wymagaj seccompProfile RuntimeDefault lub Localhost
# -------------------------------------------------------
deny contains msg if {
    seccomp := input.spec.template.spec.securityContext.seccompProfile.type
    seccomp != "RuntimeDefault"
    seccomp != "Localhost"
    msg := sprintf("Pod seccompProfile must be RuntimeDefault or Localhost, got: %s", [seccomp])
}

# -------------------------------------------------------
# Ostrzezenie: Zbyt malo replik (ponizej 2)
# -------------------------------------------------------
warn contains msg if {
    input.spec.replicas < 2
    msg := sprintf("Deployment has only %d replica(s) - consider at least 2 for HA", [input.spec.replicas])
}
