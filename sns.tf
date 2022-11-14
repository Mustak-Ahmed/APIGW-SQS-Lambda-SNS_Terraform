resource "aws_sns_topic" "results_updates" {
    name = "${var.app_prefix}-sns"
}

#SNS subscription
# resource "aws_sns_topic_subscription" "results_updates_sqs_target" {
#     topic_arn = "${aws_sns_topic.results_updates.arn}"
#     protocol  = "sqs"
#     endpoint  = "${aws_sqs_queue.queue_deadletter.arn}"
# }
# resource "aws_sns_topic" "sysadmin_alerts" {
#   name            = "sysadmin-alerts-topic"
# }

resource "aws_sns_topic_subscription" "sysadmin_alerts_email_target" {
  topic_arn = aws_sns_topic.results_updates.arn
  protocol  = var.sns_protocol
  endpoint  = var.sns_endpoint
}

