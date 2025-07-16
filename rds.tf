resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-rds-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = { Name = "rds-subnet-group" }
}

resource "aws_db_instance" "mydb" {
  identifier              = "my-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "appdb"
  username                = var.db_username
  password                = var.db_users["FinalCloud"]
  skip_final_snapshot     = true
  storage_encrypted       = true
  backup_retention_period = 7
  deletion_protection     = true
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  multi_az                = false
  publicly_accessible     = false
  tags = { Name = "AppDatabase" }
}
