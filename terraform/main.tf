terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# SSH 鍵ペアを Terraform で生成
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# 秘密鍵をローカルに保存（Terraform apply 時に）
resource "local_file" "private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/my-ec2-key.pem"
  file_permission = "0600"
}
# VPC
# ==========================
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "MyVPC" }
}

# ==========================
# パブリックサブネット
# ==========================
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# ==========================
# インターネットゲートウェイ & ルート
# ==========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================
# セキュリティグループ
# ==========================
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================
# EC2 インスタンス + Docker + PHP + SQLite
# ==========================
resource "aws_instance" "my_ec2" {
  ami                         = "ami-0c94855ba95c71c99" # Amazon Linux 2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.my_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # 更新と Docker インストール
    yum update -y
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker
    usermod -a -G docker ec2-user

    # Docker Compose インストール
    curl -L "https://github.com/docker/compose/releases/download/v2.22.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # アプリディレクトリ作成
    mkdir -p /home/ec2-user/app/src
    cd /home/ec2-user/app

    # Docker Compose ファイル作成
    cat <<EOC > docker-compose.yml
    version: '3'
    services:
      php-apache:
        image: php:8.2-apache
        container_name: php_apache
        ports:
          - "80:80"
        volumes:
          - ./src:/var/www/html
    EOC

    # PHP + SQLite サンプルコード
    cat <<EOPHP > src/index.php
    <?php
    \$db = new PDO('sqlite:/var/www/html/database.db');
    \$db->exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT);");
    \$db->exec("INSERT INTO users (name) VALUES ('Alice');");

    foreach (\$db->query('SELECT * FROM users') as \$row) {
        echo "ID: " . \$row['id'] . " Name: " . \$row['name'] . "<br>";
    }
    ?>
    EOPHP

    # Docker Compose 起動
    docker-compose up -d
  EOF
}

# ==========================
# Output
# ==========================
output "ec2_public_ip" {
  value       = aws_instance.my_ec2.public_ip
  description = "EC2のパブリックIPアドレス"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.my_ec2.public_ip}"
  description = "EC2にSSH接続するコマンド"
}