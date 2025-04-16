# -----------------------------
# VPC / Networking Module
# -----------------------------
module "network" {
  source    = "./modules/network"
  env       = var.env
  region    = var.region
  zone1     = var.zone1
  zone2     = var.zone2
  vpc_cidr  = "10.0.0.0/16"
  eks_name  = var.eks_name
}

# -----------------------------
# IAM Module
# -----------------------------
module "iam" {
  source    = "./modules/iam"
  env       = var.env
  eks_name  = var.eks_name
}

# -----------------------------
# EKS Module
# -----------------------------
module "eks" {
  source       = "./modules/eks"
  env          = var.env
  eks_name     = var.eks_name
  eks_version  = "1.30"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
  cluster_role = module.iam.eks_cluster_role_arn
  node_role    = module.iam.eks_node_role_arn
}

# -----------------------------
# Wait for EKS to be Ready
# -----------------------------
resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "echo 'Waiting for the EKS cluster to be ready...'"
  }

  depends_on = [module.eks]
}

# -----------------------------
# OIDC Provider
# -----------------------------
resource "aws_iam_openid_connect_provider" "oidc" {
  url             = module.eks.oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd40f78"]
  depends_on      = [null_resource.wait_for_cluster] # optional, but useful
}

# -----------------------------
# Addons Module (Helm, Metrics, LBC, etc.)
# -----------------------------
module "addons" {
  source         = "./modules/addons"
  cluster_name   = module.eks.cluster_name
  cluster_region = var.region
  vpc_id         = module.network.vpc_id

  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  depends_on = [null_resource.wait_for_cluster]
}

# -----------------------------
# Storage Module (EFS, EBS, CSI)
# -----------------------------
# module "storage" {
#   source         = "./modules/storage"
#   cluster_name   = module.eks.cluster_name
#   subnet_ids     = module.network.private_subnet_ids
#   cluster_sg_id  = data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
#   oidc_url       = module.eks.oidc_url
#   oidc_arn       = aws_iam_openid_connect_provider.oidc.arn

#   providers = {
#     helm       = helm.eks
#     kubernetes = kubernetes.eks
#   }

#   depends_on = [module.addons]
# }