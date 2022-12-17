# In this example, the input variables (openldap_image, openldap_image_tag, and openldap_admin_password) are declared at the top of the file and passed as arguments to the helm_release resource. 
# The helm_release resource uses these variables to deploy the OpenLDAP Helm chart with the specified parameters.
# You can then use Terragrunt to manage the configuration and execution of this Terraform code. 
# For example, you could create a separate Terragrunt configuration file for each environment (e.g. test, stage, prod) and use variable overrides to set the appropriate values for the input variables.


# Declare the input variables
inputs = {
  openldap_image          = var.openldap_image
  openldap_image_tag      = var.openldap_image_tag
  openldap_admin_password = var.openldap_admin_password
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
}
