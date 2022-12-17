# In this example, the helm_release resource is used to deploy both the NGINX ingress controller and the OpenLDAP Helm chart to the Kubernetes cluster. 
# The ingress.enabled and ingress.hosts[0].name parameters are used to enable ingress and specify the hostname for the OpenLDAP service. 
# The ingress.annotations parameter is used to set additional ingress annotations, such as the ssl-redirect annotation to disable SSL redirection.
# The input variables (openldap_image, openldap_image_tag, openldap_admin_password, and openldap_ingress_hostname) are declared at the top of the file and passed as

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

# Deploy the NGINX ingress controller
resource "helm_release" "ingress_controller" {
  name       = "ingress-controller"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "nginx-ingress"

  set {
    name  = "rbac.create"
    value = true
  }
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
    name  = "image.repository"
    value = inputs.openldap_image
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
    name = "ingress.annotations."
    value = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }
}
