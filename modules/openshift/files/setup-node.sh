#!/usr/bin/env bash

# This script template is expected to be populated during the setup of a
# OpenShift  node. It runs on host startup.

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

# Create a folder to hold our AWS logs config.
# mkdir -p /var/awslogs/etc

# Download and run the AWS logs agent.
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
python ./awslogs-agent-setup.py --non-interactive --region us-east-1 -c /var/awslogs/etc/awslogs.conf

# Create a the awslogs config.
cat >> /var/awslogs/etc/awslogs.conf <<- EOF
[/var/log/user-data.log]
file = /var/log/user-data.log
log_group_name = /var/log/user-data.log
log_stream_name = {instance_id}
EOF

# Start the awslogs service, also start on reboot.
# Note: Errors go to /var/log/awslogs.log
service awslogs restart
chkconfig awslogs on

# OpenShift setup
# See: https://docs.openshift.org/latest/install_config/install/host_preparation.html

# Install packages required to setup OpenShift.
yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion
yum update -y

# Note: The step below is not in the official docs, I needed it to install
# Docker. If anyone finds out why, I'd love to know.
# See: https://forums.aws.amazon.com/thread.jspa?messageID=574126
yum-config-manager --enable rhui-REGION-rhel-server-extras

# Docker setup. Check the version with `docker version`, should be 1.12.
yum install -y docker

# Update the docker config to allow OpenShift's local insecure registry.
sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16 --log-opt max-size=1M --log-opt max-file=3"' \
/etc/sysconfig/docker
systemctl restart docker

# Note we are not configuring Docker storage as per the guide.
