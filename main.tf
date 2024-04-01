provider "aws" {
  region = "eu-central-1"  # Set your desired AWS region
}

data "archive_file" "hello_world_handler" {  
  type = "zip"  
  source_file = "${path.module}/lambdas/hello_world_handler/hello_world_handler.py" 
  output_path = "${path.module}/build/hello_world_handler/hello_world_handler.zip"
}

resource "aws_lambda_function" "hello_lambda" {
  function_name = "helloLambda"
  filename      = "${path.module}/build/hello_world_handler/hello_world_handler.zip"
  handler       = "hello_world_handler.lambda_handler" 
  runtime       = "python3.11"
  role          = aws_iam_role.hello_lambda_exec.arn 
}

resource "aws_iam_role" "hello_lambda_exec" {
  name = "hello-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "hello_lambda_policy" {
  role       = aws_iam_role.hello_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_cloudwatch_log_group" "hello" {
  name = "/aws/lambda/${aws_lambda_function.hello_lambda.function_name}"

  retention_in_days = 14
}


resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "lambda_invoke_policy"
  description = "Policy allowing API Gateway to invoke Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "lambda:InvokeFunction",
      Resource  = aws_lambda_function.hello_lambda.arn
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_invoke_attachment" {
  name       = "lambda_invoke_attachment"
  roles      = [aws_iam_role.hello_lambda_exec.name]
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

resource "aws_apigatewayv2_api" "hello_world" {
  name          = "hello_world"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.hello_world.id

  name        = "dev"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.hello_world_api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "hello_world_api_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.hello_world.name}"

  retention_in_days = 14
}

resource "aws_apigatewayv2_integration" "lambda_hello" {
  api_id = aws_apigatewayv2_api.hello_world.id

  integration_uri    = aws_lambda_function.hello_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_hello" {
  api_id = aws_apigatewayv2_api.hello_world.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_hello.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.hello_world.execution_arn}/*/*"
}

output "hello_base_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}