terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.34.0"
    }
  }
}

#================PROVIDERS================

provider "aws" {
  region = "us-east-1"

  shared_config_files      = var.shared_config_files
  shared_credentials_files = var.shared_credentials_files

  default_tags {
  }
}

provider "kubernetes" {
  host                   = module.cluster-eks.cluster_endpoint
  token                  = module.cluster-eks.cluster_token
  cluster_ca_certificate = base64decode(module.cluster-eks.cluster_certificate_authority_data)

}


#================VPC================

module "vpc" {
  source          = "./modules/VPC"
  vpc_name        = "darede-vpc"
  vpc_cidr        = "172.16.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnets = ["172.16.3.0/24", "172.16.4.0/24"]
  cluster_name = var.cluster_name
}

#=================EKS====================

module "cluster-eks" {
  source            = "./modules/EKS"
  cluster_name      = var.cluster_name
  nodes_name        = "darede-nodes"
  service_role_arn  = var.service_role_arn
  instance_role_arn = var.instance_role_arn
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnets
  private_subnets   = module.vpc.private_subnets
}


#=================WAF====================

module "waf" {
  source       = "./modules/WAF"
  waf_name     = "darede-waf"
  waf_scope    = "REGIONAL"
  resource_arn = module.cluster-eks.cluster_arn

  depends_on = [module.cluster-eks]
}
