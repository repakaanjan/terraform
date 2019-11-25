provider_region                         = "europe-west2"
compute_region                          = "europe-west2"
host_project                            = "rare-attic-259807"
/*
Windows Bastion Host
Variable values to provided for creating a Windows VM with a specific image, internal IP passed as a parameter
*/
bastion_compute_zone                 = "europe-west2-c"
bastion_compute_machine_type         = "n1-standard-1"
bastion_compute_image                = "windows-server-2019-dc-v20191112
"
bastion_shared_subnet                = "petsathomeqasubnetapp"
bastion_host_win                     = "vm-ss-bastion-host"
bastion_internal_ip                  = "10.250.243.3"
/*
OpenVPN Server - 
Windows OpenVPN Server with public IP enabled
*/
openvpn_compute_zone                = "europe-west2-c"
openvpn_compute_image               = "windows-server-2019-dc-v20191112"
openvn_shared_subnet                = "petsathome-qa-subnet-db"
openvpn_instance_win                = "vm-ss-open-vpn"
openvpn_compute_machine_type        = "n1-standard-1"
/*
OpenVPN Server - 
Windows OpenVPN Server with internal IP - internal ip can be provided as
 a parameter value
*/
infoshare_compute_zone              =  "europe-west2-c"
infoshare_compute_image             =  "windows-server-2019-dc-v20191112
"
infoshare_shared_subnet             =  "petsathome-qa-subnet-host"
infoshare_instance_win              =  "vm-ss-infoshare-win"
infoshare_compute_machine_type      = "n1-standard-1"
infoshare_internal_ip                 = "10.250.240.3"
