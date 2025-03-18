# -----------------------------------
# RDS Database Module
# -----------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids  # From module.vpc.private_subnets
  tags = {
    Name  = "${var.identifier}-subnet-group"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier          = var.identifier
  engine              = "postgres"
  engine_version      = "17"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20

  db_name             = var.database_name
  username            = var.username
  password            = var.password
  publicly_accessible = false

  vpc_security_group_ids = var.vpc_security_group_ids  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name  

  family = "postgres17"

  tags = {
    Name  = var.identifier
  }
}