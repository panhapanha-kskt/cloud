resource "random_id" "iam_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_app_role-${random_id.iam_suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "ReadOnlyMyAppS3-${random_id.iam_suffix.hex}"
  description = "Read-only access to app S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [ {
      Effect = "Allow",
      Action = ["s3:GetObject"],
      Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_app_profile-${random_id.iam_suffix.hex}"
  role = aws_iam_role.ec2_role.name
}
