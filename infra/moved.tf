# Preserves existing state across the flap1.com -> shoichiseto.com
# re-architecture, so the already-delegated flap1.com hosted zone (and its
# records) get renamed/repointed in place instead of destroyed and recreated.

moved {
  from = aws_route53_zone.main
  to   = aws_route53_zone.redirect
}

moved {
  from = aws_route53_record.root
  to   = aws_route53_record.redirect_root
}

moved {
  from = aws_route53_record.root_aaaa
  to   = aws_route53_record.redirect_root_aaaa
}

moved {
  from = aws_route53_record.www
  to   = aws_route53_record.redirect_www
}

moved {
  from = aws_route53_record.www_aaaa
  to   = aws_route53_record.redirect_www_aaaa
}
