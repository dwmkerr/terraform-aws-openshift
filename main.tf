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
output "master-public_dns" {
  value = "${module.openshift.master-public_dns}"
}
output "master-public_ip" {
  value = "${module.openshift.master-public_ip}"
}
output "master-private_dns" {
  value = "${module.openshift.master-private_dns}"
}
output "master-private_ip" {
  value = "${module.openshift.master-private_ip}"
}

output "node1-public_dns" {
  value = "${module.openshift.node1-public_dns}"
}
output "node1-public_ip" {
  value = "${module.openshift.node1-public_ip}"
}
output "node1-private_dns" {
  value = "${module.openshift.node1-private_dns}"
}
output "node1-private_ip" {
  value = "${module.openshift.node1-private_ip}"
}

output "node2-public_dns" {
  value = "${module.openshift.node2-public_dns}"
}
output "node2-public_ip" {
  value = "${module.openshift.node2-public_ip}"
}
output "node2-private_dns" {
  value = "${module.openshift.node2-private_dns}"
}
output "node2-private_ip" {
  value = "${module.openshift.node2-private_ip}"
}

output "bastion-public_dns" {
  value = "${module.openshift.bastion-public_dns}"
}
output "bastion-public_ip" {
  value = "${module.openshift.bastion-public_ip}"
}
output "bastion-private_dns" {
  value = "${module.openshift.bastion-private_dns}"
}
output "bastion-private_ip" {
  value = "${module.openshift.bastion-private_ip}"
}
