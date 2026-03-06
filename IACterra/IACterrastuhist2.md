# Host a S3 Static Website using Terraform

## 概要
- **サービス内容**：Amazon S3 による静的ウェブサイトのホスティングを Terraform で自動化
- **ラボ完了内容**：
  - Visual Studio Code 環境構築
  - variables.tf, terraform.tfvars, main.tf, outputs.tf の作成
  - S3 バケット作成・HTMLファイルアップロード
  - バケットポリシーで公開設定
  - ウェブサイト動作確認
  - Terraform によるリソース削除

## ポイント
1. **Terraform による自動化**
   - インフラをコードで管理、再現性のある環境構築
2. **S3 の静的サイト理解**
   - index.html と error.html を利用した公開とエラー対応
3. **Outputs.tf の活用**
   - ウェブサイト URL を自動出力、アクセス確認が容易
4. **スケーラビリティ**
   - S3 は自動でトラフィック増加に対応、高可用性で安定運用

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- Visual Studio Code セットアップ
- variables.tf と terraform.tfvars 作成
- main.tf 作成（S3 バケット、オブジェクト、公開設定）
- outputs.tf 作成（ウェブサイト URL 出力）
- Terraform 実行（init → plan → apply）
- AWS Console でリソース確認
- ブラウザでウェブサイトアクセス
- エラーページ確認（error.html）
- Terraform destroy による削除

### Task 2: Setup Visual Studio Code
1. デスクトップに `task_10002_s3` フォルダ作成
2. Visual Studio Code を起動 → New Window
3. File → Open → `task_10002_s3` フォルダを開く

### Task 3: Create variables file
1. File → New File → Ctrl + S → `variables.tf` 保存
2. 以下を貼り付け

variable "access_key" {
  description = "Access key to AWS console"
  type        = string
  sensitive   = true
}
variable "secret_key" {
  description = "Secret key to AWS console"
  type        = string
  sensitive   = true
}
variable "region" {
  description = "Region of AWS VPC"
  type        = string
}

3. terraform.tfvars ファイル作成、以下を貼り付け

region = "us-east-1"                
access_key = "<YOUR AWS CONSOLE ACCESS ID>"             
secret_key = "<YOUR AWS CONSOLE SECRET KEY>"

### Task 4: Create main.tf
- AWS プロバイダ設定、S3 バケット作成、HTMLファイルアップロード、公開ポリシー設定

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
} 
resource "aws_s3_bucket" "bucket" {
  bucket        = "mybucket-${random_string.random.result}"
  force_destroy = true
}
resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document { suffix = "index.html" }
  error_document { key = "error.html" }
}
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_object" "upload_object" {
  for_each     = fileset("html/", "*")
  bucket       = aws_s3_bucket.bucket.id
  key          = each.value
  source       = "html/${each.value}"
  etag         = filemd5("html/${each.value}")
  content_type = "text/html"
}
resource "aws_s3_bucket_policy" "read_access_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

### Task 4: Create outputs.tf
output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.blog.website_endpoint
}

### Task 5: Confirm Terraform Installation
- Terminal 開き `terraform version` 実行
- バージョン確認できない場合はインストール

### Task 6: Apply Terraform Configurations
- `terraform init` → `terraform plan` → `terraform apply`
- `yes` を入力してリソース作成承認
- 作成されたリソース ID を確認可能

### Task 7: Check Resources in AWS Console
- S3 バケットを確認、`index.html` と `error.html` が存在
- Properties → Static website hosting → URL コピー → `<endpoint>/index.html` でアクセス
- 存在しないページ（例: home.html）で `error.html` 表示を確認

### Task 9: Delete AWS Resources
- Terminal 開き `terraform destroy` 実行、`yes` 入力
- 作成したリソースをすべて削除

## Completion and Conclusion
- Visual Studio Code セットアップ完了
- variables.tf, terraform.tfvars, main.tf, outputs.tf 作成完了
- Terraform 実行による S3 バケット作成、HTMLアップロード、公開設定完了
- ウェブサイト URL をブラウザで確認
- Terraform destroy によるリソース削除完了