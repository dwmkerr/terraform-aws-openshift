data "template_file" "inventory" {
  template = "${file("${path.cwd}/inventory.template.cfg")}"
  vars {
    access_key = "${aws_iam_access_key.openshift-aws-user.id}"
    secret_key = "${aws_iam_access_key.openshift-aws-user.secret}"
    public_hostname = "${aws_instance.master.public_ip}.xip.io"
    master_inventory = "${aws_instance.master.private_dns}"
    node_inventory = <<EOF
${aws_instance.master.private_dns} openshift_node_labels="{'region': 'infra', 'zone': 'default'}" openshift_schedulable=true
${aws_instance.node1.private_dns} openshift_node_labels="{'region': 'primary', 'zone': 'east'}"
${aws_instance.node2.private_dns} openshift_node_labels="{'region': 'primary', 'zone': 'west'}"
EOF
  }
}

resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/inventory.cfg"
}
