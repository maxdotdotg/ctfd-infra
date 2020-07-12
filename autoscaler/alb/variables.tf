variable "subnets" {
  type        = list(string)
  description = "subnet ids the ALB should live in"
}

variable "alb_logs_bucket_name" {
  type        = string
  description = "s3 bucket to store the alb logs"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id that the ALB will live in"
}

variable "certificate_arn" {
  type        = string
  description = "ARN for the SSL certificate used by the ALB"
}

variable "instance_sg_id" {
  type = string
  description = "security group id that allows traffic between ALB and nodes"
}
