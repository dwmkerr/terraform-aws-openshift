//  Define an Amazon Linux AMI.
data "aws_ami" "amazonlinux" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }
}

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
