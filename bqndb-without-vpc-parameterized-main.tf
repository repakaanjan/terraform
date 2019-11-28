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

/*
This section is for creating a Cloud SQL with private IP enabled
*/
resource "google_compute_global_address" "private_service_sql_ip_address" {
  provider                  = "google"
  name                      = "${var.ip_name}"
  purpose                   = "VPC_PEERING"
  address_type              = "INTERNAL"
  prefix_length             = 16
  network                   = "projects/${var.gcp_project_id}/global/networks/${var.vpc_name}"
}
/*
This section is for enabling peering between Google provided VPC and QA VPC(svpc-petsathome-qa)
*/
resource "google_service_networking_connection" "private_sql_vpc_connection" {
  provider                      = "google"
  network                       = "projects/${var.gcp_project_id}/global/networks/${var.vpc_name}"  
  service                       = "servicenetworking.googleapis.com"
  reserved_peering_ranges       = ["${google_compute_global_address.private_service_sql_ip_address.name}"]
}
/*
This section is for generating a unique name for Cloud SQL to ensure unique DB name. This section can be retained
or removed if do not need random numbers to be used.
Suggested to retain this section duirng testing process. CloudSQl instance name can't be re-used for 7 days from the
day of deletion.
*/
resource "random_id" "db_name_suffix" {
  byte_length = 4
}
/*
This section creates a Cloud SQL instance in the VPC generated previously(svpc-petsathome-qa-obj) 
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
      private_network = "projects/${var.gcp_project_id}/global/networks/${var.vpc_name}"
      
    }
  }
}

/* 
This section creates a BigQuery dataset .
*/

resource "google_bigquery_dataset" "dataset" {
  project                     = "${var.gcp_project_id}"  
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
  project                 = var.gcp_project_id 
  name                    = "${var.bucket_name}"
  location                = "${var.bucket_location}"
  storage_class           = "${var.bucket_class}"
}
