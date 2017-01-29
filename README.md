# terraform-aws-openshift
It's OpenShift, on AWS, handled by Terraform. But it's also WIP, eh?

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
# Create the module.
terraform get

# See what we will create, or do a dry run!
terraform plan

# Create the cluster!
terraform apply
```

You will be asked for a region to deploy in, use `us-east-1` should work fine! You can configure the nuances of how the cluster is created in the [`main.tf`](./main.tf) file. Once created, you will see a message like:

```
$ terraform apply
var.region
  Region to deploy the Consul Cluster into

  Enter a value: ap-southeast-1

...

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.
```

That's it.

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
