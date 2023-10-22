provider "aws" {
  region = "eu-central-1"  # Change this to your preferred AWS region
}

resource "aws_instance" "ghost" {
  ami           = "ami-0fb820135757d28fd"  # Amazon Linux 2 (free tier eligible)
  instance_type = "t2.micro"                # Free tier eligible instance type

  key_name      = var.key_name  # Replace with your SSH key name

  vpc_security_group_ids = [aws_security_group.ghost.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install epel -y
              sudo yum install -y unzip

              # Install Ghost CMS
              sudo curl -L https://ghost.org/zip/ghost-latest.zip -o ghost-latest.zip
              sudo unzip -uo ghost-latest.zip -d /var/www/ghost
              sudo chown -R ec2-user:ec2-user /var/www/ghost

              # Configure Ghost
              cd /var/www/ghost
              sudo npm install --production
              sudo cp config.production.json config.production.json.backup
              sudo cp config.example.json config.production.json

              # Start Ghost
              sudo npm start --production
              EOF

  tags = {
    Name = "GhostCMSInstance"
  }
}

resource "aws_security_group" "ghost" {
  name        = "ghost_security_group"
  description = "Security group for Ghost CMS instance"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this to your IP address range
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.ghost.public_ip
}
