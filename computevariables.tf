/*   These variables belong to the provider block.   Project ID is the ID of the service project where these VPC and
     subnets to be created. Region is the GCP region where all these network and related services to be provisioned.
*/
variable "gcp_project_id" {} 
variable "provider_region" {}
variable "host_project" {}
variable "compute_region" {}
/*
Variables declarations for Windows Bastion Host 
*/
variable "bastion_shared_subnet" {}    
variable "bastion_compute_machine_type" {}
variable "bastion_compute_zone" {}              
variable "bastion_compute_image" {}   
variable "bastion_host_win" {}    
variable "bastion_internal_ip" {}

/*
Variables declarations for OpenVPN 
*/
variable "openvpn_compute_zone" {}
variable "openvpn_compute_image" {}
variable "openvn_shared_subnet" {}
variable "openvpn_instance_win" {}
variable "openvpn_compute_machine_type" {}
/*
Variables declarations for InfoShare Server 
*/
variable "infoshare_compute_zone" {}
variable "infoshare_compute_image" {}
variable "infoshare_shared_subnet" {}
variable "infoshare_instance_win" {}
variable "infoshare_compute_machine_type" {}
variable "infoshare_internal_ip" {}
