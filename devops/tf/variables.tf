variable "resource_group_name" {
	default = "Learning-TF-Resource-Group"
}

variable "azure_client_id" {
  sensitive = true
}

variable "azure_client_secret" {
  sensitive = true
}

variable "azure_tenant_id" {
  sensitive = true
}

variable "azure_subscription_id" {
  sensitive = true
}

variable "workflow_rg_location" {
  sensitive = true
}

variable "workflow_rg_name" {
  sensitive = true
}
