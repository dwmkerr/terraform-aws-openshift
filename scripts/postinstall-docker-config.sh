#!/usr/bin/env bash

# Adjusts the docker configuration. This must be done AFTER the ansible install
# is done, as ansible changes the sysconfig as well (if we do it before ansible,
# then ansible blats it).

# Update the docker config to allow OpenShift's local insecure registry. Also
# use json-file for logging, so our Splunk forwarder can eat the container logs.
# json-file for logging
sudo sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16 --log-driver=json-file --log-opt max-size=1M --log-opt max-file=3"' /etc/sysconfig/docker
sudo systemctl restart docker
