module "ctfd_alb" { # TODO: update
  source                  = "./alb"
  subnets                 = var.alb_subnets
  vpc_id                  = var.vpc_id
  https_redirect_enabled  = var.https_redirect_enabled
  ssl_termination_enabled = var.ssl_termination_enabled
  allow_cloudflare        = var.allow_cloudflare
  inbound_ips             = var.inbound_ips
}

module "iam" {
  source              = "./iam"
  uploads_bucket_name = module.s3_uploads.uploads_bucket.id
  region              = var.region
}

module "s3_uploads" {
  source              = "./s3_uploads"
  uploads_bucket_name = "ctfd-uploads-${random_string.bucket_seed.result}"
}

module "mysql_db" {
  source     = "./mysql_db"
  vpc_id     = var.vpc_id
  db_subnets = var.db_subnets
}

module "redis" {
  source = "./redis"
  vpc_id = var.vpc_id
}

module "ecs" {
  source                    = "./ecs"
  ctfd_version              = var.ctfd_version
  aws_access_key_arn        = module.iam.s3_access.arn
  aws_secret_access_key_arn = module.iam.s3_secret.arn
  mail_username_arn         = var.mail_username_arn
  mail_password_arn         = var.mail_password_arn
  database_url_arn          = module.mysql_db.db_uri.arn
  desired_count             = var.desired_count
  workers                   = var.workers
  secret_key                = random_string.secret_key.result
  s3_bucket                 = module.s3_uploads.uploads_bucket.id
  mailfrom_addr             = var.mailfrom_addr
  mail_server               = var.mail_server
  mail_port                 = var.mail_port
  redis_url                 = module.redis.redis.cache_nodes[0].address
  task_family_name          = "ctfd"
  logs_region               = var.region
  execution_role_arn        = module.iam.ecs_role.arn
  iam_role_policy           = module.iam.ctfd_ecs_policy.id
  target_group_arn          = module.ctfd_alb.ctfd_target_group.arn
  security_groups = [
    module.redis.redis_security_group.id,
    module.mysql_db.db_security_group.id,
    module.ctfd_alb.alb_to_ecs_security_group.id
  ]
  subnets = var.ecs_subnets

  # wait for other resources in order to avoid race conditions :lolsob:
  ecs_task_depends_on = [module.mysql_db]
}
