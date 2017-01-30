# terraform-aws-openshift

This project shows you how to set up OpenShift Origin on AWS using Terraform.

## Overview

Terraform is used to create infrastructure as shown:

![Network Diagram](./docs/network-diagram.png)

Once the infrastructure is set up, a single command is used to install the OpenShift platform on the hosts.

## Prerequisites

Please install the following components:

1. [Terraform](https://www.terraform.io/intro/getting-started/install.html) - `brew update && brew install terraform`.

You must also have an AWS account. Be aware that a number of paid resources are required - some EC2 instances, hosted zones etc.

You will need to set up your AWS credentials. The preferred way is to install the AWS CLI and quickly run `aws configure`:

```
$ aws configure
AWS Access Key ID [None]: <Enter Access Key ID>
AWS Secret Access Key [None]: <Enter Secret Key>
Default region name [None]: ap-southeast-1
Default output format [None]:
```

This will keep your AWS credentials in the `$HOME/.aws/credentials` file, which Terraform can use. This and all other options are documented in the [Terraform: AWS Provider](https://www.terraform.io/docs/providers/aws/index.html) documentation.

## Creating the Cluster

The cluster is implemented as a [Terraform Module](https://www.terraform.io/docs/modules/index.html). To launch, just run:

```bash
# Get the modules, create the infrastructure.
terraform get && terraform apply
```

You will be asked for a region to deploy in, use `us-east-1` or your preferred region. You can configure the nuances of how the cluster is created in the [`main.tf`](./main.tf) file. Once created, you will see a message like:

```
$ terraform apply
var.region
  Region to deploy the Consul Cluster into

  Enter a value: ap-southeast-1

...

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.
```

That's it! The infrastructure is ready and you can install OpenShift.

## Installing OpenShift

Make sure you have your local identity added:

```
$ ssh-add ~/.ssh/id_rsa
```

Then just run the install script on the bastion:

```
$ cat install-from-bastion.sh | ssh -A ec2-user@$(terraform output bastion-public_dns)
```

It will take about 20 minutes:

TODO screenshot

Open it by hitting port 8443 of the master node:

```bash
open "https://$(terraform output master-public_dns):8443"
```

TODO screenshot

## Additional Configuration

Access the master or nodes to update configuration and add feature as needed:

```
$ ssh -A ec2-user@$(terraform output bastion-public_dns)
$ ssh -A master.openshift.local
$ sudo su
$ oc get nodes
NAME                     STATUS    AGE
master.openshift.local   Ready     1h
node1.openshift.local    Ready     1h
node2.openshift.local    Ready     1h
```

## Destroying the Cluster

Bring everything down with:

```
terraform destroy
```

## Pricing

You'll be paying for:

- 3x t2.large instances

## References

 - https://www.udemy.com/openshift-enterprise-installation-and-configuration - The basic structure of the network is based on this course.
 - https://blog.openshift.com/openshift-container-platform-reference-architecture-implementation-guides/ - Detailed guide on high available solutions, including production grade AWS setup.
 - https://access.redhat.com/sites/default/files/attachments/ocp-on-gce-3.pdf - Some useful info on using the bastion for installation.

## TODO

- [ ] Consider whether it is needed to script elastic IPs for the instances and DNS.
- [ ] Consider documenting public DNS setup.
- [ ] Consider moving the nodes into a private subnet.
