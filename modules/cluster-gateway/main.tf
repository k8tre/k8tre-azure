terraform {

  required_version = ">= 1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.34.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
  }
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
      "--tenant-id", "${var.azure_tenant_id}",
    "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
  }
}

provider "kubectl" {
  host                   = var.kube_host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  load_config_file       = false
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
        "--tenant-id", "${var.azure_tenant_id}",
      "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    }
  }

}


locals {
  gateway_api_crd_urls = {
    gatewayclasses  = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml"
    gateways        = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml"
    httproutes      = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml"
    referencegrants = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml"
    grpcroutes      = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml"
  }
}

data "http" "gateway_crds" {
  for_each = local.gateway_api_crd_urls
  url      = each.value
}

resource "kubectl_manifest" "gateway__crds" {
  for_each   = data.http.gateway_crds
  yaml_body  = each.value.response_body
  apply_only = true
}


resource "helm_release" "cilium" {
  depends_on       = [kubectl_manifest.gateway__crds]
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.17.4"
  namespace        = "kube-system"
  create_namespace = false

  set {
    name  = "cluster.name"
    value = var.cluster_name
  }

  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }

  set {
    name  = "k8sServiceHost"
    value = var.kube_host
  }

  set {
    name  = "k8sServicePort"
    value = "443"
  }

  set {
    name  = "ipam.mode"
    value = "cluster-pool"
  }

  set {
    name  = "routingMode"
    value = "tunnel"
  }

  set {
    name  = "enableIPv4Masquerade"
    value = "true"
  }

  set {
    name  = "enableIPv6"
    value = "false"
  }

  set {
    name  = "gatewayAPI.enabled"
    value = "true"
  }

  set {
    name  = "hubble.enabled"
    value = "true"
  }

  set {
    name  = "hubble.ui.enabled"
    value = "true"
  }

  set {
    name  = "hubble.relay.enabled"
    value = "true"
  }

  set {
    name  = "securityPolicy.enabled"
    value = "true"
  }
}
