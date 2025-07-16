region            = "us-east-2"
environment       = "dev"
s3_bucket_name    = "my-app-final-apse2"
instance_ami      = "ami-0eb9d6fc9fab44d24"
app_instance_type = "t2.micro"
instance_name     = "final-server"

asg_min_size  = 2
asg_max_size  = 4
asg_desired   = 2

alert_email = [
  "sop98886@gmail.com",
  "yimcheayong@gmail.com",
  "romleangmeng@gmail.com",
  "vatthanakvutthin@gmail.com"
]
db_username = "FinalCloud"
db_password = "FinalCloud"

db_users = {
  FinalCloud = "FinalCloud"
  app_user   = "AppPass123!"
  readonly   = "ReadOnly456!"
}
