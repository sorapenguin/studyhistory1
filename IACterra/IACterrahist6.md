# Create a SNS Topic and Subscribe to Email Service using Terraform

## 概要
このラボでは、Terraform を使って AWS 上に SNS トピックを作成し、メールサブスクリプションを設定する手順を学びます。  
Terraform によりインフラをコード化し、再利用可能な形でリソースを作成・管理することが目的です。

**所要時間:** 60 分  
**AWS リージョン:** US East (N. Virginia) us-east-1

## ポイント
- Terraform を使用して SNS トピックとサブスクリプションを自動作成
- メールサブスクリプションは承認後に有効化
- Terraform による作成 → AWS コンソール確認 → 削除までの一連の流れを学習
- SNS は S3 イベントや CloudWatch アラームなど多様な通知に利用可能

## ラボ手順

```bash
# Task 2: Visual Studio Code のセットアップ
# ターミナルでデスクトップへ移動
cd Desktop
mkdir task_10094_sns
cd task_10094_sns
pwd
# VSCode でフォルダを開く
# Explorer → Open Folder → task_10094_sns
# (必要に応じて Authorize をクリック)

# Task 3: variables.tf と terraform.tfvars の作成
# variables.tf
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

variable "sns_subscription_email" {
  description = "Email endpoint for the SNS subscription"
  type        = string
}

# terraform.tfvars
region = "us-east-1"
access_key = "<YOUR AWS CONSOLE ACCESS ID>"
secret_key = "<YOUR AWS CONSOLE SECRET KEY>"

# Task 4: main.tf の作成
provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

# SNS Topic 作成
resource "aws_sns_topic" "sns_topic" {
    name = "sns-topic"
}

# SNS Subscription 作成
resource "aws_sns_topic_subscription" "sns_subscription" {
    topic_arn = aws_sns_topic.sns_topic.arn
    protocol  = "email"
    endpoint  = var.sns_subscription_email
}

# Task 5: output.tf の作成
output "topic_arn1" {
    value       = aws_sns_topic.sns_topic.arn
    description = "Topic created successfully"
}
output "subscription_arn1" {
    value       = aws_sns_topic_subscription.sns_subscription.arn
    description = "Subscription created successfully. Confirm the subscription on your mail"
}

# Task 6: Terraform バージョン確認
terraform version

# Task 7: Terraform 設定を適用
terraform init
terraform plan
# プロンプトにメールアドレスを入力して plan を確認
terraform apply
# プロンプトにメールアドレスを入力、yes で承認
# リソース作成完了、ARN を確認

# Task 8: メールでのサブスクリプション承認
# メール受信 → "Confirm Subscription" をクリック
# SNS Topic にメールアドレスが登録され、通知受信可能状態に

# Task 9: AWS コンソールでの確認
# SNS → Topics → 作成した Topic を選択
# Subscriptions セクションでサブスクリプションが "Confirmed" 状態であることを確認

# Task 11: AWS リソース削除
terraform destroy
# プロンプトにメールアドレスを入力し、yes を入力
# "Destroy complete!" メッセージで削除完了

## 学習成果

- Terraform による SNS トピック作成とメールサブスクリプションの自動化が理解できた
- サブスクリプション承認の必要性と、承認後に通知が受信可能になることを確認
- AWS コンソールで作成済みリソースを確認し、`terraform destroy` により安全に削除できることを習得
- Terraform を用いた **コード化されたインフラ管理** の基本的な流れを体験