terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }

  }

  required_version = ">= 1.3.0"
}

provider "kubernetes" {
  host                   = var.kube_host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = ["get-token", "--login", "spn",
      "--client-id", "${var.spn_client_id}",
      "--client-secret", "${var.SPN_CLIENT_SECRET}",
      "--tenant-id", "${var.cluster_tenant_id}",
    "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }

}

provider "helm" {
  kubernetes {
    host                   = var.kube_host
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = ["get-token", "--login", "spn",
        "--client-id", "${var.spn_client_id}",
        "--client-secret", "${var.SPN_CLIENT_SECRET}",
        "--tenant-id", "${var.cluster_tenant_id}",
      "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }
}

provider "azuread" {}

data "azuread_service_principal" "ms_graph" {
  display_name = "Microsoft Graph"
}

data "azuread_application_published_app_ids" "well_known" {}

# TODO: Get dependency on mgmt cluster to pass in valid callback URL

resource "azuread_application" "argocd" {
  display_name = "argocd"

  group_membership_claims = ["All", "ApplicationGroup", "SecurityGroup"]

  api {
    requested_access_token_version = 2
  }

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = data.azuread_service_principal.ms_graph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }
  }

  optional_claims {
    id_token {
      name      = "groups"
      essential = false
    }

    access_token {
      name      = "groups"
      essential = false
    }

    saml2_token {
      name      = "groups"
      essential = false
    }
  }

  web {
    logout_url = "https://localhost:8443/auth/logout"
    redirect_uris = [
      "https://localhost:8443/auth/callback"
    ]
    implicit_grant {
      id_token_issuance_enabled     = false
      access_token_issuance_enabled = false
    }
  }

  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "argocd" {
  client_id  = azuread_application.argocd.client_id
  depends_on = [azuread_application.argocd]
}


resource "azuread_application_federated_identity_credential" "argocd_federation" {

  application_id = azuread_application.argocd.id
  display_name   = "argo-federated"
  description    = "Federated identity for ArgoCD"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.oidc_issuer_url
  subject        = "system:serviceaccount:argocd:argocd-server"
}


# Set up argoCD in mgmt cluster

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "8.6.1"
  create_namespace = false

  depends_on = [azuread_application.argocd]

  values = [
    yamlencode({

      repoServer = {

        extraContainers = [
          {
            name    = "cmp-kustomize-envsubst"
            image   = "quay.io/argoproj/argocd:v3.1.8"
            command = ["/var/run/argocd/argocd-cmp-server"]
            securityContext = {
              runAsNonRoot             = true
              runAsUser                = 999
              allowPrivilegeEscalation = false
              readOnlyRootFilesystem   = true
              capabilities = {
                drop = ["ALL"]
              }
              seccompProfile = {
                type = "RuntimeDefault"
              }
            }
            volumeMounts = [
              { mountPath = "/var/run/argocd", name = "var-files" },
              { mountPath = "/home/argocd/cmp-server/plugins", name = "plugins" },
              { mountPath = "/tmp", name = "tmp" },
              { mountPath = "/home/argocd/cmp-server/config/plugin.yaml", name = "cmp-plugin", subPath = "plugin.yaml" }
            ]
          }
        ]

        volumes = [
          {
            name = "cmp-plugin"
            configMap = {
              name = "cmp-plugin"
            }
          }
        ]
      }


      server = {
        podLabels = {
          "azure.workload.identity/use" = "true"
        }

        serviceAccount = {
          annotations = {
            "azure.workload.identity/client-id" = azuread_application.argocd.client_id
          }
        }
      }

      controller = {
        serviceAccount = {
          annotations = {
            "azure.workload.identity/client-id" = azuread_application.argocd.client_id
          }
        }
      }

      configs = {

        cmp = {
          create = true
          plugins = {
            "kustomize-with-envsubst" = <<-EOT
              apiVersion: argoproj.io/v1alpha1
              kind: ConfigManagementPlugin
              metadata:
                name: kustomize-with-envsubst
              spec:
                version: v1.0
                generate:
                  command: [sh, -c]
                  args:
                    - |
                      kustomize build --enable-helm --load-restrictor LoadRestrictionsNone . | \
                      sed "s/\$${ENVIRONMENT}/$${ARGOCD_ENV_ENVIRONMENT}/g; s/\$${DOMAIN}/$${ARGOCD_ENV_DOMAIN}/g; s/\\.ENVIRONMENT\\./.$${ARGOCD_ENV_ENVIRONMENT}./g; s/\\.DOMAIN/.$${ARGOCD_ENV_DOMAIN}/g; s/^ENVIRONMENT$/$${ARGOCD_ENV_ENVIRONMENT}/g; s/^DOMAIN$/$${ARGOCD_ENV_DOMAIN}/g"
            EOT
          }
        }

        cm = {
          url = "https://localhost:8443" # TODO: create argo ingress to set dynamically

          "kustomize.buildOptions" = "--enable-helm --load-restrictor LoadRestrictionsNone"

          "oidc.config" = join("\n", [
            "name: Azure",
            "issuer: https://login.microsoftonline.com/${var.cluster_tenant_id}/v2.0",
            "clientID: ${azuread_application.argocd.client_id}",
            "azure:",
            "  useWorkloadIdentity: true",
            "requestedIDTokenClaims:",
            "  groups:",
            "    essential: true",
            # "    value: \"SecurityGroup\"",
            "requestedScopes:",
            "  - openid",
            "  - profile",
            "  - email"
          ])
        }

        rbac = {
          scopes = "[groups, email]"

          "policy.csv" = join("\n", [
            "p, role:org-admin, applications, *, */*, allow",
            "p, role:org-admin, clusters, *, *, allow",
            "p, role:org-admin, repositories, get, *, allow",
            "p, role:org-admin, repositories, create, *, allow",
            "p, role:org-admin, repositories, update, *, allow",
            "p, role:org-admin, repositories, delete, *, allow",
            "g, \"${var.entra_admin_group_id}\", role:org-admin"
          ])
        }
      }
    })
  ]
}

