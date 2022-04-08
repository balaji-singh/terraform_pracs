
provider "aws" {
  #profile    = "default"
  region     = "us-west-1"

}

resource "aws_route53_zone" "terraform-prac" {
  name = "terraform-prac.allianz.at"
}


resource "aws_route53_record" "server1-record" {
  zone_id = "${aws_route53_zone.terraform-prac.zone_id}"
  name    = "*abs"
  type    = "CNAME"
  ttl     = "30"
  records = ["104.236.247.8"]
}


