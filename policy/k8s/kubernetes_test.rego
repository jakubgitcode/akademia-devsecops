package main

import future.keywords.if
import future.keywords.in

# Pomocniczy "dobry" manifest uzywany w wielu testach
good_deployment := {
    "metadata": {
        "labels": {"app": "test", "team": "dev"}
    },
    "spec": {
        "replicas": 2,
        "template": {
            "spec": {
                "automountServiceAccountToken": false,
                "securityContext": {
                    "runAsNonRoot": true,
                    "runAsUser": 1000,
                    "seccompProfile": {"type": "RuntimeDefault"}
                },
                "containers": [{
                    "name": "app",
                    "image": "nginx:1.27",
                    "securityContext": {
                        "runAsNonRoot": true,
                        "allowPrivilegeEscalation": false,
                        "readOnlyRootFilesystem": true,
                        "privileged": false,
                        "capabilities": {
                            "drop": ["ALL"]
                        }
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

# -------------------------------------------------------
# Test 1: Odrzuc brak limitow zasobow
# -------------------------------------------------------
test_deny_no_limits if {
    count(deny) > 0 with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        }
                    }]
                }
            }
        }
    }
}

# -------------------------------------------------------
# Test 2: Akceptuj pelny deployment bez deny
# -------------------------------------------------------
test_allow_good_deployment if {
    count(deny) == 0 with input as good_deployment
}

# -------------------------------------------------------
# Test 3: Odrzuc :latest tag
# -------------------------------------------------------
test_deny_latest_tag if {
    deny["Container 'app' uses :latest tag - pin to specific version"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:latest",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 4: Odrzuc brak etykiety 'app'
# -------------------------------------------------------
test_deny_missing_app_label if {
    deny["Deployment must have 'app' label"] with input as {
        "metadata": {"labels": {"team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 5: Odrzuc brak etykiety 'team'
# -------------------------------------------------------
test_deny_missing_team_label if {
    deny["Deployment must have 'team' label"] with input as {
        "metadata": {"labels": {"app": "myapp"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 6: Odrzuc hostNetwork
# -------------------------------------------------------
test_deny_host_network if {
    deny["hostNetwork is not allowed - exposes host network namespace"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "hostNetwork": true,
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 7: Odrzuc hostPID
# -------------------------------------------------------
test_deny_host_pid if {
    deny["hostPID is not allowed - exposes host process namespace"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "hostPID": true,
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 8: Odrzuc brak readOnlyRootFilesystem
# -------------------------------------------------------
test_deny_no_readonly_fs if {
    deny["Container 'app' must have readOnlyRootFilesystem: true"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 9: Odrzuc uprzywilejowany kontener (privileged)
# -------------------------------------------------------
test_deny_privileged if {
    deny["Container 'app' must not run as privileged"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "privileged": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 10: Ostrzec gdy repliki < 2
# -------------------------------------------------------
test_warn_low_replicas if {
    warn["Deployment has only 1 replica(s) - consider at least 2 for HA"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 1,
            "template": {
                "spec": {
                    "automountServiceAccountToken": false,
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 11: Odrzuc automountServiceAccountToken: true
# -------------------------------------------------------
test_deny_automount_service_account if {
    deny["automountServiceAccountToken should be false unless explicitly required"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "automountServiceAccountToken": true,
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["ALL"]}
                        },
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

# -------------------------------------------------------
# Test 12: Odrzuc brak drop ALL capabilities
# -------------------------------------------------------
test_deny_missing_drop_all if {
    deny["Container 'app' must drop ALL capabilities"] with input as {
        "metadata": {"labels": {"app": "test", "team": "dev"}},
        "spec": {
            "replicas": 2,
            "template": {
                "spec": {
                    "securityContext": {"runAsNonRoot": true, "seccompProfile": {"type": "RuntimeDefault"}},
                    "containers": [{
                        "name": "app",
                        "image": "nginx:1.27",
                        "securityContext": {
                            "runAsNonRoot": true,
                            "allowPrivilegeEscalation": false,
                            "readOnlyRootFilesystem": true,
                            "capabilities": {"drop": ["NET_RAW"]}
                        },
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
