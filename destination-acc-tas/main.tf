resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket              = var.bucket_name
  object_lock_enabled = false

  tags = {
    Name = "flow-bucket"
  }

}
resource "aws_s3_bucket_policy" "flow_log_policy" {
  bucket = aws_s3_bucket.flow_logs_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": ${var.source_account_id},
                    "s3:x-amz-acl": "bucket-owner-full-control"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:logs:${var.region}:${var.source_account_id}:*"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "s3:GetBucketAcl",
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::flow-logs-bucket-1",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": ${var.source_account_id}
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:logs:${var.region}:${var.source_account_id}:*"
                }
            }
        }
    ]
}
EOF
}

