# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id
  name   = "sm-bastion-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow SSH access to Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sm-bastion-sg"
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami           = "ami-04b4f1a9cf54c11d0"  
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = var.ssh_key_name
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y git
              snap install aws-cli --classic
              sudo snap install kubectl --classic
              EOF
  tags = {
    Name = "sm-bastion-host"
  }
}