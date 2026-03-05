# Access S3 from Private EC2 Instance using VPC Endpoint
**所要時間:** 90分  
**AWSリージョン:** US East (N. Virginia)

---

## 1. ラボ概要
このラボでは、プライベートサブネット内の EC2 インスタンスから VPC エンドポイント経由で S3 バケットへアクセスする方法を学習します。  
Bastion ホストを経由してプライベート EC2 に SSH 接続する方法と、VPC エンドポイントを使った安全な S3 アクセスを理解します。

---

## 2. タスク概要
1. AWS マネジメントコンソールにサインイン  
2. VPC 作成  
3. インターネットゲートウェイ作成・アタッチ  
4. パブリック / プライベートサブネット作成  
5. パブリックサブネットの自動パブリック IP 割り当て設定  
6. ルートテーブル作成・サブネットにアタッチ  
7. セキュリティグループ作成（Bastion 用・Endpoint 用）  
8. Bastion ホスト作成（パブリック EC2）  
9. Endpoint インスタンス作成（プライベート EC2）  
10. Bastion 経由で Endpoint インスタンスに SSH 接続  
11. VPC エンドポイント作成（S3 用）  
12. プライベート EC2 から S3 バケット・オブジェクト確認  
13. ラボ完了とリソース削除  

---

## 3. ラボ手順

### 3.1 VPC 作成
1. **VPC** サービスを開き、左メニューの **Your VPCs → Create VPC** をクリック  
2. 「VPC only」を選択  
3. 名前タグに任意の名前、IPv4 CIDR ブロックに適当な範囲を入力  
4. デフォルト設定で **Create VPC** をクリック  

---

### 3.2 インターネットゲートウェイ作成・アタッチ
1. 左メニュー **Internet Gateways → Create internet gateway**  
2. 作成後、**Actions → Attach to VPC → 作成した VPC** を選択  

---

### 3.3 サブネット作成
- **パブリックサブネット:**  
  - 名前: 任意  
  - CIDR: 適当な範囲  
  - AZ: 適当な AZ  
- **プライベートサブネット:**  
  - 名前: 任意  
  - CIDR: 適当な範囲  
  - AZ: 適当な AZ  

---

### 3.4 パブリックサブネットの自動パブリック IP 割り当て
1. Public subnet を選択  
2. **Actions → Edit subnet settings**  
3. **Enable auto-assign public IPv4 address** にチェック  
4. **Save**  

---

### 3.5 ルートテーブル作成
- **PublicRouteTable:** パブリックサブネット用  
  - ルート追加: `0.0.0.0/0` → 作成したインターネットゲートウェイ  
- **PrivateRouteTable:** プライベートサブネット用  
- 各サブネットを対応するルートテーブルにアタッチ  

---

### 3.6 セキュリティグループ作成
- **Bastion 用:** SSH / HTTP / HTTPS 許可（Source: Anywhere）  
- **Endpoint 用:** SSH 許可（Source: Bastion 用のセキュリティグループ）  

---

### 3.7 Bastion ホスト作成（パブリック EC2）
- 名前: 任意  
- AMI: Amazon Linux 2023 (kernel-6.1)  
- Instance Type: t2.micro  
- Key pair: 新規作成、.pem 形式  
- VPC: 作成した VPC  
- Subnet: パブリックサブネット  
- Security group: Bastion 用  
- Launch → Status が Running になるまで待機  

---

### 3.8 Endpoint インスタンス作成（プライベート EC2）
- 名前: 任意  
- AMI: Amazon Linux 2023 (kernel-6.1)  
- Instance Type: t2.micro  
- Key pair: 既存の Bastion 用と同じキー  
- VPC: 作成した VPC  
- Subnet: プライベートサブネット  
- Security group: Endpoint 用  
- Launch → Status が Running になるまで待機  

---

### 3.9 Bastion 経由で Endpoint に SSH 接続
1. Bastion に SSH 接続  
2. Bastion に .pem キーをコピー  
3. 権限設定: `chmod 400 <キー名>.pem`  
4. Endpoint インスタンスに SSH 接続  

---

### 3.10 VPC エンドポイント作成（S3 用）
1. **VPC → Endpoints → Create endpoints**  
2. Service category: `AWS services`  
3. Service name: `com.amazonaws.us-east-1.s3`  
4. Endpoint Type: Gateway  
5. VPC: 作成した VPC  
6. Route Table: PrivateRouteTable を選択  
7. Create endpoint → 完了後リストに表示  

---

### 3.11 プライベート EC2 から S3 バケット・オブジェクト確認
1. Endpoint インスタンスで AWS CLI 設定:  

## 3.12 プライベート EC2 から S3 バケット・オブジェクト確認

# AWS VPC NACL Lab - Case Study
**所要時間:** 60分  
**AWSリージョン:** US East (N. Virginia)

---

## 1. ラボ概要
このラボでは、カスタム NACL を作成し、パブリックおよびプライベートサブネットに適用してトラフィック制御を学習します。  
AWS VPC のネットワーク構成、NACL の仕組み、インバウンド / アウトバウンドルールの効果を理解します。

