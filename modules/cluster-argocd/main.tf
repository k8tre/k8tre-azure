terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    argocd = {
      source  = "0011blindmice/argocd"
      version = "1.0.3"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }

  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  alias           = "azure-k8sman"
  subscription_id = var.azure_k8tre_mgmt_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-dev"
  subscription_id = var.azure_k8tre_dev_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-stg"
  subscription_id = var.azure_k8tre_stg_cluster_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "azure-prd"
  subscription_id = var.azure_k8tre_prd_cluster_subscription_id
  features {}
}

provider "kubernetes" {
  alias                  = "k8s-dev"
  host                   = var.dev_kube_host
  cluster_ca_certificate = base64decode(var.dev_cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    #args        = ["get-token", "--login", "msi", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    args = ["get-token", "--login", "spn",
      "--client-id", "${var.spn_client_id}",
      "--client-secret", "${var.SPN_CLIENT_SECRET}",
      "--tenant-id", "${var.azure_tenant_id}",
    "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "kubernetes" {
  alias                  = "k8s-stg"
  host                   = var.stg_kube_host
  cluster_ca_certificate = base64decode(var.stg_cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = ["get-token", "--login", "spn",
      "--client-id", "${var.spn_client_id}",
      "--client-secret", "${var.SPN_CLIENT_SECRET}",
      "--tenant-id", "${var.azure_tenant_id}",
    "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "kubernetes" {
  alias                  = "k8s-prd"
  host                   = var.prd_kube_host
  cluster_ca_certificate = base64decode(var.prd_cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = ["get-token", "--login", "spn",
      "--client-id", "${var.spn_client_id}",
      "--client-secret", "${var.SPN_CLIENT_SECRET}",
      "--tenant-id", "${var.azure_tenant_id}",
    "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

data "external" "argo_token" {
  program = [
    "bash", "-c",
    <<EOT
        TOKEN=$(az account get-access-token --resource 9bb3b6ed-a234-4b88-897f-b576923ee790 --query accessToken -o tsv)
        TOKEN=$(echo $TOKEN | tr -d '\n')
        echo "{\"token\":\"$TOKEN\"}"
    EOT
  ]
}

provider "argocd" {
  port_forward_with_namespace = "argocd"
  auth_token                  = data.external.argo_token.result.token

  kubernetes {
    host                   = var.mgmt_kube_host
    cluster_ca_certificate = base64decode(var.mgmt_cluster_ca_certificate)
    config_context         = "argo-ctx"
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = ["get-token", "--login", "spn",
        "--client-id", "${var.spn_client_id}",
        "--client-secret", "${var.SPN_CLIENT_SECRET}",
        "--tenant-id", "${var.azure_tenant_id}",
      "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }
}

# data "azurerm_kubernetes_cluster" "dev_cluster" {
#   name                = "aks-k8tre-dev-cluster"
#   resource_group_name = "rg-k8tre-dev-uks-aks"
#   provider            = azurerm.azure-dev
# }

## Create the argocd service account in the dev cluster

resource "kubernetes_service_account_v1" "argocd" {
  provider = kubernetes.k8s-dev
  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "argocd_gen_sa_token" {
  provider = kubernetes.k8s-dev
  metadata {
    name      = "argocd-manager-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argocd.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "argocd" {
  provider = kubernetes.k8s-dev
  metadata {
    name = "argocd-manager-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd.metadata[0].name
    namespace = "kube-system"
  }
}

data "kubernetes_secret_v1" "argocd_sa_token" {
  provider = kubernetes.k8s-dev
  metadata {
    name      = kubernetes_secret_v1.argocd_gen_sa_token.metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [
    kubernetes_secret_v1.argocd_gen_sa_token
  ]
}

## Assign dev cluster to be managed by argocd

resource "argocd_cluster" "external" {
  name   = "k8tre-dev-cluster"
  server = var.dev_kube_host

  metadata {
    labels = {
      "environment"   = "dev"
      "external-dns"  = "azure"
      "secret-store"  = "kubernetes"
      "skip-cilium"   = "true"
      "skip-gateway"  = "false"
      "storage-class" = "azure"
      "vendor"        = "azure"
    }
  }

  config {
    bearer_token = data.kubernetes_secret_v1.argocd_sa_token.data.token
    tls_client_config {
      ca_data  = data.kubernetes_secret_v1.argocd_sa_token.data["ca.crt"]
      insecure = false
    }
  }
}

## External stg cluster

resource "kubernetes_service_account_v1" "stg_argocd" {
  provider = kubernetes.k8s-stg
  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "stg_argocd_gen_sa_token" {
  provider = kubernetes.k8s-stg
  metadata {
    name      = "argocd-manager-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.stg_argocd.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "stg_argocd" {
  provider = kubernetes.k8s-stg
  metadata {
    name = "argocd-manager-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.stg_argocd.metadata[0].name
    namespace = "kube-system"
  }
}

data "kubernetes_secret_v1" "stg_argocd_sa_token" {
  provider = kubernetes.k8s-stg
  metadata {
    name      = kubernetes_secret_v1.stg_argocd_gen_sa_token.metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [
    kubernetes_secret_v1.stg_argocd_gen_sa_token
  ]
}

## Assign stg cluster to be managed by argocd

resource "argocd_cluster" "stg_external" {
  name   = "k8tre-stg-cluster"
  server = var.stg_kube_host

  metadata {
    labels = {
      "environment"   = "stg"
      "external-dns"  = "azure"
      "secret-store"  = "kubernetes"
      "skip-cilium"   = "true"
      "skip-gateway"  = "false"
      "storage-class" = "azure"
      "vendor"        = "azure"
    }
  }

  config {
    bearer_token = data.kubernetes_secret_v1.stg_argocd_sa_token.data.token
    tls_client_config {
      ca_data  = data.kubernetes_secret_v1.stg_argocd_sa_token.data["ca.crt"]
      insecure = false
    }
  }
}





## External prd cluster

resource "kubernetes_service_account_v1" "prd_argocd" {
  provider = kubernetes.k8s-prd
  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "prd_argocd_gen_sa_token" {
  provider = kubernetes.k8s-prd
  metadata {
    name      = "argocd-manager-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.prd_argocd.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding" "prd_argocd" {
  provider = kubernetes.k8s-prd
  metadata {
    name = "argocd-manager-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.prd_argocd.metadata[0].name
    namespace = "kube-system"
  }
}

data "kubernetes_secret_v1" "prd_argocd_sa_token" {
  provider = kubernetes.k8s-prd
  metadata {
    name      = kubernetes_secret_v1.prd_argocd_gen_sa_token.metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [
    kubernetes_secret_v1.prd_argocd_gen_sa_token
  ]
}

## Assign prd cluster to be managed by argocd

resource "argocd_cluster" "prd_external" {
  name   = "k8tre-prd-cluster"
  server = var.prd_kube_host

  metadata {
    labels = {
      "environment"   = "prd"
      "external-dns"  = "azure"
      "secret-store"  = "kubernetes"
      "skip-cilium"   = "true"
      "skip-gateway"  = "false"
      "storage-class" = "azure"
      "vendor"        = "azure"
    }
  }

  config {
    bearer_token = data.kubernetes_secret_v1.prd_argocd_sa_token.data.token
    tls_client_config {
      ca_data  = data.kubernetes_secret_v1.prd_argocd_sa_token.data["ca.crt"]
      insecure = false
    }
  }
}

