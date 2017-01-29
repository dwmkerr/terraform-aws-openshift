//  Setup the core provider information.
provider "aws" {
  region  = "${var.region}"
}

//  Create the OpenShift cluster using our module.
module "openshift" {
  source          = "./modules/openshift"
  region          = "${var.region}"
  amisize         = "t2.large"    //  Smallest that meets the min specs for OS
  vpc_cidr        = "10.0.0.0/16"
  subnetaz        = "${var.subnetaz}"
  subnet_cidr     = "10.0.1.0/24"
  key_name        = "openshift"
  public_key_path = "${var.public_key_path}"
  public_domain   = "${var.public_domain}"
}

//  Output some useful variables for quick SSH access etc.
output "master-dns" {
  value = "${module.openshift.master-dns}"
}
output "node1-dns" {
  value = "${module.openshift.node1-dns}"
}
output "node2-dns" {
  value = "${module.openshift.node2-dns}"
}
