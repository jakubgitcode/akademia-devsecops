package main

import future.keywords.if
import future.keywords.in

test_deny_no_limits if {
    count(deny) > 0 with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {"runAsNonRoot": true}
                    }]
                }
            }
        }
    }
}

test_allow_with_limits if {
    count(deny) == 0 with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false
                        },
                        "resources": {
                            "requests": {"cpu": "100m", "memory": "64Mi"},
                            "limits": {"cpu": "200m", "memory": "128Mi"}
                        }
                    }]
                }
            }
        }
    }
}

test_deny_latest_tag if {
    deny["Container 'app' uses :latest tag - pin to specific version"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "containers": [{
                        "name": "app",
                        "image": "nginx:latest",
                        "securityContext": {"runAsNonRoot": true},
                        "resources": {
                            "requests": {"cpu": "100m"},
                            "limits": {"cpu": "200m"}
                        }
                    }]
                }
            }
        }
    }
}
