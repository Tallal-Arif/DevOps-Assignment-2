output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "public_instance_ip" {
  value = module.compute.public_instance_ip
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}


