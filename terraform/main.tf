provider "aws" {
  region = var.aws_region_eu-central-1
}
resource "aws_security_group" "ghost" {
  name        = "ghost_security_group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.ghost.public_ip
}
# EC2 instance
resource "aws_instance" "ghost" {
  ami           = var.ami_id_ghost
  instance_type = var.instance_type_t2mirco
  key_name      = var.key_name
  subnet_id     = var.subnet_id_ghost
  vpc_security_group_ids = [aws_security_group.ghost.id]

  # Tag for identification
  tags = {
    Name = "Ghost_CMS"
  }

  # Connection settings for provisioners
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("ghostsshkey.pem")
    host        = self.public_ip
  }

  # Provisioners for installing and configuring Ghost CMS
  provisioner "remote-exec" {
    inline = [
      "while sudo lsof /var/lib/rpm/.dbenv.lock; do sleep 10; done",
      "sudo echo 'Starting provisioner'",
      "sudo yum -y update",
      "sudo yum -y install nodejs",
      "sudo yum -y install npm",
      "export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
      "/usr/bin/sudo /usr/bin/npm install -g ghost-cli >> /tmp/provision.log 2>&1",
      "sudo mkdir -p /var/www/ghost",
      "sudo chown ec2-user:ec2-user /var/www/ghost",
      "cd /var/www/ghost",
      "/usr/bin/sudo /usr/bin/ghost install >> /tmp/provision.log 2>&1",
    ]
  }
}
