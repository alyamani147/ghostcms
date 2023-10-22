provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ghost" {
  ami           = "ami-0df435f331839b2d6"
  instance_type = "t2.micro"

  key_name = var.key_name

  vpc_security_group_ids = [aws_security_group.ghost.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo apt-get install -y nodejs",
      "sudo apt-get install -y npm",
      "sudo npm install -g ghost-cli",
      "sudo mkdir -p /var/www/ghost",
      "sudo chown $USER:$USER /var/www/ghost",
      "ghost install",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    tags = {
      Name = "GhostCMSInstance"
    }
  }
}


resource "aws_security_group" "ghost" {
  name        = "ghost_security_group"
  description = "Security group for Ghost CMS instance"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restricting this to my IP, but since I don't have a real IP yet, will keep it open
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
