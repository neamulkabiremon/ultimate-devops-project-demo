# # -----------------------------
# # EBS CSI DRIVER (addon-based)
# # -----------------------------
# resource "aws_iam_role" "ebs_csi" {
#   name = "${var.cluster_name}-ebs-csi-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "pods.eks.amazonaws.com"
#       }
#       Action = ["sts:AssumeRole", "sts:TagSession"]
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
#   role       = aws_iam_role.ebs_csi.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# resource "aws_eks_addon" "ebs" {
#   cluster_name             = var.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.30.0-eksbuild.1"
#   service_account_role_arn = aws_iam_role.ebs_csi.arn
# }

# # -----------------------------
# # EFS FILE SYSTEM + MOUNT TARGETS
# # -----------------------------
# resource "aws_efs_file_system" "efs" {
#   creation_token   = "eks"
#   encrypted        = true
#   performance_mode = "generalPurpose"
#   throughput_mode  = "bursting"
# }

# resource "aws_efs_mount_target" "a" {
#   file_system_id  = aws_efs_file_system.efs.id
#   subnet_id       = var.subnet_ids[0]
#   security_groups = [var.cluster_sg_id]
# }

# resource "aws_efs_mount_target" "b" {
#   file_system_id  = aws_efs_file_system.efs.id
#   subnet_id       = var.subnet_ids[1]
#   security_groups = [var.cluster_sg_id]
# }

# # -----------------------------
# # EFS CSI DRIVER (Helm)
# # -----------------------------
# data "aws_iam_policy_document" "efs_irsa" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(var.oidc_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }

#     principals {
#       type        = "Federated"
#       identifiers = [var.oidc_arn]
#     }
#   }
# }

# resource "aws_iam_role" "efs_irsa" {
#   name               = "${var.cluster_name}-efs-csi-role"
#   assume_role_policy = data.aws_iam_policy_document.efs_irsa.json
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_policy" {
#   role       = aws_iam_role.efs_irsa.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
# }

# resource "helm_release" "efs_csi" {
#   name       = "aws-efs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   namespace  = "kube-system"
#   version    = "3.0.3"

#   set {
#     name  = "controller.serviceAccount.name"
#     value = "efs-csi-controller-sa"
#   }

#   set {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.efs_irsa.arn
#   }

#   depends_on = [
#     aws_efs_mount_target.a,
#     aws_efs_mount_target.b
#   ]
# }

# resource "kubernetes_storage_class_v1" "efs" {
#   metadata {
#     name = "efs"
#   }

#   storage_provisioner = "efs.csi.aws.com"

#   parameters = {
#     provisioningMode = "efs-ap"
#     fileSystemId     = aws_efs_file_system.efs.id
#     directoryPerms   = "700"
#   }

#   mount_options = ["iam"]

#   depends_on = [helm_release.efs_csi]
# }

# data "aws_iam_openid_connect_provider" "oidc" {
#   url        = var.oidc_url
# }
