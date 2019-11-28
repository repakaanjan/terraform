when using 3 different scripts run network script first then compute script and then storage
delete them in reverse order
keep all script related files for each stack in a different directory
run terraform apply in each directory

Initially BigQuery and Cloud SQL services were configured to be created along with a different VPC in the same script 
but now there exists an another script which related the Cloud SQL instance to the network created by network script 
so no need to create a new vpc along with storage stack 
