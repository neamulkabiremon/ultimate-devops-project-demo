variable "env" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "zone1" {
  description = "First Availability Zone"
  type        = string
}

variable "zone2" {
  description = "Second Availability Zone"
  type        = string
}

variable "eks_name" {
  description = "Name of the EKS cluster"
  type        = string
}
