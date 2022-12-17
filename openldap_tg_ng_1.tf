# In this example, the helm_release resource is used to deploy the OpenLDAP Helm chart to the Kubernetes cluster. 
# The set blocks are used to set the values of chart parameters, such as the image tag and the LDAP organization. 
# The openldap_service_name, openldap_ingress_host, and openldap_ingress_path variables are used to specify the service name, host, and path for the OpenLDAP Ingress resource.
# You can then use the terraform apply command to apply this configuration and deploy the OpenLDAP Helm chart to your Kubernetes

# Declare the input variables
inputs = {
  openldap_image          = var.openldap_image
  openldap_image_tag      = var.openldap_image_tag
  openldap_admin_password = var.openldap_admin_password
  openldap_service_name   = var.openldap_service_name
  openldap_ingress_host   = var.openldap_ingress_host
  openldap_ingress_path   = var.openldap_ingress_path
}

# Configure the Kubernetes provider
provider "kubernetes" {
  config_context_cluster = "CLUSTER_NAME"
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

  # Enable the NGINX Ingress controller
  set {
    name  = "ingress.enabled"
    value = true
  }

  # Set the service name and port for the OpenLDAP service
  set {
    name  = "service.name"
    value = inputs.openldap_service_name
  }

  set {
    name  = "service.port"
    value = "389"
  }

  # Set the host and path for the OpenLDAP Ingress resource
  set {
    name  = "ingress.hosts[0].host"
    value = inputs.openldap_ingress_host
  }

  set {
    name  = "ingress.hosts[0].paths[0]"
    value = inputs.openldap_ingress_path
  }
}
