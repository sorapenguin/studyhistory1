# AWS学習記録

## 2026-03-03

### Understanding and Configuring Layered Security in an AWS VPC

- **学習時間**: 約1時間  
- **リージョン**: US East (N. Virginia)  

---

## 学習内容

### 1. VPC 作成
- 名前: MyVPC  
- IPv4 CIDR: 10.0.0.0/16  
- Tenancy: Default  

### 2. サブネット作成
- **パブリックサブネット**  
  - 名前: PublicSubnet  
  - CIDR: 10.0.1.0/24  
  - AZ: 任意  
  - Auto-assign public IP: Enabled  
- **プライベートサブネット**  
  - 名前: PrivateSubnet  
  - CIDR: 10.0.2.0/24  
  - AZ: 任意  
  - Auto-assign public IP: Disabled  

### 3. インターネットゲートウェイ作成
- 名前: InternetGateway  
- 作成した VPC にアタッチ  

### 4. ルートテーブル作成とサブネット関連付け
- **PublicRouteTable**: パブリックサブネットに関連付け  
  - ルート追加: 0.0.0.0/0 → InternetGateway  
- **PrivateRouteTable**: プライベートサブネットに関連付け  
  - ルートは未設定（必要に応じて NAT Gateway で設定可能）  

### 5. セキュリティグループ作成
- 名前: VPCSecurityGroup  
- インバウンドルール: SSH と ICMP を許可  
- アウトバウンドルール: デフォルト許可  

### 6. ネットワーク ACL 作成
- 名前: VPCNACL  
- インバウンド・アウトバウンドルールに SSH と ICMP を設定  
- パブリック・プライベートサブネットに関連付け  

### 7. EC2 インスタンス作成
- **パブリックインスタンス**  
  - サブネット: PublicSubnet  
  - 自動パブリック IP: Enabled  
  - セキュリティグループ: VPCSecurityGroup  
- **プライベートインスタンス**  
  - サブネット: PrivateSubnet  
  - 自動パブリック IP: Disabled  
  - セキュリティグループ: VPCSecurityGroup  

### 8. EC2 テスト
- パブリックインスタンスからプライベートインスタンスへ ping で疎通確認  

---

## 学習成果
- VPC、サブネット、IGW、ルートテーブル、セキュリティグループ、NACL の作成手順を理解  
- パブリック／プライベートサブネットの違いとアクセス制御の仕組みを把握  
- EC2 インスタンス間の通信テストでネットワーク構成を確認

# AWS学習記録

## 2026-03-03

### Introduction to Amazon CloudFormation (LAMP Server)
- **学習時間**: 約30分  
- **リージョン**: US East (N. Virginia)  

---

## 学習内容

### 1. ラボ環境起動
- Lab 環境を起動し、IAM ユーザー名、パスワード、アクセスキー、シークレットキーを取得  
- ラボ環境のプロビジョニングに 1 分未満  

### 2. S3 バケット内テンプレート確認
- AWS マネジメントコンソールで S3 に移動  
- バケット内にある `LAMP_template.json` を確認  
- オブジェクト URL をコピーしてメモに保存  

### 3. CloudFormation スタック作成
- CloudFormation コンソールに移動  
- **Create Stack** → **With existing template** → **Amazon S3 URL** を選択  
- コピーしたテンプレート URL を貼り付け  

#### スタック詳細
- Stack Name: `MyLAMPStack`  
- DB Name: `MyDatabase`  
- DB User: `DBUser`  
- DB Password: `DBPassword123`  
- DB Root Password: `DBRootPassword123`  
- Instance Type: `t2.micro`  
- Key Name: 既存のキーペアを選択  
- SSH Location: `0.0.0.0/0`  

#### オプション設定
- タグ: `Name = MyCFStack`  
- 権限はデフォルト  
- 他の設定はデフォルトで Next → Submit  

- スタック作成中は `CREATE_IN_PROGRESS` が表示される  
- 1〜5 分で作成完了 → `CREATE_COMPLETE`  

### 4. LAMP サーバー動作確認
- CloudFormation スタックの **Outputs** タブから URL を取得  
- ブラウザでアクセス → PHP 情報ページとデータベース接続確認  

### 5. 補足
- CloudFormation によるインフラ管理は、手作業を減らし、構成の一貫性を保ち、迅速で信頼性の高いデプロイが可能  
- インフラをコード化することで、同一構成の再現や複製が容易  

