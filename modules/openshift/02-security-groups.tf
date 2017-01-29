//  This is not the best way to handle security groups for an OpenShift cluster,
//  as the various different needs are bundled into one security group. However
//  this suffices for a simple demo.
//  IMPORTANT: This is *not* production ready. SSH access is allowed to all
//  instances from anywhere.

resource "aws_security_group" "openshift-vpc" {
  name        = "openshift-vpc"
  description = "Default security group that allows all instances in the VPC to talk to each other over any port and protocol."
  vpc_id      = "${aws_vpc.openshift.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags {
    Name    = "OpenShift Internal VPC"
    Project = "openshift"
  }
}

//  This security group allows public access to the instances for HTTP, HTTPS
//  common HTTP/S proxy ports and SSH.
resource "aws_security_group" "openshift-public-access" {
  name        = "openshift-public-access"
  description = "Security group that allows public access to instances, HTTP, HTTPS, SSH and more."
  vpc_id      = "${aws_vpc.openshift.id}"

  //  HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTP Proxy
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS Proxy
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "OpenShift Public Access"
    Project = "openshift"
  }
}
