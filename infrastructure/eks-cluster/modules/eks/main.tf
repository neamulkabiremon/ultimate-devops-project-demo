resource "aws_eks_cluster" "this" {
  name     = "${var.env}-${var.eks_name}"
  role_arn = var.cluster_role
  version  = var.eks_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = "${var.env}-${var.eks_name}-eks-cluster"
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.env}-${var.eks_name}-node-group"
  node_role_arn   = var.node_role
  subnet_ids      = var.subnet_ids
  version         = var.eks_version

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]

  labels = {
    role = "general"
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_eks_cluster.this]
}