---

## 2. タスク概要
1. AWS マネジメントコンソールにサインイン  
2. VPC 作成  
3. パブリック / プライベートサブネット作成  
4. インターネットゲートウェイ作成・アタッチ  
5. ルートテーブル作成・サブネットにアタッチ  
6. パブリックサブネットの自動パブリック IP 割り当て設定  
7. パブリック / プライベート EC2 インスタンス作成  
8. カスタム NACL 作成・サブネットにアタッチ  
9. インバウンド / アウトバウンドルール設定  
10. EC2 インスタンス間通信テスト  
11. ラボ完了とリソース確認

---

## 3. ラボ手順

### 3.1 VPC 作成
1. VPC サービスを開き、左メニューの **Your VPCs → Create VPC** をクリック  
2. 「VPC only」を選択  
3. 名前タグ: 任意  
4. IPv4 CIDR ブロック: 10.0.0.0/16  
5. デフォルト設定で **Create VPC** をクリック

### 3.2 サブネット作成
- **パブリックサブネット:**  
  - 名前: MyPublicSubnet  
  - CIDR: 10.0.1.0/24  
  - AZ: us-east-1a  
- **プライベートサブネット:**  
  - 名前: MyPrivateSubnet  
  - CIDR: 10.0.2.0/24  
  - AZ: us-east-1b

### 3.3 インターネットゲートウェイ作成・アタッチ
1. 左メニュー **Internet Gateways → Create internet gateway**  
2. 名前タグ: MyInternetGateway  
3. 作成後 **Actions → Attach to VPC → MyVPC** を選択

### 3.4 ルートテーブル作成・サブネットアタッチ
- **PublicRouteTable:**  
  - ルート: `0.0.0.0/0` → MyInternetGateway  
  - サブネットアタッチ: MyPublicSubnet  
- **PrivateRouteTable:**  
  - サブネットアタッチ: MyPrivateSubnet

### 3.5 パブリックサブネットの自動パブリック IP 割り当て
1. MyPublicSubnet を選択  
2. **Actions → Edit subnet settings**  
3. **Enable auto-assign public IPv4 address** にチェック  
4. **Save**

### 3.6 EC2 インスタンス作成
- **パブリック EC2 (MyPublicEC2Server)**  
  - AMI: Amazon Linux 2023 (kernel-6.1)  
  - Instance Type: t2.micro  
  - Key pair: 新規作成  
  - Security group: SSH / HTTP 許可
- **プライベート EC2 (MyPrivateEC2Server)**  
  - AMI: Amazon Linux 2023 (kernel-6.1)  
  - Instance Type: t2.micro  
  - Key pair: 既存のパブリック EC2 キー  
  - Security group: SSH / ICMP 許可

### 3.7 カスタム NACL 作成・アタッチ
1. **VPC → Network ACLs → Create NACL**  
2. パブリック NACL: MyPublicNACL  
3. プライベート NACL: MyPrivateNACL  
4. パブリック NACL をパブリックサブネットにアタッチ  
5. プライベート NACL をプライベートサブネットにアタッチ

### 3.8 NACL ルール設定
- **インバウンドルール (MyPublicNACL)**  
  - HTTP(80) Allow  
  - ALL ICMP-IPv4 Allow  
  - SSH(22) Allow
- **アウトバウンドルール (MyPublicNACL)**  
  - Custom TCP 1024-65535 Allow  
  - ALL ICMP-IPv4 Allow  
  - SSH(22) Allow

### 3.9 EC2 インスタンス間通信テスト
1. パブリック EC2 に SSH 接続  
2. プライベート EC2 の Private IP に ping 実行  
3. カスタム NACL のルールによって通信確認

---

## 4. ポイント
- カスタム NACL によるサブネットレベルのトラフィック制御を理解  
- インバウンド / アウトバウンドルールの順序や優先度の重要性  
- パブリック / プライベート EC2 間通信で NACL の影響を確認  
- デフォルト NACL とカスタム NACL の違いを理解  

---

## 5. 学習成果
- VPC とサブネットの作成・構成理解  
- パブリック / プライベート EC2 のネットワーク接続理解  
- カスタム NACL の作成・ルール設定手順理解  
- AWS VPC のネットワークセキュリティ強化方法の理解

# Peer VPC with Transit Gateway and its Components
**所要時間:** 1時間15分  
**AWSリージョン:** US East (N. Virginia)

---

## 1. ラボ概要
このラボでは、Transit Gateway を使用して 2 つの VPC をピアリングする方法を学習します。  
パブリックおよびプライベートサブネットを持つ VPC を作成し、EC2 インスタンスを起動、Transit Gateway を通じて相互通信を確認します。

---

## 2. タスク概要
1. AWS マネジメントコンソールにサインイン  
2. First VPC 作成（パブリックサブネット付き）  
3. Second VPC 作成（プライベートサブネット付き）  
4. パブリックサブネットに EC2 作成  
5. プライベートサブネットに EC2 作成  
6. Transit Gateway 作成  
7. Transit Gateway Attachment を両 VPC に作成  
8. 各 VPC のルートテーブルに Transit Gateway ルート追加  
9. EC2 インスタンス間の通信確認  
10. ラボ完了とリソース削除

