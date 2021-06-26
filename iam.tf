resource "aws_iam_role" "lambda-role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda-policy" {
  name = "lambda-policy"
  role = aws_iam_role.lambda-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObjectTagging",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.source.arn}/*",
        ]
      },
      {
        Action = [
          "rekognition:DetectLabels"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-logs" {
  role       = aws_iam_role.lambda-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
