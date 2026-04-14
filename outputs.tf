output "vault_cluster_id" {
  description = "HCP Vault cluster ID."
  value       = hcp_vault_cluster.this.cluster_id
}

output "vault_private_endpoint_url" {
  description = "Private endpoint URL for the HCP Vault cluster."
  value       = hcp_vault_cluster.this.vault_private_endpoint_url
}

output "hvn_id" {
  description = "HCP HVN ID."
  value       = hcp_hvn.this.hvn_id
}

output "azure_peering_state" {
  description = "State of the HVN to Azure peering connection."
  value       = data.hcp_azure_peering_connection.active.state
}

output "azure_vm_private_ip" {
  description = "Private IP of the Ubuntu compute node."
  value       = azurerm_network_interface.vm.private_ip_address
}

output "azure_vm_public_ip" {
  description = "Public IP of the Ubuntu compute node when enabled."
  value       = var.create_vm_public_ip ? azurerm_public_ip.vm[0].ip_address : null
}

output "azure_vm_ssh_command" {
  description = "Convenience SSH command when a public IP is enabled."
  value       = var.create_vm_public_ip ? "ssh -i ${path.root}/${var.azure_vm_private_key_filename} ${var.azure_vm_admin_username}@${azurerm_public_ip.vm[0].ip_address}" : null
}

output "azure_vm_private_key_path" {
  description = "Path to the generated private key file for the Ubuntu VM."
  value       = "${path.root}/${var.azure_vm_private_key_filename}"
}
