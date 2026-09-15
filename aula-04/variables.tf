variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "TechNova"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "development"
}

variable "owner" {
  description = "RA do aluno"
  type        = string
  default     = "3925000"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDRs das sub-redes públicas"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das sub-redes privadas"
  type        = list(string)
  default = [
    "10.0.2.0/24",
    "10.0.4.0/24"
  ]
}