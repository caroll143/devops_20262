# ==========================================
# POLICY 1 - S3 READ ONLY
# ==========================================

resource "aws_iam_policy" "s3_read" {
  name        = "${var.ra}-technova-s3-read"
  description = "Permite leitura dos buckets S3 da TechNova"
  tags        = local.common_tags

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "S3ReadOnly"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-*",
          "arn:aws:s3:::technova-*/*"
        ]
      }
    ]
  })
}

# ==========================================
# POLICY 2 - EC2 + S3 FULL
# ==========================================

resource "aws_iam_policy" "ec2_s3_full" {
  name        = "${var.ra}-technova-ec2-s3-full"
  description = "Permite gerenciamento controlado de EC2 e acesso de leitura e escrita ao S3"
  tags        = local.common_tags

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EC2Describe"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeTags"
        ]

        Resource = "*"
      },
      {
        Sid    = "EC2StartStopWithTag"
        Effect = "Allow"

        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]

        Resource = "arn:aws:ec2:*:*:instance/*"

        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" = "TechNova"
          }
        }
      },
      {
        Sid    = "S3ReadWrite"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-*",
          "arn:aws:s3:::technova-*/*"
        ]
      }
    ]
  })
}

# ==========================================
# POLICY 3 - DENY DESTRUCTIVE ACTIONS
# ==========================================

resource "aws_iam_policy" "deny_destructive" {
  name        = "${var.ra}-technova-deny-destructive"
  description = "Impede ações destrutivas como Delete e Terminate"
  tags        = local.common_tags

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyDestructiveActions"
        Effect = "Deny"

        Action = [
          "s3:Delete*",
          "ec2:Terminate*",
          "iam:Delete*"
        ]

        Resource = "*"
      }
    ]
  })
}

# ==========================================
# POLICY ATTACHMENTS
# ==========================================

resource "aws_iam_group_policy_attachment" "developers_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read.arn
}

resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.deny_destructive.arn
}

resource "aws_iam_group_policy_attachment" "platform_ec2_s3_full" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.ec2_s3_full.arn
}