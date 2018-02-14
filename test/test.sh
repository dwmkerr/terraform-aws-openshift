#!/usr/bin/env bash
set -x
set -e

# This script is designed to be run locally or from a CI environment to test the
# project. It should:
#
# 1. Create the infrastructure
# 2. Install OpenShift
# 3. Test OpenShift
# 4. Tear down the infrastructure
# 5. Report overall success or failure.

# Grab the parameters we need.
keypath=$1

# Initialise terraform.
terraform init && terraform get

# Create the infrastructure, setting our key path.
export TF_VAR_public_key_path="${keypath}"
terraform apply -auto-approve

# Install OpenShift.
make openshift

