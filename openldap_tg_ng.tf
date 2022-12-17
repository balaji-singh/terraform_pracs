# In this example, the kubernetes_manifest resource is used to deploy the NGINX Ingress controller to the Kubernetes cluster. 
# The helm_release resource then configures the OpenLDAP Helm chart to use the ingress controller by enabling the ingress parameter and setting the ingress.hosts[0].name and ingress.tls[0].secretName parameters. 
# The kubernetes_secret resource is then used to create a secret in the Kubernetes cluster that stores the TLS certificate and key for the ingress hostname.

# Declare the input variables
inputs = {
  openldap_image            = var.openldap_image
  openldap_image_tag        = var.openldap_image_tag
  openldap_admin_password   = var.openldap_admin_password
  openldap_ingress_hostname = var.openldap_ingress_hostname
}

# Configure the Kubernetes provider
provider "kubernetes" {
  config_context_cluster = "CLUSTER_NAME"
}

# Deploy the NGINX Ingress controller
resource "kubernetes_manifest" "ingress_controller" {
  manifest = file("ingress-controller.yaml")
}

# Deploy the OpenLDAP Helm chart
resource "helm_release" "openldap" {
  name       = "openldap"
  repository = "https://charts.osixia.net/stable"
  chart      = "openldap"

  set {
    name  = "image.tag"
    value = inputs.openldap_image_tag
  }

  set {
    name  = "persistence.size"
    value = "1Gi"
  }

  set {
    name  = "env.ADMIN_PASSWORD"
    value = inputs.openldap_admin_password
  }

  set {
    name  = "env.LDAP_ORGANISATION"
    value = "My Company"
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.hosts[0].name"
    value = inputs.openldap_ingress_hostname
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = "openldap-tls"
  }
}

# Create a secret to store the TLS certificate and key
resource "kubernetes_secret" "openldap_tls" {
  metadata {
    name = "openldap-tls"
  }

  data = {
    "tls.crt" = base64encode(file("tls.crt")),
    "tls.key" = base64encode(file("tls.key"))
  }
}
