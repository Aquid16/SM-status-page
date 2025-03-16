# -----------------------------------
# RDS Database Module
# -----------------------------------
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
  subnet_ids          = var.subnet_ids

  family = "postgres17"

  tags = {
    Name  = var.identifier
  }
}

resource "null_resource" "initialize_db" {
  provisioner "local-exec" {
    command = <<EOT
      psql -h ${module.rds.db_instance_endpoint} -U ${var.username} -d postgres -c "CREATE DATABASE ${var.database_name} OWNER ${var.username};"
    EOT
    environment = {
      PGPASSWORD = var.password
    }
  }

  depends_on = [module.rds]
}