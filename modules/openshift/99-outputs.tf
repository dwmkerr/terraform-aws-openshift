//  Output some useful variables for quick SSH access etc.
output "master-dns" {
  value = "${aws_instance.master.public_dns}"
}
output "node1-dns" {
  value = "${aws_instance.node1.public_dns}"
}
output "node2-dns" {
  value = "${aws_instance.node2.public_dns}"
}
