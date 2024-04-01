variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}

variable "resource_group_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "kubernetes_version" {
  type        = string
  default     = "1.27.9"
  description = "Kubernetes version."
}