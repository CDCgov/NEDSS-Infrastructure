/*module aks{
  source = "../modules/aks"
  k8_admin_username= var.k8_admin_username
  azuread_service_principal_display_name= var.azuread_service_principal_display_name
  modern_resource_group_name= var.modern_resource_group_name
  k8_cluster_name= var.k8_cluster_name
  k8_cluster_version = var.k8_cluster_version
  k8_dns_prefix= var.k8_dns_prefix
  service_principal_client_secret= var.service_principal_client_secret
  modern_subnet=var.modern_subnet
  resource_prefix=var.resource_prefix
}
*/
module "aks" {
  source = "../modules/aks"
  #k8_admin_username= var.k8_admin_username
  #azuread_service_principal_display_name= var.azuread_service_principal_display_name
  modern_resource_group_name = var.modern_resource_group_name
  k8_cluster_name            = var.k8_cluster_name
  k8_cluster_version         = var.k8_cluster_version
  #k8_dns_prefix= var.k8_dns_prefix
  #service_principal_client_secret= var.service_principal_client_secret
  modern_subnet   = var.modern_subnet
  resource_prefix = var.resource_prefix
}