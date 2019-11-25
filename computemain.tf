/*
***************************************************************************************************************************************
Script                  : Script for creating compute services - VMs, App Engine, GKE
Description             : Provider details, credentials file name generated for the service account, Project name and region to be provided.
Changes to be performed : This section has to be updated with the name of the json file generated for the service account, GCP Project ID 
                          GCP region details before executing the sctipt.
                          JSON file to be kep in the /home directory of the logged in user. 
                          All these values to be provided as variable input in terraform.tfvars file.
                          Variables to be added/amended to be update in the variables.tf file.
                          Assumed that a VM has been created as metioned in the run book for executing the terraform scripts.
***************************************************************************************************************************************
*/
provider "google" {
 credentials = "${file("credentials.json")}"
 project     = "${var.gcp_project_id}"
 region      = "${var.provider_region}"
}
/***********************************************************************************************************/
// Windows Bastion Host
/***********************************************************************************************************/
/*
This section spins up a Windows VM for bastion host without an external IP assigned
Interal IP can be provided as a parameter, to retain the existing internal ip in case of migration
*/
resource "google_compute_instance" "win-bastion-host" {
  name                        = "${var.bastion_host_win}"
  machine_type                = "${var.bastion_compute_machine_type}"
  zone                        = "${var.bastion_compute_zone}"
  //Assign Firewall tags here
  tags = ["web", "app"]       
  boot_disk {
    initialize_params {
                        image = "${var.bastion_compute_image}"
    }
  }

  network_interface {

    subnetwork            = "${var.bastion_shared_subnet}"
    subnetwork_project    = "${var.host_project}"
    network_ip            = "${var.bastion_internal_ip}"
  }
  metadata = {
    project_name      = "ocean"
    environment       = "shared"
    role              = "bastion-host-windows"
    deparment         = "finance"
    business_owner    = "name of the business owner"
  }
}
/***********************************************************************************************************/
// OpenVPN Server - Windows Server
/***********************************************************************************************************/
/*
This section spins up a Windows VM for hosting OpenVPN Server - with a public IP assigned
*/
/*
First reserve a Static IP to be assigned to this OpenVPN server 
*/
resource "google_compute_address" "ext-ip-for-openvpn-obj" {
                name      = "externalip-for-openvpn-server"
                address_type = "EXTERNAL"
                network_tier = "PREMIUM"
                region    = "${var.compute_region}"
}


resource "google_compute_instance" "win-openvpn-obj" {
  name                        = "${var.openvpn_instance_win}"
  machine_type                = "${var.openvpn_compute_machine_type}"
  zone                        = "${var.openvpn_compute_zone}"
  //Assign Firewall tags here
  tags = ["web", "app"]       
  boot_disk {
    initialize_params {
                        image = "${var.openvpn_compute_image}"
    }
  }

  network_interface {

    subnetwork            = "${var.openvn_shared_subnet}"
    subnetwork_project    = "${var.host_project}"
    access_config {
      nat_ip       = "${google_compute_address.ext-ip-for-openvpn-obj.address}"
      network_tier = "PREMIUM"
    }
  }
  metadata = {
    project_name      = "ocean"
    environment       = "shared"
    role              = "open-vpn-server-windows"
    deparment         = "finance"
    business_owner    = "name of the business owner"
  }
}

/***********************************************************************************************************/
// InfoShare CC app - Windows Server
/***********************************************************************************************************/
resource "google_compute_instance" "win-infoshare-server" {
  name                        = "${var.infoshare_instance_win}"
  machine_type                = "${var.infoshare_compute_machine_type}"
  zone                        = "${var.infoshare_compute_zone}"
  //Assign Firewall tags here
  tags = ["web", "app"]       
  boot_disk {
    initialize_params {
                        image = "${var.infoshare_compute_image}"
    }
  }

  network_interface {

    subnetwork            = "${var.infoshare_shared_subnet}"
    subnetwork_project    = "${var.host_project}"
    network_ip            = "${var.infoshare_internal_ip}"
  }
  metadata = {
    project_name      = "ocean"
    environment       = "shared"
    role              = "infoshae-win-server"
    deparment         = "finance"
    business_owner    = "name of the business owner"
  }
}