---

## 3. ラボ手順

### 3.1 First VPC 作成
1. **VPC → Your VPCs → Create VPC** をクリック  
2. 「VPC only」を選択  
3. 名前タグ: `First_VPC`  
4. IPv4 CIDR: `10.0.0.0/24`  
5. デフォルト設定で **Create VPC** をクリック  
6. VPC ID を控える  
7. **Actions → Edit VPC Settings** で DNS Resolution と DNS Hostnames を有効化  

---

### 3.2 パブリックサブネット作成
- 名前: `Public_subnet_first_VPC`  
- CIDR: `10.0.0.0/25`  
- AZ: No Preference  

---

### 3.3 インターネットゲートウェイ作成・アタッチ
1. **Internet Gateways → Create Internet Gateway**  
2. 名前: `IGW`  
3. 作成後 **Actions → Attach to VPC → First_VPC**  

---

### 3.4 パブリックルートテーブル作成・サブネットアタッチ
- 名前: `PublicRT`  
- VPC: `First_VPC`  
- サブネット: `Public_subnet_first_VPC` にアタッチ  
- ルート追加: `0.0.0.0/0` → 作成した IGW  

---

### 3.5 パブリック EC2 インスタンス作成
- 名前: `First_VPC_EC2`  
- AMI: Amazon Linux 2023 (kernel-6.1)  
- Instance Type: `t2.micro`  
- Key Pair: 新規作成 `ec2_ssh_key` (.pem)  
- VPC: `First_VPC`  
- Subnet: `Public_subnet_first_VPC`  
- Auto-assign Public IP: Enable  
- Security Group: SSH / HTTP / HTTPS 許可  
- IAM Role: 必要に応じて設定  
- User Data: Apache インストールと簡易 HTML ページ作成  

```bash
#!/bin/bash
sudo dnf update -y
sudo dnf install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<html><h1>Welcome to the Public Server</h1></html>" > /var/www/html/index.html

### 3.6 Second VPC 作成
1. **VPC → Your VPCs → Create VPC** を開く  
2. 名前タグ: `Second_VPC`  
3. IPv4 CIDR: `20.0.0.0/24`  
4. デフォルト設定で作成  
5. DNS Resolution と DNS Hostnames を有効化  

---

### 3.7 プライベートサブネット作成
- 名前: `Private_subnet_second_VPC`  
- CIDR: `20.0.0.0/25`  
- AZ: No Preference  

---

### 3.8 プライベート EC2 インスタンス作成
- 名前: `Second_VPC_EC2`  
- AMI: Amazon Linux 2023 (kernel-6.1)  
- Instance Type: `t2.micro`  
- Key Pair: 既存の `ec2_ssh_key`  
- VPC: `Second_VPC`  
- Subnet: `Private_subnet_second_VPC`  
- Auto-assign Public IP: Disable  
- Security Group: SSH 許可  
- Launch → Running 状態になるまで待機  

---

### 3.9 Transit Gateway 作成
- 名前: `DemoTG`  
- Description: `Transit Gateway for peering VPCs`  
- デフォルト設定で **Create Transit Gateway**  
- 利用可能になるまで待機  

---

### 3.10 Transit Gateway Attachment 作成
- **First VPC Attachment:**  
  - 名前: `First_VPC_TGA`  
  - Transit Gateway: `DemoTG`  
  - VPC: `First_VPC`  
- **Second VPC Attachment:**  
  - 名前: `Second_VPC_TGA`  
  - Transit Gateway: `DemoTG`  
  - VPC: `Second_VPC`  

---

### 3.11 VPC ルートテーブルに Transit Gateway ルート追加
- **First VPC (PublicRT)**  
  - Destination: `20.0.0.0/24` → Target: `DemoTG`  
- **Second VPC (Default Route Table)**  
  - Destination: `10.0.0.0/24` → Target: `DemoTG`  

---

### 3.12 VPC 間通信確認
1. First VPC の EC2 に Session Manager で接続
2. Root に切り替え:
   - `sudo su`
3. Private EC2 用の .pem キーを作成・権限設定:
   - `chmod 400 ec2_ssh_key.pem`
4. Private EC2 に SSH 接続:
   - `ssh ec2-user@<Second_VPC Private IP> -i ec2_ssh_key.pem`
5. 接続確認
   - Transit Gateway 経由で通信が成功していることを確認

---

## 4. ポイント
- Transit Gateway により **VPC 間通信が容易に実現**
- **ルートテーブルへの適切なルート追加** が通信成功のカギ
- **パブリック / プライベートサブネット構成の理解**
- **スケーラブルで柔軟なネットワーク設計** が可能

---

## 5. 学習成果
- パブリック / プライベート VPC と EC2 の作成・構成を理解
- Transit Gateway の作成および Attachment の理解
- VPC 間通信テストの手順を習得
- スケーラブルな VPC ピアリング構成の理解

