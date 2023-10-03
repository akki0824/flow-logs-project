#SOURCE ACCOUNT
resource "aws_iam_role" "flow_log_role_sta" {
  name = "FlowLogRoleSta"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "flow_log_policy_sta" {
  name        = "FlowLogPolicySta"
  description = "IAM policy for publishing flow logs to Amazon S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogDelivery",
          "logs:DeleteLogDelivery"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flow_log_attachment_sta" {
  policy_arn = aws_iam_policy.flow_log_policy_sta.arn
  role       = aws_iam_role.flow_log_role_sta.name
}

resource "aws_vpc" "flow_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "flow_vpc" }


}

resource "aws_flow_log" "flow_log_publish" {
  log_destination      = "arn:aws:s3:::flow-logs-bucket-1/"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.flow_vpc.id
  tags                 = { Name = "flow_log_s3" }
}

resource "aws_internet_gateway" "flow_igw" {
  vpc_id = aws_vpc.flow_vpc.id
  tags   = { Name = "flow-igw" }
}
