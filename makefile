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
	ssh -t -A -o StrictHostKeyChecking=no ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local

# Setup splunk.
splunk:
	cat oc process -v SPLUNK_FORWARD_SERVER=$$(terraform output splunk-private_ip) | ssh -t -A -o StrictHostKeyChecking=no ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local oc create -f
