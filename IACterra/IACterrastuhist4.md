# Access S3 Bucket from EC2 Instance using Terraform

## 概要
- **サービス内容**：Amazon EC2 は仮想サーバー環境を提供。EC2 インスタンスに IAM ロールを付与することで、S3 バケットへの安全なアクセスが可能。Apache をインストールして Web サーバーとしても利用可能。  
- **ラボ完了内容**：
  - Terraform で EC2 インスタンス、セキュリティグループ、S3 バケットを作成  
  - IAM ロールを付与して EC2 から S3 バケットにアクセス  
  - Apache サーバーを起動し、S3 から HTML をコピー  
  - EC2 のパブリック IP を使ってブラウザで Web ページ確認  
  - AWS コンソールでリソース作成・削除を確認  

## ポイント
1. **Terraform の基本操作**  
   - terraform init, plan, apply, destroy の使い方を理解
2. **EC2 インスタンスの設定**  
   - AMI、インスタンスタイプ、セキュリティグループ、IAM ロールの設定
3. **S3 バケットの設定**  
   - オブジェクトの作成と公開アクセスの理解
4. **User Data の活用**  
   - Apache のインストール、S3 から HTML のコピー
5. **アウトプット設定**  
   - EC2 のパブリック IP を Terraform で取得

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- Visual Studio Code をセットアップ
- Terraform 変数ファイルを作成
- main.tf に EC2 インスタンスと S3 バケット、セキュリティグループを記述
- output.tf を作成して EC2 のパブリック IP を出力
- Terraform のバージョン確認
- Terraform でリソースを作成
- EC2 から S3 バケットにアクセスして HTML をコピー
- AWS コンソールでリソース確認
- リソースを削除

### Task 2: Setup Visual Studio Code
```bash
# デスクトップに作業フォルダを作成
cd Desktop
mkdir task_10003_ec2
cd task_10003_ec2
pwd
```
- Visual Studio Code を開き、作成したフォルダを開く
- Terminal を開いて作業ディレクトリに移動

### Task 3: Create Variables Files
```hcl
# variables.tf
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "bucket_name" {}
```
```hcl
# terraform.tfvars
access_key = "<YOUR AWS ACCESS KEY>"
secret_key = "<YOUR AWS SECRET KEY>"
bucket_name = "<YOUR S3 BUCKET NAME>"
```

### Task 4: Create main.tf
```hcl
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_ssm_parameter" "al2023_latest" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_s3_bucket" "blog" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "object1" {
  for_each     = fileset("html/", "*")
  bucket       = aws_s3_bucket.blog.id
  key          = each.value
  source       = "html/${each.value}"
  etag         = filemd5("html/${each.value}")
  content_type = "text/html"
}

resource "aws_security_group" "web-sg" {
  name = "Web-SG"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023_latest.value
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  iam_instance_profile   = "<YOUR EC2 ROLE NAME>"

  user_data = <<EOF
#!/bin/bash
sudo su
yum update -y
yum install httpd -y
aws s3 cp s3://${aws_s3_bucket.blog.id}/index.html /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
EOF

  tags = {
    Name = "EC2-Instance"
  }
}
```

### Task 5: Create outputs.tf
```hcl
output "EC2_instance_id" {
  value = aws_instance.web.public_ip
}
```

### Task 6: Confirm Terraform Installation
```bash
terraform version
```

### Task 7: Apply Terraform Configuration
```bash
terraform init
terraform plan
terraform apply
```
- 作成された EC2 のパブリック IP をコピーしてブラウザで確認

### Task 8: Access EC2 via Session Manager
- AWS コンソールで EC2 → Instances → 対象インスタンス → Connect → Session Manager を選択
- 新しいタブで接続される

### Task 9: List S3 Bucket and Objects
```bash
# S3 バケット一覧
aws s3 ls

# バケット内オブジェクト一覧
aws s3 ls s3://<BUCKET_NAME>
```

### Task 10: Delete AWS Resources
```bash
terraform destroy
# yes を入力して削除
```

## 学習成果
- Terraform で EC2 インスタンス、S3 バケット、セキュリティグループを作成・管理する方法を習得  
- IAM ロールを使って EC2 から S3 に安全にアクセス  
- User Data を活用した Apache Web サーバー構築と HTML 配置  
- Terraform Output で EC2 のパブリック IP を取得  
- 作成・削除を通して IaC の理解を深める