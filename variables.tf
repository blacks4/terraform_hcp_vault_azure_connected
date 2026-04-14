variable "hcp_client_id" {
  description = "HCP service principal client ID."
  type        = string
  sensitive   = true
}

variable "hcp_client_secret" {
  description = "HCP service principal client secret."
  type        = string
  sensitive   = true
}

variable "hcp_project_id" {
  description = "Target HCP project ID."
  type        = string
}

variable "hcp_region" {
  description = "HCP region for the Azure HVN and Vault cluster."
  type        = string
  default     = "eastus"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant ID."
  type        = string
}

variable "azure_client_id" {
  description = "Azure service principal client ID."
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure service principal client secret."
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment tag value."
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefix used for Azure support resources."
  type        = string
  default     = "hcp-vault"
}

variable "azure_location" {
  description = "Azure region for the resource group, VNet, and VM."
  type        = string
  default     = "East US"
}

variable "azure_resource_group_name" {
  description = "Azure resource group name."
  type        = string
  default     = "rg-hcp-vault"
}

variable "azure_vnet_name" {
  description = "Azure virtual network name."
  type        = string
  default     = "vnet-hcp-vault"
}

variable "azure_vnet_cidr" {
  description = "Azure VNet CIDR. Must not overlap with the HVN CIDR."
  type        = string
  default     = "10.60.0.0/16"
}

variable "azure_subnet_name" {
  description = "Azure subnet name for the Ubuntu VM."
  type        = string
  default     = "snet-compute"
}

variable "azure_subnet_cidr" {
  description = "Azure subnet CIDR for the Ubuntu VM."
  type        = string
  default     = "10.60.1.0/24"
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to the Ubuntu VM."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_vm_public_ip" {
  description = "Whether to assign a public IP to the Ubuntu VM for management access."
  type        = bool
  default     = true
}

variable "azure_vm_name" {
  description = "Azure Ubuntu VM name."
  type        = string
  default     = "vm-hcp-vault-client"
}

variable "azure_vm_size" {
  description = "Azure VM size for the Ubuntu compute node."
  type        = string
  default     = "Standard_B2s"
}

variable "azure_vm_admin_username" {
  description = "Admin username for the Ubuntu VM."
  type        = string
  default     = "azureuser"
}

variable "azure_vm_private_key_filename" {
  description = "Private key filename Terraform writes into the working directory for SSH access."
  type        = string
  default     = "azure-vm-key.pem"
}

variable "hvn_id" {
  description = "HCP HVN ID."
  type        = string
  default     = "azure-hvn"
}

variable "hvn_cidr_block" {
  description = "CIDR block for the HCP HVN."
  type        = string
  default     = "172.25.48.0/20"
}

variable "hvn_peering_id" {
  description = "HCP Azure peering connection ID."
  type        = string
  default     = "azure-peering"
}

variable "hvn_route_id" {
  description = "HCP route ID for Azure VNet reachability."
  type        = string
  default     = "azure-vnet-route"
}

variable "vault_cluster_id" {
  description = "HCP Vault cluster ID."
  type        = string
  default     = "vault-standard-small"
}

variable "tags" {
  description = "Additional Azure tags to apply."
  type        = map(string)
  default     = {}
}
