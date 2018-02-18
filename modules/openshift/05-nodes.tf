//  Create an SSH keypair
resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

//  Create the master userdata script.
data "template_file" "setup-master" {
  template = "${file("${path.module}/files/setup-master.sh")}"
  vars {
    availability_zone = "${lookup(var.subnetaz, var.region)}"
  }
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_instance" "master" {
  ami                  = "${data.aws_ami.rhel7_2.id}"
  # Master nodes require at least 16GB of memory.
  instance_type        = "m4.xlarge"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-master.rendered}"

  security_groups = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  //  We need at least 30GB for OpenShift, let's be greedy...
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  # Storage for Docker, see:
  # https://docs.openshift.org/latest/install_config/install/host_preparation.html#configuring-docker-storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 80
    volume_type = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "OpenShift Master"
    Project = "openshift"
    // this tag is required for dynamic EBS PVCs
    // see https://github.com/kubernetes/kubernetes/issues/39178
    KubernetesCluster = "openshift-${var.region}"
  }
}

//  Create the node userdata script.
data "template_file" "setup-node" {
  template = "${file("${path.module}/files/setup-node.sh")}"
  vars {
    availability_zone = "${lookup(var.subnetaz, var.region)}"
  }
}

//  Create the two nodes. This would be better as a Launch Configuration and
//  autoscaling group, but I'm keeping it simple...
resource "aws_instance" "node1" {
  ami                  = "${data.aws_ami.rhel7_2.id}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-node.rendered}"

  security_groups = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  //  We need at least 30GB for OpenShift, let's be greedy...
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  # Storage for Docker, see:
  # https://docs.openshift.org/latest/install_config/install/host_preparation.html#configuring-docker-storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 80
    volume_type = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "OpenShift Node 1"
    Project = "openshift"
    KubernetesCluster = "openshift-${var.region}"
  }
}
resource "aws_instance" "node2" {
  ami                  = "${data.aws_ami.rhel7_2.id}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-node.rendered}"

  security_groups = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  //  We need at least 30GB for OpenShift, let's be greedy...
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  # Storage for Docker, see:
  # https://docs.openshift.org/latest/install_config/install/host_preparation.html#configuring-docker-storage
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 80
    volume_type = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  tags {
    Name    = "OpenShift Node 2"
    Project = "openshift"
    KubernetesCluster = "openshift-${var.region}"
  }
}
