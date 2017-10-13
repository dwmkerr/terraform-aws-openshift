
//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_instance" "bastion" {
  ami                  = "${data.aws_ami.amazonlinux.id}"
  instance_type        = "t2.micro"
  subnet_id            = "${aws_subnet.public-subnet.id}"

  security_groups = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-ssh.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "OpenShift Bastion"
    Project = "openshift"
  }
}
