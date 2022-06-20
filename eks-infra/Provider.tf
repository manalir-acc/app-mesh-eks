#provider "aws" {
#  region = "var.region_name"
#  profile = "AWS_741032333307_User"
#}

provider "aws" {
  region     = var.region_name
}
terraform {
  backend "s3" {
    bucket = "landg-terraform-state"
    key    = "eks/test/terraform.tfstate"
    region = "eu-west-1"
    encrypt= true

  }
}
locals {
  cluster_name= data.aws_eks_cluster.eks_cluster.name
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  #config_path = "./.kube/config"
  config_path ="${var.github_runner_base_path}.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    #config_path = "./.kube/config"
    config_path ="${var.github_runner_base_path}.kube/config"
  }
}
##
#provider "helm" {
#  kubernetes {
#    host                   = data.aws_eks_cluster.eks_cluster.endpoint
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#    exec {
#      api_version = "client.authentication.k8s.io/v1alpha1"
#      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
#      command     = "aws"
#    }
#  }
#}
#provider "kubernetes" {
#  host                   = data.aws_eks_cluster.eks_cluster.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#  exec {
#    api_version = "client.authentication.k8s.io/v1alpha1"
#    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
#    command     = "aws"
#  }
#}
