/*
***************************************************************************************************************************************
Section name            : Database and BigQuery scripts
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

resource "google_compute_network" "private_sql_network" {
  provider = "google"
  name       = "private-sql-network"
  auto_create_subnetworks = "false"
}
resource "google_compute_subnetwork" "subnet1" {
  name          = "private-sql-network-subnet"
  ip_cidr_range = "10.1.1.0/24"
  network       = "private-sql-network"
  depends_on    = ["google_compute_network.private_sql_network"]
  region        = "asia-east1"
  private_ip_google_access = true
}

/*
This section is for creating a Cloud SQL with private IP enabled
*/
resource "google_compute_global_address" "private_service_sql_ip_address" {
  provider                  = "google"
  name                      = "${var.ip_name}"
  purpose                   = "VPC_PEERING"
  address_type              = "INTERNAL"
  prefix_length             = 16
  network                   = "${google_compute_network.private_sql_network.self_link}"
}
/*
This section is for enabling peering between Google provided VPC and QA VPC(${var.vpc_name})
*/
resource "google_service_networking_connection" "private_sql_vpc_connection" {
  provider                      = "google"
  network                       = "${google_compute_network.private_sql_network.self_link}"
  service                       = "servicenetworking.googleapis.com"
  reserved_peering_ranges       = ["${google_compute_global_address.private_service_sql_ip_address.name}"]
}
/*
This section is for generating a unique name for Cloud SQL to ensure unique DB name. This section can be retained
or removed if do not need random numbers to be used.
Suggested to retain this section duirng ${var.vpc_name}ing process. CloudSQl instance name can't be re-used for 7 days from the
day of deletion.
*/
resource "random_id" "db_name_suffix" {
  byte_length = 4
}
/*
This section creates a Cloud SQL instance in the VPC generated previously(${var.vpc_name}-obj) 
with Private IP and respective authorized networks for establishing connection to the SQL instance.
*/

resource "google_sql_database_instance" "instance" {
  provider              = "google"
  name                  = "private-instance-${random_id.db_name_suffix.hex}"
  region                = "${var.subnet_region}"
  depends_on = [
    "google_service_networking_connection.private_sql_vpc_connection"
  ]
  settings {
    tier = "${var.sql_machine_type}"
    ip_configuration {
      ipv4_enabled = false
     private_network = "${google_compute_network.private_sql_network.self_link}" 
    }
  }
}

/* 
This section creates a BigQuery dataset .
*/

resource "google_bigquery_dataset" "dataset" {
  project                     = "rare-attic-259807"  
  dataset_id                  ="${var.dataset_id}"
  friendly_name               = "${var.bq_friendly_name}"
  description                 = "BigQuery Dataset created for PAH QA environment"
  location                    = "${var.bq_location}"
 // default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }

  access {
    role          = "OWNER"
    user_by_email = "${var.bq_owner_email}"
  }
  access {
    role   = "READER"
    domain = "cognizant.com"
  }
}

/*
This section creates a regional storage bucket_class.
*/
resource "google_storage_bucket" "storage_bucket" {
  project                 = "rare-attic-259807" 
  name                    = "${var.bucket_name}"
  location                = "${var.bucket_location}"
  storage_class           = "${var.bucket_class}"
}
