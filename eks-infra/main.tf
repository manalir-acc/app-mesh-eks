module "vpc" {
    source                              = "../modules/vpc"
    environment                         =  var.environment
    vpc_cidr                            =  var.vpc_cidr
    vpc_name                            =  var.vpc_name
    cluster_name                        =  var.cluster_name
    cluster_group                       =  var.cluster_group
    public_subnets_cidr                 =  var.public_subnets_cidr
    availability_zones_public           =  var.availability_zones_public
    private_subnets_cidr                =  var.private_subnets_cidr
    availability_zones_private          =  var.availability_zones_private
    cidr_block_nat_gw                   =  var.cidr_block_nat_gw
    cidr_block_internet_gw              =  var.cidr_block_internet_gw
}



module "eks" {
    source                              =  "../modules/eks"
    cluster_name                        =  var.cluster_name
    cluster_version                     =  var.cluster_version
    environment                         =  var.environment
    #eks_node_group_instance_types       =  var.eks_node_group_instance_types
    private_subnets                     =  module.vpc.aws_subnets_private
    public_subnets                      =  module.vpc.aws_subnets_public
    fargate_app_namespace               =  var.fargate_app_namespace

    depends_on = [module.vpc]
}



module "coredns_patching" {
  source  = "../modules/coredns-patch"

  k8s_cluster_type = var.cluster_type
  k8s_namespace    = "kube-system"
  k8s_cluster_name = module.eks.eks_cluster_name
  user_profile =   var.user_profile
  user_os = var.user_os
  depends_on = [module.eks]

}

module "aws_alb_controller" {
  source  = "../modules/aws-lb-controller"
  k8s_cluster_type = var.cluster_type
  k8s_namespace    = "kube-system"
  k8s_cluster_name = module.eks.eks_cluster_name
 # alb_controller_depends_on =  ""
  depends_on = [module.eks, module.coredns_patching]
}

module "eks_kubernetes_addons" {
  source         = "../modules/kubernetes-addons"
  enable_amazon_eks_vpc_cni    = true
  k8s_cluster_type = var.cluster_type
  k8s_namespace    = "kube-system"
  k8s_cluster_name = module.eks.eks_cluster_name
  depends_on = [module.eks, module.coredns_patching]
}
# module "aws_appmesh_controller" {
#   source  = "../modules/aws-appmesh-controller"
#   k8s_namespace    = "appmesh-system"
#   k8s_cluster_name = module.eks.eks_cluster_name
#   depends_on =  [module.eks, module.coredns_patching]
# }

# module "acm" {
#   source           = "../modules/acm-cert"
#   domain_name      = "landg-eks.com"
#   hosted_zone_name = "landg-eks.com"
#   #certificate_name = "wildcard.tsi.dev-tvlk.cloud"
#   environment      = "testing"
#   description      = "Wildcard certificate for example.tsi.dev-tvlk.cloud"
#   product_domain   = "eks"
# }
# module "kubernetes_app" {
#    source           =  "../modules/kubernetes-app"

#  depends_on = [module.eks, module.aws_alb_controller]
# }