---

## 学習成果
- S3 バケットに保存されたテンプレートから CloudFormation スタックを作成する手順を理解  
- LAMP サーバーを自動構築できることを確認  
- CloudFormation によるインフラ構築の効率性と再現性を体験  

# AWS学習記録

## 2026-03-XX

### How to Create Virtual Private Cloud (VPC) with AWS CloudFormation

- **学習時間**: 約55分  
- **リージョン**: US East (N. Virginia)

---

## 学習概要

このラボでは、AWS CloudFormation を使用して VPC を作成し、最初は 2 サブネットの VPC を作成し、後に 2 AZ に跨る 4 サブネット構成の VPC に更新する手順を学習します。

---

## 学習内容

### 1. CloudFormation を使った VPC 作成 (VPC_Template)

1. **S3 バケットからテンプレート取得**
   - バケット内の `VPC_template.json` を選択
   - オブジェクト URL をコピー

2. **CloudFormation スタック作成**
   - テンプレート: S3 URL
   - スタック名: `MyStack`
   - タグ: Name → `MyCF`
   - 他のオプションはデフォルト
   - 作成後、ステータスが `CREATE_COMPLETE` になるまで待機

3. **VPC リソース確認**
   - サービス → VPC で作成済みリソース確認
   - パブリックサブネット 1、プライベートサブネット 1 が作成済み
   - パブリックルートテーブルとプライベートルートテーブルの関連付け完了

---

### 2. CloudFormation を使った VPC 更新 (VPC_II_Template)

1. **S3 バケットからテンプレート取得**
   - バケット内の `VPC_II_template.json` を選択
   - オブジェクト URL をコピー

2. **既存スタック更新**
   - スタック選択: `MyStack`
   - 「Update stack」 → 「Replace existing template」
   - S3 URL をペースト
   - パラメータ変更なし、タグ変更なし
   - ステータスが `UPDATE_COMPLETE` になるまで待機

3. **VPC 構成**
   - VPC 名: `Lab VPC`（既存 VPC と同名）
   - サブネット (2 AZ に拡張)
     - Public Subnet 1: 10.0.0.0/24 (AZ-1)
     - Private Subnet 1: 10.0.1.0/24 (AZ-1)
     - Public Subnet 2: 10.0.2.0/24 (AZ-2)
     - Private Subnet 2: 10.0.3.0/24 (AZ-2)
   - インターネットゲートウェイを VPC にアタッチ
   - 公開サブネット → 公開ルートテーブル
   - プライベートサブネット → プライベートルートテーブル
   - 更新後、新しいリソースが追加される

---

### 3. ポイント

- 既存スタックの更新で複数 AZ 対応 VPC を作成  
- サブネットを AZ ごとに分けることで可用性と冗長性を確保  
- CloudFormation のカスタムリソースを活用することで Lambda などを使った独自リソースの作成も可能  
- テンプレート理解により、インフラ自動化と再現性が向上

---

### 4. 学習成果

- CloudFormation テンプレートで VPC を作成・更新する手順を理解  
- パブリック / プライベートサブネットの構成とルートテーブル関連付けを理解  
- CloudFormation の Stack と Template の仕組みを理解  

### 1. CloudFormation を使った VPC 作成 (VPC_Template)

1. **S3 バケットからテンプレート取得**
   - バケット内の `VPC_template.json` を選択
   - オブジェクト URL をコピー

2. **CloudFormation スタック作成**
   - CloudFormation サービス → 「Create Stack」 → 「Choose an existing template」
   - S3 URL を指定
   - スタック名: `MyStack`
   - タグ追加: Name = `MyCF`
   - その他設定はデフォルト
   - ステータスが `CREATE_COMPLETE` になるまで待機

3. **VPC 構成**
   - VPC 名: `Lab VPC`
   - CIDR: 10.0.0.0/16
   - インターネットゲートウェイを作成し VPC にアタッチ
   - サブネット
     - Public Subnet 1: 10.0.0.0/24 (AZ-1)
     - Private Subnet 1: 10.0.1.0/24 (AZ-1)
   - ルートテーブル
     - 公開サブネット → 公開ルートテーブル
     - プライベートサブネット → プライベートルートテーブル

---

### 2. CloudFormation を使った VPC 更新 (VPC_II_Template)

