resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = var.instance_ami
  instance_type = var.app_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

user_data = base64encode(<<-EOF
#!/bin/bash
exec > >(tee /var/log/bootstrap.log | logger -t user-data -s 2>/dev/console) 2>&1
set -eux

# 1. Install LAMP + AWS CLI
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 php php-mysql mysql-client awscli unzip curl

# 2. Start and enable Apache
systemctl enable apache2
systemctl start apache2

# 3. Create working dir and move in
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# 4. Pull environment + SQL seed from S3
aws s3 cp s3://${var.s3_bucket_name}/.env . || { echo ".env not found"; exit 1; }
aws s3 cp s3://${var.s3_bucket_name}/seed_appdb.sql . || { echo "seed_appdb.sql not found"; exit 1; }

# 5. Load .env vars (DB_HOST, DB_USER, DB_PASS, DB_NAME)
set -a
source .env
set +a

# 6. Wait for RDS to be available
for i in {1..30}; do
  if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &>/dev/null; then
    echo "Database is available"
    break
  fi
  echo "Waiting for database..."
  sleep 10
done

# 7. Seed database
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < seed_appdb.sql || echo "DB already initialized"

# 8. Write test PHP DB connection page
cat <<EOPHP > /var/www/html/dbtest.php
<?php
\$conn = new mysqli('$DB_HOST', '$DB_USER', '$DB_PASS', '$DB_NAME');
if (\$conn->connect_error) {
  die("Connection failed: " . \$conn->connect_error);
}
echo "Connected to RDS MySQL!";
?>
EOPHP

# 9. Ensure root (/) returns HTTP 200 with content
aws s3 cp s3://${var.s3_bucket_name}/index.html /var/www/html/index.html || echo "<h1>App is ready</h1>" > /var/www/html/index.html

# 10. Restart Apache just in case
systemctl restart apache2
EOF
)

}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "asg-final-cloud"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = aws_launch_template.app_lt.latest_version
  }

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
