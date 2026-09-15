data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_key_pair" "technova" {
  key_name   = "technova-key"
  public_key = file(pathexpand("~/.ssh/technova-key.pub"))
}

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.api.id]

  key_name = aws_key_pair.technova.key_name

  iam_instance_profile        = data.aws_iam_instance_profile.lab_profile.name
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y
              dnf install -y git

              curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
              dnf install -y nodejs

              cd /opt
              git clone https://github.com/caroll143/technova-api.git /opt/technova-api

              cd /opt/technova-api

              npm install
              npm start > /var/log/technova-api.log 2>&1 &
              EOF

  tags = {
    Name        = "technova-api-ec2"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}
