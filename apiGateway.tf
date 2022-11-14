resource "aws_api_gateway_rest_api" "apiGateway" {
  name        = "${var.app_prefix}-api-gateway"
  description = var.apigw_description
}

resource "aws_api_gateway_resource" "form_score" {
    rest_api_id = aws_api_gateway_rest_api.apiGateway.id
    parent_id   = aws_api_gateway_rest_api.apiGateway.root_resource_id
    path_part   = var.apigw_path_part
}

# resource "aws_api_gateway_request_validator" "validator_query" {
#   name                        = "queryValidator"
#   rest_api_id                 = aws_api_gateway_rest_api.apiGateway.id
#   validate_request_body       = true
#   validate_request_parameters = true
# }

resource "aws_api_gateway_method" "method_form_score" {
    rest_api_id   = aws_api_gateway_rest_api.apiGateway.id
    resource_id   = aws_api_gateway_resource.form_score.id
    http_method   = var.apigw_method
    authorization = var.apigw_authorization
    api_key_required = true

    request_models       = {
       "application/json" = aws_api_gateway_model.my_model.name
        }
  #   request_parameters = {
  #     "method.request.path.proxy"        = false
  #   #  "method.request.querystring.unity" = true
  #     # example of validation: the above requires this in query string
  #     # https://my-api/dev/form-score?unity=1
  # }

  #request_validator_id = aws_api_gateway_request_validator.validator_query.id
}

resource "aws_api_gateway_model" "my_model" {
  rest_api_id  = aws_api_gateway_rest_api.apiGateway.id
  name         =var.apigw_model_name
  description  = var.model_descr
  content_type = var.model_content_type

  schema = <<EOF
  {
  "$schema" : "http://json-schema.org/draft-04/schema#",
  "title" : "validateTheBody",
  "type" : "object",
  "properties" : {
    "message" : { "type" : "string" }
  },
  "required" :["message"]
  }
  EOF
  }

resource "aws_api_gateway_usage_plan" "myusageplan" {
  name = "${var.app_prefix}-usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.apiGateway.id
    stage  = aws_api_gateway_deployment.api.stage_name
  }
}

resource "aws_api_gateway_api_key" "mykey" {
  name = "${var.app_prefix}-key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.mykey.id
  key_type      = var.apigw_key_type
  usage_plan_id = aws_api_gateway_usage_plan.myusageplan.id
}

resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.apiGateway.id
  resource_id             = aws_api_gateway_resource.form_score.id
  http_method             = aws_api_gateway_method.method_form_score.http_method
  type                    = var.integration_type
  integration_http_method = var.apigw_method
  credentials             = aws_iam_role.apiSQS.arn
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${aws_sqs_queue.queue.name}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

 

  depends_on = [
    aws_iam_role_policy_attachment.api_exec_role
  ]
  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}


# Mapping SQS Response
resource "aws_api_gateway_method_response" "http200" {
  rest_api_id = aws_api_gateway_rest_api.apiGateway.id
  resource_id = aws_api_gateway_resource.form_score.id
  http_method = aws_api_gateway_method.method_form_score.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "http200" {
  rest_api_id       = aws_api_gateway_rest_api.apiGateway.id
  resource_id       = aws_api_gateway_resource.form_score.id
  http_method       = aws_api_gateway_method.method_form_score.http_method
  status_code       = aws_api_gateway_method_response.http200.status_code
  selection_pattern = var.selection_pattern                                       // regex pattern for any 200 message that comes back from SQS

  depends_on = [
    aws_api_gateway_integration.api
    ]
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.apiGateway.id
  stage_name  = var.environment

  depends_on = [
    aws_api_gateway_integration.api,
  ]

  # Redeploy when there are new updates
  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_api_gateway_integration.api),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}
