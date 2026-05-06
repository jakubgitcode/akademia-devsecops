package main

import future.keywords.if
import future.keywords.in
import future.keywords.contains

# Deny containers without resource limits
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.limits
    msg := sprintf("Container '%s' must have resource limits", [container.name])
}

# Deny containers without resource requests
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.resources.requests
    msg := sprintf("Container '%s' must have resource requests", [container.name])
}

# Deny containers running as root
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not container.securityContext.runAsNonRoot
    not input.spec.template.spec.securityContext.runAsNonRoot
    msg := sprintf("Container '%s' must set runAsNonRoot: true", [container.name])
}

# Deny containers with privilege escalation
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
    msg := sprintf("Container '%s' must not allow privilege escalation", [container.name])
}

# Deny :latest tag
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("Container '%s' uses :latest tag - pin to specific version", [container.name])
}

# Deny missing image tag
deny contains msg if {
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("Container '%s' has no image tag - will use :latest", [container.name])
}

# Require specific labels
deny contains msg if {
    not input.metadata.labels.app
    msg := "Deployment must have 'app' label"
}

deny contains msg if {
    not input.metadata.labels.team
    msg := "Deployment must have 'team' label"
}

# Warn if replicas < 2
warn contains msg if {
    input.spec.replicas < 2
    msg := sprintf("Deployment has only %d replica(s) - consider at least 2 for HA", [input.spec.replicas])
}

# Deny hostNetwork
deny contains msg if {
    input.spec.template.spec.hostNetwork == true
    msg := "hostNetwork is not allowed"
}

# Deny hostPID
deny contains msg if {
    input.spec.template.spec.hostPID == true
    msg := "hostPID is not allowed"
}