1. **S3 バケットからテンプレート取得**
   - バケット内の `VPC_II_template.json` を選択
   - オブジェクト URL をコピー

2. **既存スタック更新**
   - スタック選択: `MyStack`
   - 「Update stack」 → 「Replace existing template」
   - S3 URL をペースト
   - パラメータ変更なし、タグ変更なし
   - ステータスが `UPDATE_COMPLETE` になるまで待機

3. **VPC 構成**
   - VPC 名: `Lab VPC`（既存 VPC と同名）
   - サブネット (2 AZ に拡張)
     - Public Subnet 1: 10.0.0.0/24 (AZ-1)
     - Private Subnet 1: 10.0.1.0/24 (AZ-1)
     - Public Subnet 2: 10.0.2.0/24 (AZ-2)
     - Private Subnet 2: 10.0.3.0/24 (AZ-2)
   - インターネットゲートウェイを VPC にアタッチ
   - 公開サブネット → 公開ルートテーブル
   - プライベートサブネット → プライベートルートテーブル
   - 更新後、新しいリソースが追加される

---

### 3. ポイント

- 既存スタックの更新で複数 AZ 対応 VPC を作成  
- サブネットを AZ ごとに分けることで可用性と冗長性を確保  
- CloudFormation のカスタムリソースを活用することで Lambda などを使った独自リソースの作成も可能  
- テンプレート理解により、インフラ自動化と再現性が向上

---

### 4. 学習成果

- CloudFormation テンプレートで VPC を作成・更新する手順を理解  
- パブリック / プライベートサブネットの構成とルートテーブル関連付けを理解  
- CloudFormation の Stack と Template の仕組みを理解

# Introduction to Creating AWS VPC Flow Logs
**所要時間:** 45分  
**AWSリージョン:** US East (N. Virginia)

---

## 1. ラボ概要
このラボでは、VPC フローログの作成手順を学習します。  
VPC フローログを利用することで、VPC 内外の IP トラフィック情報（送信元・宛先 IP アドレス、ポート、プロトコル、パケット数など）を収集できます。  

本ラボでは、AWS VPC と VPC フローログの操作を実践します。

---

## 2. タスク概要
1. AWS マネジメントコンソールにサインイン  
2. CloudWatch ログの作成  
3. VPC の作成  
4. VPC フローログの作成  

---

## 3. ラボ手順

### 3.1 CloudWatch ログの作成
1. サービスメニューから **CloudWatch** を選択  
2. 左メニューの **ログ管理** → **ロググループの作成** をクリック  
3. ロググループ名を入力（例: `vpclogs`）  
4. **作成** をクリック  
> 注: CloudWatch メトリクス取得エラーは無視して構いません

---

### 3.2 VPC の作成
1. サービスメニューから **VPC** を選択  
2. 左メニューの **Your VPCs** → **Create VPC**  
3. 「VPC only」を選択  
4. 名前タグに任意の名前（例: `myvpc`）を入力  
5. IPv4 CIDR ブロックを入力（例: `10.1.0.0/16`）  
6. その他の設定はデフォルトのまま **Create** をクリック  

---

### 3.3 VPC フローログの作成
1. 作成した VPC を選択  
2. 下部タブの **Flow Logs** → **Create Flow Log** をクリック  
3. Flow Log 設定:
   - 名前: 任意（例: `vpcflow`）  
   - フィルター: `Accept`  
   - 宛先: CloudWatch Logs → 作成済みロググループを選択  
   - IAM ロール: デフォルト（例: `VPCFlowLogXYZ`）  
4. その他の設定はデフォルトのまま **Create flow log** をクリック  

> Flow Logs が作成されたら、**Flow Logs** タブで確認可能

---

## 4. ポイント

- VPC フローログでネットワーク監視、セキュリティ分析、トラブルシューティング、性能分析が可能  
- CloudWatch ログを宛先にすることで、ログ管理と分析が容易  
- フローログは送受信トラフィックを詳細に可視化できるため、VPC の運用やセキュリティ強化に有効  

---

## 5. 学習成果

- CloudWatch ログの作成手順を理解  
- VPC の作成手順を理解  
- VPC フローログの作成手順を理解  
- AWS VPC のネットワーク可視化と監視の基礎を理解  

---

## 6. ラボ終了
1. AWS マネジメントコンソールからサインアウト  
2. ラボ環境の **End Lab** をクリックして終了

# AWS学習記録

