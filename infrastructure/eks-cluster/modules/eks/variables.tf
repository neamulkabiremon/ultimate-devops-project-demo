variable "env" {
  type = string
}

variable "eks_name" {
  type = string
}

variable "eks_version" {
  type    = string
  default = "1.30"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "cluster_role" {
  description = "IAM role ARN for the EKS control plane"
  type        = string
}

variable "node_role" {
  description = "IAM role ARN for EKS nodes"
  type        = string
}
