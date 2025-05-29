terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = var.vpc_cidr
  project_name   = var.project_name
  environment    = var.environment
}

module "public_subnet" {
  source         = "./modules/subnet"
  vpc_id         = module.vpc.vpc_id
  cidr_blocks    = var.public_subnet_cidrs
  azs            = var.azs
  subnet_type    = "public"
  project_name   = var.project_name
  environment    = var.environment
}

module "private_subnet" {
  source         = "./modules/subnet"
  vpc_id         = module.vpc.vpc_id
  cidr_blocks    = var.private_subnet_cidrs
  azs            = var.azs
  subnet_type    = "private"
  project_name   = var.project_name
  environment    = var.environment
}

module "security_groups" {
  source         = "./modules/security_group"
  vpc_id         = module.vpc.vpc_id
  vpc_cidr       = var.vpc_cidr
  project_name   = var.project_name
  environment    = var.environment
}

module "nginx_proxies" {
  source          = "./modules/ec2"
  instance_count  = var.proxy_count
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_ids      = module.public_subnet.subnet_ids
  security_groups = [module.security_groups.proxy_sg_id]
  key_name        = var.key_name
  user_data       = file("${path.module}/user-data/proxy.sh")
  role            = "proxy"
  project_name    = var.project_name
  environment     = var.environment
}

module "apache_servers" {
  source          = "./modules/ec2"
  instance_count  = var.backend_count
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_ids      = module.private_subnet.subnet_ids
  security_groups = [module.security_groups.backend_sg_id]
  key_name        = var.key_name
  user_data       = file("${path.module}/user-data/backend.sh")
  role            = "backend"
  project_name    = var.project_name
  environment     = var.environment
}

module "external_alb" {
  source          = "./modules/elb"
  name            = "external-alb"
  internal        = false
  security_groups = [module.security_groups.alb_sg_id]
  subnet_ids      = module.public_subnet.subnet_ids
  vpc_id          = module.vpc.vpc_id
  instances       = module.nginx_proxies.instance_ids
  project_name    = var.project_name
  environment     = var.environment
}

module "internal_alb" {
  source          = "./modules/internal-alb"
  name            = "internal-alb"
  internal        = true
  security_groups = [module.security_groups.internal_alb_sg_id]
  subnet_ids      = module.private_subnet.subnet_ids
  vpc_id          = module.vpc.vpc_id
  instances       = module.apache_servers.instance_ids
  project_name    = var.project_name
  environment     = var.environment
}

module "state_backend" {
  source        = "./modules/backend"
  bucket_name   = var.state_bucket_name
  table_name    = var.lock_table_name
  environment   = var.environment
}
