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
      "sudo curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -",
      "sudo yum install -y nodejs",
      "sudo yum install -y npm",
      "node -v",
      "npm -v",
      "sudo npm install ghost-cli@latest -g",
      "sudo npm audit fix --force",
      "sudo npm install -g npm@10.2.1",
      "sudo ghost install local",
    ]
  }
#  provisioner "remote-exec" {
#    inline = [
#      "usermod -aG sudo ubuntu",
#      "su - ubuntu",
#      "sudo apt-get update",
#      "sudo apt-get upgrade",
#      "sudo apt-get install nginx",
#      "sudo ufw allow 'Nginx Full'",
#      "sudo apt-get install mysql-server",
#      "sudo apt-get update",
#      "sudo apt-get install -y ca-certificates curl gnupg",
#      "sudo mkdir -p /etc/apt/keyrings",
#      "sudo curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg NODE_MAJOR=18",
#      "echo \"deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main",
#      "sudo tee /etc/apt/sources.list.d/nodesource.list",
#      "sudo apt-get update",
#      "sudo apt-get install nodejs -y",
#      "sudo npm install ghost-cli@latest -g",
#      "sudo mkdir -p /var/www/ghost",
#      "sudo chown ubuntu:ubuntu /var/www/ghost",
#      "sudo chmod 775 /var/www/ghost",
#      "cd /var/www/ghost",
#      "sudo ghost install"
#    ]
#  }
}
resource "aws_secretsmanager_secret" "ghostkey" {
  name = "sshkeyALMEC2ghosts"
}

resource "aws_secretsmanager_secret_version" "ghostkey" {
  secret_id = aws_secretsmanager_secret.ghostkey.id
  secret_string = file("./ghostsshkey.pem")
}