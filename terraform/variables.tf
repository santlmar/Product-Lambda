variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "jwt_secret" {
  description = "Secreto para JWT"
  type        = string
  sensitive   = true
  default     = "clave_secreta"
}

variable "lambda_zip_path" {
  description = "Ruta al archivo ZIP de la Lambda"
  type        = string
  default     = "lambda.zip"
}

variable "lambda_zip_path_products" {
  description = "Ruta al archivo ZIP de la Lambda"
  type        = string
  default     = "../lambda_products.zip"
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-west-1"
}

variable "lambda_zip_path_auth" {
  description = "Ruta de arhicvo ZIP de la Lambda de autenticación"
  type        = string
  default     = "lambda_auth.zip"
}

variable "lambda_bucket_name" {
  description = "Name of the S3 bucket where Lambda code is stored"
  type        = string
  default     = "ourbucket-ssssy"
}

variable "product_lambda_key" {
  description = "S3 key for the product Lambda function code"
  type        = string
  default     = "lambda_products.zip"
}

variable "user_lambda_key" {
  description = "S3 key for the user Lambda function code"
  type        = string
  default     = "lambda.zip"
}

variable "auth_lambda_key" {
  description = "S3 key for the auth Lambda function code"
  type        = string
  default     = "lambda_auth.zip"
}