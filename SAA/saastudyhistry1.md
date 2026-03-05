# AWS学習記録

## 2026-03-03

---

### IAMラボ（ユーザー・グループ作成）

- 学習時間: 約30分  
- 演習内容:
  1. **IAMユーザー作成**
     - ユーザー: ユーザーA, ユーザーB（開発チーム用）、ユーザーC, ユーザーD（HRチーム用）
     - コンソールアクセス用パスワード設定
     - タグ設定: 開発チーム → Developers、HRチーム → HR
  2. **IAMグループ作成**
     - 開発チーム: ユーザーA, ユーザーB を追加
       - ポリシー: AmazonEC2ReadOnlyAccess, AmazonS3ReadOnlyAccess
     - HRチーム: ユーザーC, ユーザーD を追加
       - ポリシー: Billing
  3. **ポリシー割当**
     - グループ作成時にポリシーを添付
     - ユーザーは所属グループの権限を継承
  4. **Access Analyzer確認**
     - IAMポリシーのアクセス権を自動解析
     - 推奨設定や不要アクセスの通知を確認
- 理解度: 80%  
- メモ:
  - IAMユーザー・グループ作成と権限設定の流れを理解
  - Access Analyzer によるセキュリティ確認の重要性を把握

---

### NAT Gatewayラボ学習内容

- 学習時間: 約1時間30分  
- リージョン: US East (N. Virginia)  

#### 1. VPC作成
- 名前: VPC-1  
- IPv4 CIDR: 10.0.0.0/16  
- Tenancy: Default  

#### 2. サブネット作成
- **パブリックサブネット**: PublicSubnet-1  
  - CIDR: 10.0.0.0/24  
  - Auto-assign public IP: Enabled  
- **プライベートサブネット**: PrivateSubnet-1  
  - CIDR: 10.0.1.0/24  
  - Auto-assign public IP: Disabled  

#### 3. インターネットゲートウェイ作成
- 名前: IGW-1  
- VPC-1 にアタッチ  

#### 4. パブリックルートテーブル作成
- 名前: PublicRT-1  
- ルート: 0.0.0.0/0 → IGW-1  
- PublicSubnet-1 に関連付け  

#### 5. EC2起動
- **パブリック EC2**: PublicServer-1
  - AMI: Amazon Linux 2023
  - インスタンスタイプ: t2.micro
  - セキュリティグループ: SG-1 (SSH許可)
  - 公開 IP 有効
- **プライベート EC2**: PrivateServer-1
  - AMI: Amazon Linux 2023
  - インスタンスタイプ: t2.micro
  - セキュリティグループ: SG-1
  - 公開 IP 無効
  - プライベート IP: 10.0.1.45

#### 6. SSH接続確認
- パブリック EC2 からプライベート EC2 に接続
- root に切り替え: `sudo su`
- パブリック EC2: `yum -y update` → 成功
- プライベート EC2: `yum -y update` → 失敗（直接インターネット未接続）

#### 7. NAT Gateway作成
- 名前: NATGW-1
- VPC: VPC-1
- 接続タイプ: Public
- Elastic IP 割当: Automatic
- パブリックサブネット内に作成
- ステータス **available** になるまで待機

#### 8. プライベートルートテーブル更新
- PrivateRT-1 にルート追加: 0.0.0.0/0 → NATGW-1
- 保存して更新完了

#### 9. 接続確認
- プライベート EC2 で再度 `yum -y update` 実行
- NAT Gateway 経由で **インターネット接続成功**

#### 学習成果
- VPC、サブネット、インターネットゲートウェイ、ルートテーブル、NAT Gateway作成手順を理解  
- パブリック／プライベートサブネットの違いとアクセス制御の仕組みを把握  

---

### Build Amazon VPC with Public and Private Subnets (from Scratch)

- 学習時間: 約30分  
- リージョン: US East (N. Virginia)  

#### 1. VPC作成
- 名前: VPC-2  
- IPv4 CIDR: 10.0.0.0/16  
- Tenancy: Default  

#### 2. サブネット作成
- **パブリックサブネット**: PublicSubnet-2  
  - CIDR: 10.0.1.0/24  
  - AZ: us-east-1a  
  - Auto-assign public IP: Enabled  
- **プライベートサブネット**: PrivateSubnet-2  
  - CIDR: 10.0.2.0/24  
  - AZ: us-east-1b  
  - Auto-assign public IP: Disabled  

#### 3. インターネットゲートウェイ作成
- 名前: IGW-2  
- VPC-2 にアタッチ  

#### 4. ルートテーブル作成
- PublicRT-2: パブリックサブネットに関連付け  
  - ルート: 0.0.0.0/0 → IGW-2  
- PrivateRT-2: プライベートサブネットに関連付け  
  - ルートは未設定（NAT Gateway で設定可能）  

#### 5. サブネットとルートテーブルの関連付け
- PublicSubnet-2 → PublicRT-2  
- PrivateSubnet-2 → PrivateRT-2  
- Main Route Table には関連付けなし  

#### 6. 補足
- パブリックサブネット内のインスタンスはインターネットアクセス可能  
- プライベートサブネット内のインスタンスは NAT Gateway 経由でアクセス可能  
- VPC Flow Logs によりネットワークトラフィックの解析やセキュリティ監視が可能

---

### EC2ラボ学習内容

- 学習時間: 約1時間  
- リージョン: US East (N. Virginia)  

#### 1. デフォルトVPCの準備
- 既存のデフォルトVPCを削除
- `Create default VPC`で再作成

#### 2. EC2インスタンス作成
- 名前: EC2Server-1
- AMI: Amazon Linux 2023
- インスタンスタイプ: t2.micro
- キーペア: 作成したキーペア (RSA, .pem)
- セキュリティグループ: SG-EC2
  - SSH 許可
  - HTTP 許可 (Anywhere)
- Auto-assign public IP: Enabled

#### 3. SSH接続
- ブラウザまたはターミナルでSSH接続
- root に切り替え: `sudo su`

#### 4. システム更新
- コマンド: `dnf update -y`
- パッケージとセキュリティ更新を最新化

#### 5. Apacheサーバーのインストールと起動
- インストール: `dnf install httpd -y`
- サービス起動: `systemctl start httpd`
- 自動起動設定: `systemctl enable httpd`
- ステータス確認: `systemctl status httpd`
- ブラウザで Public IPv4 アドレスを入力して Apache テストページ確認

#### 6. ウェブページ作成と公開
- index.html にコンテンツを追加:
```bash
echo "<html>Hello, this is a public page</html>" > /var/www/html/index.html