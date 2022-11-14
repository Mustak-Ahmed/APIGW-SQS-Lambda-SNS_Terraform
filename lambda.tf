data "archive_file" "lambda_with_dependencies" {
  source_dir  = "lambda/"
  output_path = "${local.app_name}-${var.lambda_name}.zip"
  type        = "zip"
}

resource "aws_lambda_function" "lambda_sqs" {
  function_name    = "${var.app_prefix}-sqs-lambda"
  handler          = var.lambda_handler
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = var.lambda_runtime

  filename         = data.archive_file.lambda_with_dependencies.output_path
  source_code_hash = data.archive_file.lambda_with_dependencies.output_base64sha256

  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  depends_on = [
    aws_iam_role_policy_attachment.lambda_role_policy
  ]
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
  statement_id  = var.lambda_statement_id
  action        = var.lambda-action
  function_name = aws_lambda_function.lambda_sqs.function_name
  principal     = var.lambda_sqs_principal
  source_arn    = aws_sqs_queue.queue.arn
}

resource "aws_lambda_function_event_invoke_config" "Lambda-async-invoc" {
  function_name = aws_lambda_function.lambda_sqs.function_name
  
  destination_config {
    on_failure {
      destination = aws_sqs_queue.queue.arn
    }
  }
}


#lambda for sqs to sns integration

data "archive_file" "lambda_with_dependencies1" {
  source_dir  = "lambda1/"
  output_path = "${local.app_name}-${var.lambda_name}-sqs-sns.zip"
  type        = "zip"
}

resource "aws_lambda_function" "lambda_sqs_sns" {
  function_name    = "${var.app_prefix}-sqs-sns"
  handler          = var.lambda_handler
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.lambda_runtime
  environment {
    variables = {
    email_topic = aws_sns_topic.results_updates.arn
  }
  }

  filename         = data.archive_file.lambda_with_dependencies1.output_path
  source_code_hash = data.archive_file.lambda_with_dependencies1.output_base64sha256

  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_lambda_permission" "allows_sqs_to_trigger" {
  statement_id  = var.lambda_statement_id
  action        = var.lambda-action
  function_name = aws_lambda_function.lambda_sqs_sns.function_name
  principal     = var.lambda_sqs_principal
  source_arn    = aws_sqs_queue.queue_deadletter.arn
}

resource "aws_lambda_event_source_mapping" "event_source_mapping1" {
  event_source_arn = aws_sqs_queue.queue_deadletter.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_sqs_sns.function_name
  batch_size       = 1
}

# resource "aws_lambda_function_event_invoke_config" "lambda_event_invoke_config" {
#   function_name = aws_lambda_function.lambda_sqs_sns.function_name

#   destination_config {
#     on_success {
#       destination = aws_sns_topic.results_updates.arn
#     }
#   }
# }
resource "aws_iam_role" "lambda_role" {
name   = "${var.app_prefix}-iam-role-sqs-sns"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
resource "aws_iam_policy" "iam_policy_for_lambda1" {
 
 name         = "${var.app_prefix}-iam-policy-sqs-sns"
 path         = "/"
 description  = var.lambda_policy_desc
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
   {
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.queue_deadletter.arn}"
   },
   {
    "Effect": "Allow",
    "Action": "sns:*",
    "Resource":  "${aws_sns_topic.results_updates.arn}"
   }
 ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda1.arn
}


