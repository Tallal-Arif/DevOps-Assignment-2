module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

module "security" {
  source = "./modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  my_ip       = var.my_ip
}

module "compute" {
  source = "./modules/compute"

  ami_id             = var.ami_id
  instance_type      = var.instance_type
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  web_sg_id          = module.security.web_sg_id
  db_sg_id           = module.security.db_sg_id
  key_name           = var.key_name
  environment        = var.environment
  s3_bucket_arn      = aws_s3_bucket.terraform_state.arn
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  environment       = var.environment
  asg_name          = module.compute.asg_name
}
