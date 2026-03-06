# Create a 2 Tier Amazon VPC using Terraform

## 概要
- **サービス内容**：Terraform を使用して AWS のネットワーク環境（VPC）をコードで構築する（Infrastructure as Code）
- **ラボ完了内容**
  - Terraform の設定ファイル（variables.tf / terraform.tfvars / main.tf）を作成
  - Terraform CLI を使って AWS リソースを自動作成
  - VPC、Subnets、Route Tables、Internet Gateway を作成
  - AWS コンソールでリソース確認
  - terraform destroy で環境削除

---

# ポイント

## 1. Infrastructure as Code (IaC) の理解

Terraformを使うと、AWSインフラを**コードとして定義・管理**できる。

### メリット

- 手動構築ミスを防止
- 環境の再現性が高い
- インフラ構築を自動化
- Gitでバージョン管理可能

---

## 2. Terraformの基本構成ファイル

Terraformでは主に **3つのファイル**を使用する。

### variables.tf
変数を定義するファイル

```hcl
variable "access_key" {
  description = "Access key to AWS console"
}

variable "secret_key" {
  description = "Secret key to AWS console"
}

variable "region" {
  description = "AWS region"
}
```

---

### terraform.tfvars
変数に値を設定するファイル

```hcl
region = "us-east-1"
access_key = "YOUR_ACCESS_KEY"
secret_key = "YOUR_SECRET_KEY"
```

---

### main.tf
AWSリソースを定義するメイン設定ファイル

```hcl
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```

---

## 3. Terraformで作成したAWSリソース

このラボでは以下のAWSリソースを作成した。

- VPC
- Internet Gateway
- Route Table
- Subnets（各 Availability Zone）

### VPC CIDR

```
10.0.0.0/16
```

---

## 4. VPC作成

```hcl
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}
```

---

## 5. Internet Gateway作成

```hcl
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}
```

---

## 6. Route設定

すべてのインターネット通信をInternet Gatewayへルーティングする。

```hcl
resource "aws_route" "route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}
```

---

## 7. Availability Zone取得

Terraformでは **dataソース**を使ってAZを取得できる。

```hcl
data "aws_availability_zones" "available" {}
```

取得例

- us-east-1a
- us-east-1b
- us-east-1c

---

## 8. Subnet自動作成

Terraformの **count** を使ってAZごとにサブネットを作成する。

```hcl
resource "aws_subnet" "main" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
}
```

### 生成されるCIDR例

```
10.0.0.0/24
10.0.1.0/24
10.0.2.0/24
```

---

# Terraformコマンド

## インストール確認

```bash
terraform version
```

Terraformがインストールされていない場合

```
command not found: terraform
```

と表示される。

---

## ディレクトリ移動

```bash
cd task_10000_vpc
```

---

## 初期化

```bash
terraform init
```

### 処理

- Providerプラグインダウンロード
- Terraform実行環境初期化

---

## 実行計画確認

```bash
terraform plan
```

### 目的

- 作成予定のAWSリソース確認
- 実行前に変更内容チェック

---

## リソース作成

```bash
terraform apply
```

```
Enter a value: yes
```

### 処理

- main.tf の設定を元に
- AWSリソースを作成

作成時間：約2分

---

## リソース削除

```bash
terraform destroy
```

```
Enter a value: yes
```

Terraformで作成したリソースをすべて削除。

---

# AWSコンソール確認

## VPC確認

AWS Console

```
Services
 → Networking & Content Delivery
 → VPC
 → Your VPCs
```

Custom VPC が作成されている。

---

## Subnets確認

```
VPC
 → Subnets
```

Filter

```
VPC ID = Custom VPC
```

---

## 確認できるリソース

- VPC
- Subnets
- Route Tables
- Internet Gateways
- Security Groups

---

# 学習成果

このラボで習得した内容

- Terraformを使ったAWSインフラ構築
- Infrastructure as Code (IaC) の基本
- VPC / Subnet / Route / Internet Gateway の構築
- Availability Zone を利用したサブネット作成
- Terraform CLI操作

```
terraform init
terraform plan
terraform apply
terraform destroy
```

- AWSコンソールでのリソース確認