



############################################
# Core modules
############################################

module "network" {
  source = "./modules/network"

  cluster_name = var.name
  environment  = var.environment
  region       = var.region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway   = true
  create_vpc_endpoints = true

  # simplest: allow endpoint connections from inside the VPC
  endpoint_allowed_cidrs = [var.vpc_cidr]

  tags = var.tags
}

module "eks_cluster" {
  source       = "./modules/eks-cluster"
  cluster_name = var.name
  region       = var.region
  subnet_ids   = module.network.private_subnet_ids
  vpc_cidr_block = var.vpc_cidr
}

module "oidc_provider" {
  source          = "./modules/oidc-provider"
  cluster_name    = module.eks_cluster.cluster_name
  oidc_issuer_url = module.eks_cluster.oidc_issuer_url
}

module "node_groups" {
  source       = "./modules/node-groups"
  cluster_name = module.eks_cluster.cluster_name
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids

  ssh_key_name      = "kube-demo"
  ssh_ingress_cidrs = ["73.15.140.160/32"]
}

module "eks_addons" {
  source       = "./modules/eks-addons"
  cluster_name = module.eks_cluster.cluster_name

  depends_on = [module.node_groups]
  
}

############################################
# Secrets Manager: Git creds for Image Updater (HTTPS + PAT)
# Creates:
#   eksdemo2/prod/argocd-image-updater/git-creds
############################################
/* create it once in SM... let it stay.. dun create using terraform
module "gitlab_image_updater_secret" {
  source = "./modules/secrets-manager"

  name        = "${module.eks_cluster.cluster_name}/prod/argocd-image-updater/git-creds"
  description = "Git creds (HTTPS) for ArgoCD Image Updater"

  # ExternalSecret extracts username/password
  secret_string = jsonencode({
    username = var.gitlab_username
    password = var.gitlab_token
  })

  tags = {
    Cluster = module.eks_cluster.cluster_name
    Env     = "prod"
    App     = "argocd-image-updater"
  }
}
*/
############################################
# IRSA roles
############################################

data "aws_caller_identity" "current" {}

module "irsa_roles" {
  source            = "./modules/irsa-roles"
  cluster_name      = module.eks_cluster.cluster_name
  oidc_issuer_url   = module.eks_cluster.oidc_issuer_url
  oidc_provider_arn = module.oidc_provider.oidc_provider_arn
  aws_account_id    = data.aws_caller_identity.current.account_id

  oidc_provider_url = module.eks_cluster.oidc_provider_url

  # if your irsa module expects this ARN for ESO/other integrations
  gitlab_secret_arn = var.gitlab_secret_arn
}

############################################
# Karpenter
############################################

module "karpenter" {
  source                        = "./modules/karpenter"
  cluster_name                  = module.eks_cluster.cluster_name
  region                        = var.region
  oidc_provider_arn             = module.oidc_provider.oidc_provider_arn
  oidc_issuer_url               = module.eks_cluster.oidc_issuer_url
  karpenter_controller_role_arn = module.karpenter.controller_role_arn

  karpenter_namespace      = "karpenter"
  karpenter_serviceaccount = "karpenter"
  karpenter_node_role_name = "${module.eks_cluster.cluster_name}-karpenter-node-role"
  discovery_tag            = module.eks_cluster.cluster_name
}

############################################
# Install Argo CD via Helm
############################################

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [file("${path.module}/argocd-values.yaml")]
}

############################################
# OPTIONAL: SSH repo secret (REMOVE if you switched fully to HTTPS)
# If you are not using SSH anymore (platform-root repoURL is HTTPS),
# delete this block and also delete the old AWS secret in Secrets Manager.
############################################
# module "gitlab_repo_ssh_secret" {
#   source      = "./modules/secrets-manager"
#   name        = "${module.eks_cluster.cluster_name}/prod/argocd/gitlab-ssh-repo"
#   description = "ArgoCD repo SSH credentials for GitLab"
#
#   secret_string = jsonencode({
#     url           = "git@gitlab.com:learning-group1580903/Learning-project.git"
#     sshPrivateKey = file(pathexpand("~/.ssh/id_ed25519"))
#     known_hosts   = "gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf"
#   })
#
#   tags = {
#     Cluster = module.eks_cluster.cluster_name
#     Env     = "prod"
#     App     = "argocd"
#   }
# }

############################################
# RDS Postgres
############################################

module "rds_postgres" {
  source = "./modules/rds-postgres"

  name        = "${var.name}-db"
  environment = var.environment
  tags        = var.tags

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  allowed_security_group_ids = {
    eks_nodes       = module.node_groups.eks_nodes_security_group_id
    eks_cluster_sg  = module.eks_cluster.cluster_security_group_id
    karpenter_nodes = module.node_groups.karpenter_nodes_security_group_id
  }

  db_name         = "todo"
  master_username = "postgres"

  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  backup_retention_period = 1
  multi_az                = false
}



############################################
# EC2 and ECS 
############################################
/*
module "ec2_bastion" {
  source      = "./modules/ec2-instance"
  name        = "${module.eks_cluster.cluster_name}-bastion"
  environment = var.environment

  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_ids[0] # if bastion; for private EC2 use private subnet
  instance_type = "t3.micro"

  associate_public_ip   = true
  allowed_ingress_cidrs = []
  ingress_ports         = [22]

  tags = var.tags
}


module "ecs_todo" {
  source      = "./modules/ecs-fargate-service"
  name        = "todo"
  environment = var.environment
  region      = var.region

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  container_image   = var.todo_image
  container_port    = 8080
  desired_count     = 2
  health_check_path = "/health"

  env = {
    ENV = var.environment
  }

  tags = var.tags
}
*/