resource "aws_cloudwatch_event_rule" "search_reporter_rule" {
  name                = "search_reporter_rule"
  description         = "Starts the search reporter lambda"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_lambda_permission" "allow_cloudwatch_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = module.search_reporter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.search_reporter_rule.arn
}

resource "aws_cloudwatch_event_target" "event_trigger" {
  rule = aws_cloudwatch_event_rule.search_reporter_rule.id
  arn  = module.search_reporter.arn
}
