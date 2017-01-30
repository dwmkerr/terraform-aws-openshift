# Fail on errors.
set -x

# Elevate priviledges, retaining the environment.
sudo -E su

# Install dev tools and Ansible 2.2
yum install -y "@Development Tools" python2-pip openssl-devel python-devel gcc libffi-devel
pip install -Iv ansible==2.2.0.0

# Clone the openshift-ansible repo, which contains the installer.
git clone https://github.com/openshift/openshift-ansible

# Run the playbook.
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/byo/config.yml

# If needed, uninstall with the below:
# ansible-playbook playbooks/adhoc/uninstall.yml
