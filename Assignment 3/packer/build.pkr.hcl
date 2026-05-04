packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "custom-nginx-ami-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "nginx-builder"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx curl",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo '<h1>Welcome to Custom AMI via Packer!</h1>' | sudo tee /var/www/html/index.html",
      "sudo apt-get install -y stress-ng"
    ]
  }
}
