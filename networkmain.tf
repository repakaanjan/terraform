/*
***************************************************************************************************************************************
Script for              : To create network services. VPCs, subnets etc.
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
/*
To create a VPC which will be shared with the QA project - subsequent steps will add the required subnets to this VPC
VPC name to be provided as a parameter
*/
resource "google_compute_network" "svpc-petsathome-qa-obj" {
  provider                = "google"
  name                    = "${var.vpc_name}"
  auto_create_subnetworks = "false"
}
/*
Creating a new subnet (petsathome-qa-subnet-app) in the previously created VPC for QA environment - 
This subnet is for keeping all the app related services.  Subnet name to be provided as a parameter.
*/
resource "google_compute_subnetwork" "petsathome-qa-subnet-app-obj" {
  name                      = "${var.app_subnet_name}"
  ip_cidr_range             = "${var.app_subnet_cidr}" 
  network                   = "${var.vpc_name}"
  depends_on                = ["google_compute_network.svpc-petsathome-qa-obj"]
  region                    = "${var.subnet_region}"
  private_ip_google_access  = true
}
/*
Creating a new subnet (petsathome-qa-subnet-db) in the previously created VPC for QA environment - 
This subnet is for keeping all the db related services.  Subnet name to be provided as a parameter.
*/
resource "google_compute_subnetwork" "petsathome-qa-subnet-db-obj" {
  name                      = "${var.db_subnet_name}"
  ip_cidr_range             = "${var.db_subnet_cidr}"
  network                   = "${var.vpc_name}"
  depends_on                = ["google_compute_network.svpc-petsathome-qa-obj"]
  region                    = "${var.subnet_region}"
  private_ip_google_access  = true
}

/*
Creating a new subnet (petsathome-qa-subnet-host) in the previously created VPC for QA environment - 
This subnet is for keeping all the common shared services. Subnet name to be provided as a parameter.
*/
resource "google_compute_subnetwork" "petsathome-qa-subnet-host-obj" {
  name                      = "${var.host_subnet_name}"
  ip_cidr_range             = "${var.host_subnet_cidr}"
  network                   = "${var.vpc_name}"
  depends_on                = ["google_compute_network.svpc-petsathome-qa-obj"]
  region                    = "${var.subnet_region}"
  private_ip_google_access  = true
}

/*
Creating a new subnet (petsathome-qa-subnet-identity) in the previously created VPC for QA environment - 
This subnet is for keeping identity related services. Subnet name to be provided as a parameter.
*/
resource "google_compute_subnetwork" "petsathome-qa-subnet-identity-obj" {
  name                      = "${var.identity_subnet_name}"
  ip_cidr_range             = "${var.identity_subnet_cidr}"
  network                   = "${var.vpc_name}"
  depends_on                = ["google_compute_network.svpc-petsathome-qa-obj"]
  region                    = "${var.subnet_region}"
  private_ip_google_access  = true
}
