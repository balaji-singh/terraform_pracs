
provider "aws" {
  #profile    = "default"
  region     = "us-west-1"
  access_key = "AKIARUFL5R6QP2PYGJ24"
  secret_key = "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"

}

/*resource "aws_route53_zone" "terraform-prac" {
  name = "terraform-prac.allianz.at"

}
*/


resource "aws_route53_record" "server1-record" {
   zone_id="Z07696633PDJ0QVN7Y4G3"
  name    = "*abs"
  type    = "CNAME"
  ttl     = "30"
  records = ["*.abs-drperf.allianz"]
  allow_overwrite = true
}


