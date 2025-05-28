output "product_api_endpoint" {
  description = "URL del API Gateway para productos"
  value       = "${aws_apigatewayv2_api.product_api.api_endpoint}/products"
}

output "product_table_name" {
  description = "Nombre de la tabla DynamoDB de productos"
  value       = aws_dynamodb_table.product_table.name
}

output "product_lambda_name" {
  description = "Nombre de la función Lambda de productos"
  value       = aws_lambda_function.product_function.function_name
}

output "auth_lambda_name" {
  description = "Nombre de la función Lambda de productos"
  value       = aws_lambda_function.auth_function.function_name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}

output "api_gateway_url" {
  description = "URL pública para invocar la API Gateway"
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/user"
}

output "get_products_api_endpoint" {
  description = "URL del endpoint GET /products"
  value       = "${aws_apigatewayv2_api.product_api.api_endpoint}/products"
}

output "get_products_lambda_arn" {
  description = "ARN de tu función Lambda para obtener productos"
  value       = aws_lambda_function.get_products_function.arn
}

output "get_products_lambda_name" {
  description = "Nombre de tu función Lambda para obtener productos"
  value       = aws_lambda_function.get_products_function.function_name
}