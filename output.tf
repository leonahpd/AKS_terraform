output "management_client_certificate" {
  value     = azurerm_kubernetes_cluster.kubernetes_aks2.kube_config[0].client_certificate
  sensitive = true
}

output "management_kube_config" {
  value = azurerm_kubernetes_cluster.kubernetes_aks2.kube_config_raw

  sensitive = true
}
