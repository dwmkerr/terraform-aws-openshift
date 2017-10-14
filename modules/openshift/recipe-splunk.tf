# This security group allows public ingress on port 8000, which is Splunk's
# management console port.
resource "aws_security_group" "splunk-public-management-ingress" {
  name        = "openshift-public-management-"
  description = "Security group that allows ingress on port 8000"
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "OpenShift Splunk Management Public Access"
    Project = "openshift"
  }
}

//  Create the userdata script.
data "template_file" "setup-splunk" {
  template = "${file("${path.module}/files/setup-splunk.sh")}"

  //  Currently, no vars needed.
}

resource "aws_instance" "splunk" {
  ami                  = "${data.aws_ami.amazonlinux.id}"
  instance_type        = "t2.medium"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  # The profile below provides access to cloudwatch.
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-splunk.rendered}"

  security_groups = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-egress.id}",
    "${aws_security_group.splunk-public-management-ingress.id}",
  ]

  # Give ourselves a bit more space...
  root_block_device {
    volume_size = 50
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "OpenShift Splunk"
    Project = "openshift"
  }
}
