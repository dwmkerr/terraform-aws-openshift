infrastructure:
	# Get the modules, create the infrastructure.
	terraform get && terraform apply

# Installs OpenShift on the cluster.
openshift:
	ssh-add ~/.ssh/id_rsa

	# Create our inventory from the template and terraform output. 
	sed "s/\$${aws_instance.master.public_ip}/$$(terraform output master-public_ip)/" inventory.template.cfg > inventory.cfg
	
	# Copy the inventory to the bastion.
	scp ./inventory.cfg ec2-user@$$(terraform output bastion-public_dns):~
	
	# Run the installer on the bastion.
	cat install-from-bastion.sh | ssh -o StrictHostKeyChecking=no -A ec2-user@$$(terraform output bastion-public_dns)

# Open the console.
open:
	open $$(terraform output master-url)

# SSH onto the master.
ssh-master:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local

# Create sample services.
sample:
	oc process -f ./sample/counter-service.yml | oc create -f - 

# Setup splunk.
splunk:
	sed "s/\$${SPLUNK_FORWARD_SERVER}/$$(terraform output splunk-private_ip)/" ./recipes/splunk/splunk-forwarder.template.yml | ssh -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local oc create -f -
	
	# Create the splunk template with the forwarder ip. Create it on the master.
	# oc process -v SPLUNK_FORWARD_SERVER=$$(terraform output splunk-private_ip) -f ./recipes/splunk/splunk-forwarder.template.yml \
		# | ssh -t -A ec2-user@$$(terraform output bastion-public_dns) \
		# ssh master.openshift.local oc create -f - 

.PHONY: sample
