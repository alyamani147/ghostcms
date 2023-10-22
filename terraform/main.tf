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
    private_key = aws_secretsmanager_secret_version.ghostkey.secret_string
    host        = self.public_ip
  }

#   Provisioners for installing and configuring Ghost CMS
  provisioner "remote-exec" {
    inline = [
      "echo 'Starting provisioner'",
      "sudo yum update -y",
      "sudo amazon-linux-extras install epel -y",
      "sudo yum install -y gcc-c++ make",
      "sudo yum remove libuv -y",
      "sudo wget https://rpmfind.net/linux/epel/7/x86_64/Packages/l/libuv-1.44.2-1.el7.x86_64.rpm",
      "sudo rpm -i libuv-1.44.2-1.el7.x86_64.rpm",
      "sudo yum install https://rpm.nodesource.com/pub_18.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y",
      "sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1",
      "sudo yum install -y npm",
      "sudo npm install -g npm@10.2.1",
      "node -v",
      "npm -v",
      "sudo npm install ghost-cli@latest -g",
      "sudo npm audit fix --force",
      "sudo ghost install local",
    ]
  }
}
resource "aws_secretsmanager_secret" "ghostkey" {
  name = "GhostKeyEC2Latest"
}

resource "aws_secretsmanager_secret_version" "ghostkey" {
  secret_id = aws_secretsmanager_secret.ghostkey.id
  secret_string = file("./ghostsshkey.pem")
}