## Access S3 from Private EC2 Instance using VPC Endpoint
**所要時間:** 1時間30分  
**AWSリージョン:** US East (N. Virginia)

---

## 1. ラボ概要
このラボでは、プライベートサブネット内の EC2 インスタンスから VPC エンドポイント経由で Amazon S3 にアクセスする手順を学習します。

- Bastion ホスト（パブリック EC2）を利用してプライベート EC2 に SSH 接続  
- VPC エンドポイントを作成して S3 に安全にアクセス  
- インターネットを介さずに Amazon ネットワーク内で通信  

---

## 2. ラボ手順

### 2.1 VPC 作成
1. VPC を作成  
   - 名前: 任意  
   - IPv4 CIDR: `192.168.0.0/26`  
   - Tenancy: デフォルト  

### 2.2 インターネットゲートウェイ作成とアタッチ
1. インターネットゲートウェイを作成  
2. VPC にアタッチ  

### 2.3 パブリックサブネットとプライベートサブネット作成
- **パブリックサブネット**  
  - CIDR: `192.168.0.1/27`  
  - 自動パブリック IP 有効化  
- **プライベートサブネット**  
  - CIDR: `192.168.0.32/27`  
  - 自動パブリック IP 無効  

### 2.4 ルートテーブル作成とサブネット関連付け
- パブリック用ルートテーブル → パブリックサブネット  
  - ルート: `0.0.0.0/0` → インターネットゲートウェイ  
- プライベート用ルートテーブル → プライベートサブネット  
- メインルートテーブルには関連付けない  

### 2.5 セキュリティグループ作成
- **Bastion-SG**: SSH、HTTP、HTTPS 許可（ソース: どこからでも）  
- **Endpoint-SG**: SSH 許可（ソース: Bastion-SG のみ）  

### 2.6 Bastion ホスト作成（パブリック EC2）
1. AMI: Amazon Linux 2023  
2. インスタンスタイプ: t2.micro  
3. VPC: 作成済み VPC  
4. サブネット: パブリックサブネット  
5. セキュリティグループ: Bastion-SG  
6. キーペア作成（RSA, .pem）  

### 2.7 Endpoint インスタンス作成（プライベート EC2）
1. AMI: Amazon Linux 2023  
2. インスタンスタイプ: t2.micro  
3. VPC: 作成済み VPC  
4. サブネット: プライベートサブネット  
5. セキュリティグループ: Endpoint-SG  
6. 既存キーペアを使用  

### 2.8 Bastion ホスト経由で Endpoint に SSH 接続
1. Bastion ホストにキーファイルをコピー  
2. 権限を 400 に設定: `chmod 400 WhizKey.pem`  
3. SSH 接続:  
   ```bash
   ssh -i WhizKey.pem ec2-user@<Endpoint-Private-IP>
## 2.9 VPC エンドポイント作成（S3）

1. VPC コンソール → **Endpoints** → **Create Endpoint**  
2. サービスカテゴリ: AWS services  
3. Service name: `com.amazonaws.<region>.s3`  
4. VPC: 作成済み VPC  
5. Route Table: プライベートサブネット用  
6. 作成後、エンドポイントが一覧に表示される  

## 2.10 S3 バケットの確認

1. プライベート EC2 で `aws configure` を実行  
   - Access Key / Secret Key  
   - Default region: `us-east-1`  
   - Default output: Enter  

2. バケット一覧表示:  
```bash
aws s3 ls

## オブジェクト確認（例: バケット名 mybucket）

```bash
aws s3 ls s3://mybucket
## 3. ポイント

- Bastion ホストはパブリックサブネットにのみ配置し、プライベート EC2 への中継役  
- VPC エンドポイントで S3 へ安全にアクセス可能  
- インターネットを経由せず、Amazon ネットワーク内で通信するためセキュリティ・コスト効率が向上  
- プライベート EC2 から S3 バケットやオブジェクトを直接操作できる  

## 4. 学習成果

- パブリック/プライベートサブネット構成を理解  
- Bastion ホスト経由でプライベート EC2 に SSH 接続可能  
- VPC エンドポイント作成と S3 へのアクセス手順を理解  
- プライベートネットワーク内での安全な AWS サービス利用の概念を理解  

## 5. ラボ終了手順

1. AWS コンソールからサインアウト  
2. ラボダッシュボードから **End Lab** をクリック