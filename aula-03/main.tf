locals {
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Aluno       = var.aluno
    RA          = var.ra
    Disciplina  = var.disciplina
    Aula        = var.aula
    Environment = var.environment
  }
}

# =========================
# IAM GROUPS
# =========================

resource "aws_iam_group" "developers" {
  name = "${var.ra}-technova-developers"
}

resource "aws_iam_group" "platform_eng" {
  name = "${var.ra}-technova-platform-eng"
}

# =========================
# IAM USERS
# =========================

resource "aws_iam_user" "juliana_dev" {
  name = "${var.ra}-juliana-dev"

  tags = local.common_tags
}

resource "aws_iam_user" "rafael_platform" {
  name = "${var.ra}-rafael-platform"

  tags = local.common_tags
}

resource "aws_iam_user" "lucas_intern" {
  name = "${var.ra}-lucas-intern"

  tags = local.common_tags
}

# =========================
# GROUP MEMBERSHIPS
# =========================

resource "aws_iam_user_group_membership" "juliana_dev" {
  user = aws_iam_user.juliana_dev.name

  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "rafael_platform" {
  user = aws_iam_user.rafael_platform.name

  groups = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

resource "aws_iam_user_group_membership" "lucas_intern" {
  user = aws_iam_user.lucas_intern.name

  groups = [
    aws_iam_group.developers.name
  ]
}