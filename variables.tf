variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, prod)"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for static assets"
}

variable "instance_ami" {
  type        = string
  description = "AMI ID for EC2 instance"
}

variable "app_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "instance_name" {
  type        = string
  description = "EC2 instance name for tagging"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of EC2 instances in ASG"
  default     = 2
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of EC2 instances in ASG"
  default     = 4
}

variable "asg_desired" {
  type        = number
  description = "Desired number of EC2 instances in ASG"
  default     = 2
}

variable "alert_email" {
  type        = list(string)
  description = "List of email addresses to receive CloudWatch alerts"
}
variable "db_username" {
  description = "Database admin username"
  type        = string
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}
variable "db_users" {
  type        = map(string)
  description = "Map of DB usernames and passwords"
  sensitive   = true
}
