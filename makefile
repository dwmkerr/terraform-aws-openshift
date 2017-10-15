infrastructure:
	# Get the modules, create the infrastructure.
	terraform get && terraform apply

# Installs OpenShift on the cluster.
openshift:
	# Add our identity for ssh, add the host key to avoid having to accept the
	# the host key manually. Also add the identity of each node to the bastion.
	ssh-add ~/.ssh/id_rsa
	ssh-keyscan -t rsa -H $$(terraform output bastion-public_dns) >> ~/.ssh/known_hosts
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H master.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H node1.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H node2.openshift.local >> ~/.ssh/known_hosts"

	## Create our inventory from the template and terraform output. 
	sed "s/\$${aws_instance.master.public_ip}/$$(terraform output master-public_ip)/" inventory.template.cfg > inventory.cfg
	
	## Copy the inventory to the bastion, run the installer.
	scp ./inventory.cfg ec2-user@$$(terraform output bastion-public_dns):~
	cat install-from-bastion.sh | ssh -A ec2-user@$$(terraform output bastion-public_dns)

	# Now the installer is done, run the postinstall steps on each host.
	cat ./scripts/postinstall-docker-config.sh | ssh -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local
	cat ./scripts/postinstall-docker-config.sh | ssh -A ec2-user@$$(terraform output bastion-public_dns) ssh node1.openshift.local
	cat ./scripts/postinstall-docker-config.sh | ssh -A ec2-user@$$(terraform output bastion-public_dns) ssh node2.openshift.local

# Open the console.
browse-openshift:
	open $$(terraform output master-url)
browse-splunk:
	open $$(terraform output splunk-console-url)

# SSH onto the master.
ssh-bastion:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns)
ssh-master:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local
ssh-node1:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh node1.openshift.local
ssh-node2:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh node2.openshift.local

# Create sample services.
sample:
	oc login $(terraform output master-url) --insecure-skip-tls-verify=true -u=admin -p=123
	oc new-project sample
	oc process -f ./sample/counter-service.yml | oc create -f - 

# Setup splunk.
splunk:
	cat ./recipes/splunk/setup-cluster.sh | ssh -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local
	sed "s/\$${SPLUNK_FORWARD_SERVER}/$$(terraform output splunk-private_ip)/" ./recipes/splunk/splunk-forwarder.template.yml | ssh -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local oc create -f -

.PHONY: sample
