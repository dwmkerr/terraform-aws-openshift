//  Output some useful variables for quick SSH access etc.
output "master-public_dns" {
  value = "${aws_instance.master.public_dns}"
}
output "master-public_ip" {
  value = "${aws_instance.master.public_ip}"
}
output "master-private_dns" {
  value = "${aws_instance.master.private_dns}"
}
output "master-private_ip" {
  value = "${aws_instance.master.private_ip}"
}

output "node1-public_dns" {
  value = "${aws_instance.node1.public_dns}"
}
output "node1-public_ip" {
  value = "${aws_instance.node1.public_ip}"
}
output "node1-private_dns" {
  value = "${aws_instance.node1.private_dns}"
}
output "node1-private_ip" {
  value = "${aws_instance.node1.private_ip}"
}

output "node2-public_dns" {
  value = "${aws_instance.node2.public_dns}"
}
output "node2-public_ip" {
  value = "${aws_instance.node2.public_ip}"
}
output "node2-private_dns" {
  value = "${aws_instance.node2.private_dns}"
}
output "node2-private_ip" {
  value = "${aws_instance.node2.private_ip}"
}

output "bastion-public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}
output "bastion-public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
output "bastion-private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}
output "bastion-private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}
