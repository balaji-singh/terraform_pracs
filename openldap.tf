
# In this example, the helm_release resource is used to deploy the OpenLDAP Helm chart to the Kubernetes cluster. 
# The set blocks are used to set the values of chart parameters, such as the image tag and the LDAP organization. The openldap_image and openldap_image_tag variables are used to specify the Docker image and tag to use for the OpenLDAP container, and the openldap_admin_password variable is used to set the password for the LDAP admin user.
# You can then use the terraform apply command to apply this configuration and deploy the OpenLDAP Helm chart to your Kubernetes cluster.

# Configure the Kubernetes provider
provider "kubernetes" {
  config_context_cluster = "CLUSTER_NAME"
}

# Declare the input variables
variable "openldap_image" {
  default = "osixia/openldap"
}

variable "openldap_image_tag" {
  default = "1.3.0"
}

variable "openldap_admin_password" {
  default = "admin"
}

# Deploy the OpenLDAP Helm chart
resource "helm_release" "openldap" {
  name       = "openldap"
  repository = "https://charts.osixia.net/stable"
  chart      = "openldap"

  set {
    name  = "image.tag"
    value = var.openldap_image_tag
  }

  set {
    name  = "persistence.size"
    value = "1Gi"
  }

  set {
    name  = "env.ADMIN_PASSWORD"
    value = var.openldap_admin_password
  }

  set {
    name  = "env.LDAP_ORGANISATION"
    value = "My Company"
  }
}
