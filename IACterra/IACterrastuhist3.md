# Launch an EC2 Instance as a Web Server using Terraform

## 概要
- **サービス内容**：Amazon EC2（Elastic Compute Cloud）は、仮想サーバー環境を提供。AMI（Amazon Machine Images）を使って事前構成済みのインスタンスを簡単に起動可能。インスタンスに Apache などのサービスをインストールして Web サーバーとして利用可能。
- **ラボ完了内容**：
  - Terraform で EC2 インスタンスとセキュリティグループを作成
  - Apache サーバーを起動し、HTML コンテンツを配置
  - EC2 のパブリック IP を使ってブラウザで Web ページ確認
  - AWS コンソールでリソース作成・削除を確認

## ポイント
1. **Terraform の基本操作**
   - terraform init, plan, apply, destroy の使い方を理解
2. **EC2 インスタンスの設定**
   - AMI、インスタンスタイプ、Key Pair、セキュリティグループ、タグの設定方法
3. **セキュリティグループ理解**
   - HTTP (80) ポート開放、全てのアウトバウンド許可の設定
4. **User Data での初期設定**
   - Apache サーバーのインストール、自動起動、HTML ページの作成
5. **アウトプット設定**
   - EC2 インスタンスのパブリック IP を出力

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- Visual Studio Code をセットアップ
- Terraform 変数ファイルを作成
- main.tf に EC2 インスタンスとセキュリティグループを記述
- output.tf を作成してパブリック IP を出力
- Terraform のバージョン確認
- Terraform でリソースを作成
- EC2 にアクセスして HTML ページを確認
- AWS コンソールでリソース確認
- リソースを削除

### Task 2: Setup Visual Studio Code
1. 新規フォルダを作成（例: task_ec2_web）
2. Visual Studio Code を開き、作業フォルダを開く
3. Terminal を開き、作業ディレクトリに移動

### Task 3: Create Variables Files
- variables.tf

variable "access_key" {
  description = "Access key to AWS console"
}
variable "secret_key" {
  description = "Secret key to AWS console"
}
variable "region" {
  description = "Region of AWS"
}

- terraform.tfvars

region = "us-east-1"
access_key = "<AWS ACCESS KEY>"
secret_key = "<AWS SECRET KEY>"

### Task 4: Create EC2 and Security Group in main.tf

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_security_group" "web-server" {
  name        = "web-server"
  description = "Allow HTTP traffic"

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

resource "aws_instance" "web-server" {
  ami           = "ami-xxxxxxxxxxxxxx"  # Region に合った AMI を使用
  instance_type = "t2.micro"
  key_name      = "your-key-pair"
  security_groups = [aws_security_group.web-server.name]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<html><h1> Welcome to the Web Server! </h1></html>" >> /var/www/html/index.html
  EOF

  tags = {
    Name = "web_instance"
  }
}

### Task 5: Create Output File
- output.tf

output "web_instance_ip" {
  value = aws_instance.web-server.public_ip
}

### Task 6: Confirm Terraform Installation
- terraform version

### Task 7: Apply Terraform Configuration
- terraform init
- terraform plan
- terraform apply
- 作成された EC2 のパブリック IP を確認

### Task 8: Check HTML Page
- ブラウザで EC2 のパブリック IP にアクセス
- User Data で作成した HTML が表示される

### Task 9: Check Resources in AWS Console
- EC2 → Instances で作成されたインスタンスを確認
- Security Groups で web-server が存在することを確認

### Task 10: Delete AWS Resources
- terraform destroy
- yes を入力して削除
- AWS コンソールでリソースが削除されたことを確認

## 学習成果
- Terraform で EC2 インスタンスとセキュリティグループを作成・管理する方法を習得
- User Data を使った初期設定による Apache Web サーバー構築
- Terraform 出力（Output）でリソース情報を取得する方法
- 作成・削除を通して IaC の実践理解