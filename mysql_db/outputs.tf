output "db_cluster" {
  value = aws_rds_cluster.default
}

output "db_instances" {
  value = aws_rds_cluster_instance.cluster_instances[*]
}

output "pass" {
  value     = random_string.random
  sensitive = true
}