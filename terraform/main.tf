provider "aws" {
  region = var.aws_region_eu-central-1
}

# EC2 instance
resource "aws_instance" "ghost" {
  ami           = var.ami_id_ghost
  instance_type = var.instance_type_t2mirco
  key_name      = var.key_name
  subnet_id     = var.subnet_id_ghost

  # Tag for identification
  tags = {
    Name = "Ghost-CMS"
  }

  # Connection settings for provisioners
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/id_rsa")
    host        = self.public_ip
  }

  # Provisioners for installing and configuring Ghost CMS
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nodejs",
      "sudo apt-get install -y npm",
      "sudo npm install -g ghost-cli",
      "sudo mkdir -p /var/www/ghost",
      "sudo chown ubuntu:ubuntu /var/www/ghost",
      "cd /var/www/ghost",
      "ghost install",
    ]
  }
}
