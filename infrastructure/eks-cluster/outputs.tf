output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# output "efs_id" {
#   value = module.storage.efs_id
# }

output "oidc_url" {
  value = module.eks.oidc_url
}
