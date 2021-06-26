resource "aws_lambda_function" "image-processor" {
  function_name = "image-processor"
  filename      = "lambdas/image-processor.zip"
  role          = aws_iam_role.lambda-role.arn
  description   = "retrieve image from s3 and process image"

  memory_size                    = 128
  package_type                   = "Zip"
  runtime                        = "nodejs12.x"
  timeout                        = 60
  reserved_concurrent_executions = 10

  handler          = "index.lambda_handler"
  source_code_hash = filebase64sha256("lambdas/image-processor.zip")
}

resource "aws_lambda_permission" "s3-trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image-processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

