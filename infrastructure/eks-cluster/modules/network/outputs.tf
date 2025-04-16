variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "zone1" {
  type = string
}

variable "zone2" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "eks_name" {
  type = string
}
