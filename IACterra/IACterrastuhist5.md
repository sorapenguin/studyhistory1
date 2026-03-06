# Application Load Balancer を使用して 2 つの EC2 インスタンス間でトラフィックを分散する（Terraform 使用）

## 概要
このラボでは、Terraform を使用して AWS 上に **Application Load Balancer (ALB)** を作成し、HTTP トラフィックを **2 台の EC2 インスタンス** に分散する手順を学びます。  
Terraform ファイル作成、初期化、リソース作成、トラフィック確認、リソース削除までの一連の操作を体験できます。

**所要時間:** 約 1 時間  
**AWS リージョン:** US East (N. Virginia) `us-east-1`

**学習ポイント**
- ELB と ALB の仕組みを理解
- Terraform による AWS リソース作成
- EC2 インスタンスと ALB の連携
- トラフィック分散の確認
- Terraform によるリソース削除

---

## 前提条件
- Terraform をローカルマシンにインストール ([HashiCorp ガイド](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- Visual Studio Code をインストール

---

## Lab 手順と Terraform コード

```hcl
# 作業フォルダ作成
cd Desktop
mkdir task_10004_elb
cd task_10004_elb
pwd

# variables.tf ファイル
variable "access_key" {
    description = "AWS コンソールアクセスキー"
}

variable "secret_key" {
    description = "AWS コンソールシークレットキー"
}

variable "region" {
    description = "AWS VPC のリージョン"
}

# terraform.tfvars ファイル
region = "us-east-1"
access_key = "<YOUR AWS CONSOLE ACCESS ID>"
secret_key = "<YOUR AWS CONSOLE SECRET KEY>"

# main.tf ファイル
provider "aws" {
    region     = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

################## デフォルト VPC とサブネット ##################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

################## セキュリティグループ ##################
# ALB セキュリティグループ
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "HTTP を許可"
  vpc_id      = data.aws_vpc.default.id
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

# EC2 セキュリティグループ
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "ALB からの HTTP のみ許可"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################## EC2 インスタンス 2 台作成 ##################
resource "aws_instance" "web_server" {
  ami           = "ami-0150ccaf51ab55a51"
  instance_type = "t2.micro"
  count         = 2
  key_name      = "<YOUR KEY NAME>"
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
       #!/bin/bash
       sudo dnf update -y
       sudo dnf install -y httpd
       sudo systemctl start httpd
       sudo systemctl enable httpd
       echo "<html><h1>Welcome! This is $(hostname -f)</h1></html>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "instance-${count.index + 1}"
  }
}

################## ターゲットグループ作成 ##################
resource "aws_lb_target_group" "target_group" {
  name        = "app-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

################## ALB 作成 ##################
resource "aws_lb" "application_lb" {
  name               = "app-alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "app-alb"
  }
}

################## リスナー作成 ##################
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

################## ターゲットグループに EC2 をアタッチ ##################
resource "aws_lb_target_group_attachment" "ec2_attach" {
  count            = length(aws_instance.web_server)
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.web_server[count.index].id
}

################## 出力 ##################
output "alb_dns_name" {
  value = aws_lb.application_lb.dns_name
}

# Terraform コマンド手順
# Terraform 初期化
terraform init

# 作成プラン確認
terraform plan

# リソース作成
terraform apply
# yes と入力して作成承認

# ALB の DNS 名でブラウザ確認
# HTML ページが表示され、リロードすると 2 台の EC2 に分散されることを確認

# AWS コンソール確認
# EC2 インスタンス、セキュリティグループ、ALB、ターゲットグループが作成されていることを確認

# リソース削除
terraform destroy
# yes と入力して削除承認