########################################
#           PROVIDER & TERRAFORM       #
########################################

provider "aws" {
  region     = var.aws_region
  access_key = "AKIAZVAIZ3CVZ7K7YIE7"
  secret_key = "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"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
  }
}

########################################
#           DYNAMODB TABLES            #
########################################

# Tabla DynamoDB: Productos
resource "aws_dynamodb_table" "product_table" {
  name         = "products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"
  range_key    = "name"

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "NameIndex"
    hash_key        = "name"
    projection_type = "ALL"
  }

  tags = {
    Environment = var.environment
  }
}

# Tabla DynamoDB: Usuarios
resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"
  range_key    = "email"

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name               = "email"
    hash_key           = "email"
    projection_type    = "ALL"
  }
}

########################################
#           IAM ROLES & POLICIES       #
########################################

# IAM para productos
resource "aws_iam_role" "product_lambda_role" {
  name = "product-lambda-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "product_dynamodb_policy" {
  name = "product-dynamodb-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query"
      ],
      Resource = [
        aws_dynamodb_table.product_table.arn,
        "${aws_dynamodb_table.product_table.arn}/index/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "product_dynamodb_attach" {
  role       = aws_iam_role.product_lambda_role.name
  policy_arn = aws_iam_policy.product_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "product_lambda_basic" {
  role       = aws_iam_role.product_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM para usuarios
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "dynamodb_put" {
  name        = "dynamodb-put-policy"
  description = "Allow Lambda to put items in DynamoDB"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:PutItem"]
      Resource = aws_dynamodb_table.users.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_put" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_put.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kms_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::663590918315:policy/lambda-kms-policy"
}

resource "aws_iam_policy" "lambda_kms_policy" {
  name        = "lambda-kms-policy"
  description = "Allow Lambda to decrypt environment variables using KMS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*"
      ],
      Resource = "*"
    }]
  })
}

# IAM para autenticación
resource "aws_iam_role" "auth_lambda_role" {
  name = "auth-lambda-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "auth_dynamodb_policy" {
  name = "auth-dynamodb-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        Resource = [
          aws_dynamodb_table.users.arn,
          "${aws_dynamodb_table.users.arn}/index/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "auth_dynamodb_attach" {
  role       = aws_iam_role.auth_lambda_role.name
  policy_arn = aws_iam_policy.auth_dynamodb_policy.arn
}

########################################
#           LAMBDAS                    #
########################################

resource "aws_lambda_function" "product_function" {
  function_name = "ProductCreate"
  handler       = "dist/main.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.product_lambda_role.arn
  s3_bucket     = var.lambda_bucket_name
  s3_key        = "lambda_products.zip"

  environment {
    variables = {
      JWT_SECRET     = var.jwt_secret
      PRODUCTS_TABLE = "products"
    }
  }
}

resource "aws_lambda_function" "get_products_function" {
  function_name    = "GetProducts"
  handler          = "dist/main.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.product_lambda_role.arn
  s3_bucket        = var.lambda_bucket_name
  s3_key           = "lambda_zip_get_products.zip"

  environment {
    variables = {
      PRODUCTS_TABLE = aws_dynamodb_table.product_table.name
    }
  }
}

resource "aws_lambda_function" "user_register" {
  function_name = "user_register"
  handler       = "dist/infrastructure/lambda/userRegisterHandler.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  s3_bucket     = var.lambda_bucket_name
  s3_key        = "lambda.zip"
  kms_key_arn   = "arn:aws:kms:us-west-1:663590918315:key/ccf8d3cd-3022-4c73-a746-1cf068096fa4"

  environment {
    variables = {
      USERS_TABLE = aws_dynamodb_table.users.name
    }
  }
}

resource "aws_lambda_function" "auth_function" {
  function_name = "auth_function"
  handler       = "dist/main.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.auth_lambda_role.arn
  s3_bucket     = var.lambda_bucket_name
  s3_key        = "lambda_auth.zip"

  environment {
    variables = {
      AUTH_TABLE = aws_dynamodb_table.users.name
    }
  }
}

########################################
#           API GATEWAY: PRODUCTOS     #
########################################

resource "aws_apigatewayv2_api" "product_api" {
  name          = "ProductAPI-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "product_lambda_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.product_function.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "product_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "POST /products"
  target    = "integrations/${aws_apigatewayv2_integration.product_lambda_integration.id}"
}

resource "aws_lambda_permission" "product_api_permission" {
  statement_id  = "AllowProductAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "product_stage" {
  api_id      = aws_apigatewayv2_api.product_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "get_products_integration" {
  api_id             = aws_apigatewayv2_api.product_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.get_products_function.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_products_route" {
  api_id    = aws_apigatewayv2_api.product_api.id
  route_key = "GET /products"
  target    = "integrations/${aws_apigatewayv2_integration.get_products_integration.id}"
}

resource "aws_lambda_permission" "get_products_api_permission" {
  statement_id  = "AllowGetProductsAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_products_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.product_api.execution_arn}/*/*"
}

########################################
#           API GATEWAY: USUARIOS      #
########################################

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "user-register-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.lambda_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.user_register.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "user_post_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /user"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_register.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

########################################
#           API GATEWAY: AUTENTICACIÓN #
########################################

resource "aws_apigatewayv2_api" "auth_api" {
  name          = "auth-api"
  protocol_type = "HTTP"
  description   = "API para autenticación"
}

resource "aws_apigatewayv2_integration" "auth_integration" {
  api_id                 = aws_apigatewayv2_api.auth_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth_function.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_login_route" {
  api_id    = aws_apigatewayv2_api.auth_api.id
  route_key = "POST /auth/login"  # Debe coincidir EXACTAMENTE con tu @Post() en NestJS
  target    = "integrations/${aws_apigatewayv2_integration.auth_integration.id}"
}

resource "aws_apigatewayv2_route" "root_route" {
  api_id    = aws_apigatewayv2_api.auth_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.auth_integration.id}"
}

resource "aws_lambda_permission" "auth_api_permission" {
  statement_id  = "AllowAuthAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.auth_api.execution_arn}/*/*"
}