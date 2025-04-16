output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_id" {
  value = aws_eks_cluster.this.id
}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
