# =========================================
# 3) EKS Add-ons (CoreDNS, kube-proxy, VPC CNI)
# =========================================

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  # addon_version = "v1.xx.x-eksbuild.y"  # optional pin
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "aws_eks_addon" "coredns" {
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

/*# Optional but common:
 #EBS CSI Driver (for dynamic PV provisioning)
 resource "aws_eks_addon" "ebs_csi" {
   cluster_name = var.cluster_name
   addon_name   = "aws-ebs-csi-driver"
   resolve_conflicts_on_create = "OVERWRITE"
   resolve_conflicts_on_update = "OVERWRITE"
 }*/

/*#Optional: EKS Pod Identity Agent (ONLY if you want EKS Pod Identity feature)
 resource "aws_eks_addon" "pod_identity_agent" {
   cluster_name = var.cluster_name
   addon_name   = "eks-pod-identity-agent"
   resolve_conflicts_on_create = "OVERWRITE"
   resolve_conflicts_on_update = "OVERWRITE"
   #depends_on = [aws_eks_node_group.public]
 }*/
