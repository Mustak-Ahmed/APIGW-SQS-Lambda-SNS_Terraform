resource "aws_sqs_queue" "queue" {
  name                      = "${var.app_prefix}-sqs"
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
     redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter.arn,
    maxReceiveCount     = 10
    
  })

  tags = {
    Product = local.app_name
  }
}


# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn =  aws_sqs_queue.queue.arn
  enabled          = true
  function_name    =  aws_lambda_function.lambda_sqs.arn
}
# Dead letter queuee creation
resource "aws_sqs_queue" "queue_deadletter" {
  name = "${var.app_prefix}-deadletter-queuee"
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  
}
