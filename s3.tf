resource "aws_s3_bucket" "source" {
  bucket        = "${var.project}-${var.environment}-source"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "lambda-trigger" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image-processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3-trigger]
}
