variable "resource_group_name" {
  type        = string
  default     = "AKS-resource"
  description = "Resource group name in your Azure subscription."
}

#variable "client_id" {
#  description = "Service Principal Client ID for AKS"
#  type        = string
#}
#
#variable "client_secret" {
#  description = "Service Principal Client Secret for AKS"
#  type        = string
#  sensitive   = true
#}
