//  Notes: We could make the internal domain a variable, but not sure it is
//  really necessary.

//  Create the internal DNS.
resource "aws_route53_zone" "internal" {
  name = "openshift.local"
  comment = "OpenShift Cluster Internal DNS"
  vpc_id = "${aws_vpc.openshift.id}"
  tags {
    Name    = "OpenShift Internal DNS"
    Project = "openshift"
  }
}

//  Routes for 'master', 'node1' and 'node2'.
resource "aws_route53_record" "master-a-record" {
    zone_id = "${aws_route53_zone.internal.zone_id}"
    name = "master.openshift.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.master.private_ip}"
    ]
}
resource "aws_route53_record" "node1-a-record" {
    zone_id = "${aws_route53_zone.internal.zone_id}"
    name = "node1.openshift.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.node1.private_ip}"
    ]
}
resource "aws_route53_record" "node2-a-record" {
    zone_id = "${aws_route53_zone.internal.zone_id}"
    name = "node2.openshift.local"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.node2.private_ip}"
    ]
}

//  Create the external DNS.
resource "aws_route53_zone" "external" {
  name = "${var.public_domain}"
  comment = "OpenShift Cluster External DNS"

  tags {
    Name    = "OpenShift External DNS"
    Project = "openshift"
  }
}

//  Create a record to hit the master node via 'console.<domain>'.
resource "aws_route53_record" "master-console-a-record" {
    zone_id = "${aws_route53_zone.external.zone_id}"
    name = "console.${var.public_domain}"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.master.public_ip}"
    ]
}

//  Also add a wildcard - this'll be for services etc.
resource "aws_route53_record" "master-wildcard-a-record" {
    zone_id = "${aws_route53_zone.external.zone_id}"
    name = "*.${var.public_domain}"
    type = "A"
    ttl  = 300
    records = [
        "${aws_instance.master.public_ip}"
    ]
}
