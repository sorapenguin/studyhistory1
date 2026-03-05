# Introduction to Amazon GuardDuty

## 概要
- **サービス内容**：Amazon GuardDuty は AWS アカウント全体の API コール、ネットワークトラフィック、DNS データなどを解析・監視し、潜在的なセキュリティ脅威や異常を特定
- **ラボ完了内容**：
  - GuardDuty の有効化と無効化
  - Settings、Lists、Accounts などのオプションを確認
  - サンプル Findings を生成・確認

## ポイント
1. **脅威検出の理解**
   - GuardDuty がどのようにデータを監視し、潜在的リスクを検出するか体験
2. **サービス探索の学習**
   - 設定やリスト管理、アカウント管理の機能を把握
3. **サンプル Findings での体験**
   - 深刻度や影響リソースを理解し、実運用時の対応判断の基礎を習得
4. **運用上の注意**
   - 必要に応じてサービスを無効化可能
   - 有効化・無効化や設定変更の影響を理解して運用管理

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- GuardDuty を有効化
- サービス画面を探索
- サンプル Findings を生成・確認
- GuardDuty を無効化

### Task 2: Enabling Amazon GuardDuty
1. AWS マネジメントコンソール右上で **US East (N. Virginia, us-east-1)** を選択
2. Services メニュー → Security, Identity and Compliance → GuardDuty
3. 「Get started」をクリック
4. 「Enable GuardDuty」をクリックして有効化
5. Findings ページを確認（初期状態では「No findings」と表示、無視してよい）

### Task 3: Exploring Amazon GuardDuty
#### Settings
- Detector ID：GuardDuty サービスを表すリソース
- Service roles：GuardDuty がデータソースを監視するために使用する IAM ロール
- Findings export options：CloudWatch Events へ自動送信、S3 へのエクスポートも可能（新規 Findings は約5分でエクスポート）
- Suspend GuardDuty：監視を一時停止、新しい Findings は生成されないが既存は保持
- Disable GuardDuty：監視停止＋既存 Findings と設定も削除（復元不可）

#### Lists
- Trusted IP Lists：信頼できる IP。これに含まれる IP は Findings を生成しない
- Threat IP Lists：既知の悪意ある IP。これに含まれる IP は Findings が生成される
- ページが空白の場合は 2～3 回リフレッシュ

#### Accounts
- 他の AWS アカウントを招待して関連付け可能
- 招待送信側は **マスターアカウント**、受信側は **メンバーアカウント**
- マスターアカウントからメンバーの Findings を確認・管理可能（最大 1000 アカウント）

### Task 4: Generating Sample Findings
1. Settings → 下にスクロール → Generate sample findings をクリック
2. 左パネルの Findings を開き、サンプル結果を確認
3. Filter 機能を使って条件に応じた Findings を絞り込み
4. 任意のサンプル Findings をクリックして詳細を確認
   - パラメータ：Severity、Region、Account ID、Resource ID、Resource Affected など
5. 深刻度（Severity）の違いを学び、対応優先度の理解を深める

### Task 5: Validation of the Lab
- 右側パネルの Validation ボタンをクリック
- AWS アカウント内リソースをチェックし、ラボの完了状況を確認

## 学習成果
- GuardDuty の有効化・無効化操作を理解
- Settings、Lists、Accounts の機能を把握
- サンプル Findings を通して脅威の深刻度や影響リソースを理解
- 実運用時の対応判断の基礎を習得

# Discover sensitive data present in S3 bucket using Amazon Macie

## 概要
- **サービス内容**：Amazon Macie は S3 バケット内の機密データを自動で発見、分類、保護するサービス
- **検出対象**：
  - 個人情報（PII）：名前、住所、クレジットカード番号など
  - 財務データ、知的財産など企業独自の機密情報
  - S3 バケット情報：公開設定、暗号化の有無、他アカウントとの共有状況
- **ラボ完了内容**：
  - Macie を有効化
  - Macie ジョブを作成
  - ジョブを実行して S3 バケット内のデータを検出・取得

## ポイント
1. **データ保護と可視化**  
   - バケットの公開状態や暗号化状況を確認し、リスクのあるバケットを特定
2. **カスタムデータ識別子の活用**  
   - 正規表現を用いて独自フォーマットの機密データも検出可能
3. **ジョブ作成と実行**  
   - 特定のバケット・ファイル形式・識別子を指定して効率的にデータスキャン
4. **Findings の確認と活用**  
   - 検出された機密データやリスク情報を閲覧・エクスポート可能
5. **学習効果**  
   - Macie の一連操作（有効化→ジョブ作成→実行→Findings 確認）を習得
   - データセキュリティ運用の基礎を理解

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- Macie を有効化
- Macie ジョブを作成
- ジョブ実行後の Findings を確認
- ラボ完了後に Validation を実行

### Task 2: Enable Macie for the account
1. リージョンを **US East (N. Virginia, us-east-1)** に設定
2. Services → Security, Identity & Compliance → Amazon Macie
3. ホームページの **Get started** をクリック
4. **Enable Macie** をクリックして有効化

### Task 3: Create a Macie job
1. **Create job** ボタンをクリック
2. Step-1: **Choose S3 Bucket** を選択  
   - バケットが見えない場合は **Add filter criteria → Bucket name** でフィルタ  
   - 「sample-bucket」と入力して対象バケットを選択  
   - ページが空白の場合は 2–5 分待機し、2–3 回リフレッシュ
3. Step-3: **Refine the scope**  
   - **One-time job** を選択  
   - Additional settings → File name extensions に `csv` を追加
4. Step-4: **Select managed data identifiers**  
   - **Recommended** を選択
5. Step-5: **Custom data identifiers**  
   - **Manage custom identifiers** をクリック  
   - 新しいタブで **Create** → Name: `CustomIdentifier`、Description: `This identifier finds the data present in the format of AB-01 i.e. two characters, dash and followed by two numbers.`, Regular expression: `[a-z]{2}-[0-9]{2}`  
   - Submit で作成、元のタブに戻り **Refresh** → 新しい識別子を確認
6. Allow lists: デフォルトのまま **Next**
7. General Setting: Name: `SampleScanJob`、Description: `This job scans the bucket with a name starting as sample-bucket and gathers its finding based on the regular expression pattern.` → **Next**
8. Step-8: **Review and create** → 設定確認後 **Submit** をクリックしてジョブ作成完了

### Task 4: Macie job run and findings
1. ジョブは作成後自動的に開始、約 10 分で完了（Status: Complete）
2. Findings の確認:
   - ジョブをクリック → **Show results** → **Show findings**
   - 任意の Finding を開き詳細確認  
   - 表示されない場合は 2 分待機しリフレッシュ
3. Findings のエクスポート:
   - 対象 Finding を選択 → **Actions → Export (JSON)**  
   - JSON は Read-only、必要に応じてダウンロード可能

## 学習成果
- Macie の有効化・ジョブ作成・実行の一連操作を習得
- カスタムデータ識別子を使った独自フォーマットのデータ検出を理解
- S3 バケット内の敏感データ可視化とリスク評価の基礎を習得

# Blocking web traffic with WAF in AWS

## 概要
- **サービス内容**：AWS WAF は Web アプリケーションの前段に配置され、HTTP/HTTPS トラフィックを解析・フィルタリングするセキュリティサービス。特定の攻撃パターン（SQL インジェクション、クロスサイトスクリプティングなど）や IP アドレスに基づいてアクセスをブロック可能。
- **ラボ完了内容**：
  - ALB（Application Load Balancer）の作成
  - Web サーバー（EC2）2 台の作成と ALB への登録
  - IPセット作成と Web ACL の設定
  - WAF による特定 IP のアクセスブロック確認
  - IP ブロック解除後のアクセス確認

## ポイント
1. **Web ACL と IPセットの理解**
   - Web ACL にルールを追加し、特定の IP からのアクセスをブロック
   - ALB に関連付けることで実際のトラフィックに適用
2. **ALB の負荷分散確認**
   - ブラウザで DNS 名にアクセスして `RESPONSE COMING FROM SERVER A/B` の表示を確認
   - 複数サーバーへのリクエスト分散が正常に動作
3. **WAF 動作確認**
   - Web ACL に IPセットを追加後、ブロック対象 IP からのアクセスは 403 Forbidden
   - IP 削除後は再度アクセス可能
4. **運用上の注意**
   - IP ブロックやルール変更は即時反映される
   - Web ACL と ALB の関連付けを正しく行うことが重要

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- ALB、Web サーバー、WAF 設定を順に作成
- WAF でのブロック動作確認とアンブロックを実施

### Task 2: Creating a Security Group for the Load Balancer
1. EC2 コンソール → **Security Groups** → **Create security group**
2. 設定:
   - Name: `LoadBalancer-SG`
   - Description: `Security group for the load balancer`
   - Inbound rule: HTTP, TCP, Port 80, Source 0.0.0.0/0
3. 作成をクリック

### Task 3: Creating Web Servers
1. EC2 → Launch Instance
2. 設定:
   - Name: `WebServer-A` / `WebServer-B`
   - AMI: Amazon Linux 2023 kernel-6.1
   - Instance type: `t2.micro`
   - Key pair: `MyKeyPair`（新規作成）
   - Security group: `WebServer-SG`（HTTP: ALB から、SSH: Anywhere）
3. User data スクリプトで HTTPD とテストページを作成
   - Server A: `Response coming from server A`
   - Server B: `Response coming from server B`

### Task 4: Creating a Load Balancer
1. **Target Group** 作成:
   - Name: `WebServer-TG`
   - Target type: Instances
   - Health check: HTTP `/index.html`
   - EC2 インスタンスを登録
2. **ALB 作成**:
   - Name: `WebServer-LB`
   - Scheme: Internet-facing
   - Security group: `LoadBalancer-SG`
   - Listener: HTTP 80 → Target group `WebServer-TG`
3. ALB が Active になるまで待機

### Task 5: Testing the Load Balancer
- ALB の DNS 名をブラウザで開く
- ブラウザを更新すると `RESPONSE COMING FROM SERVER A` / `B` が交互に表示される
- https の場合は s を削除して http にアクセス

### Task 6: Creating an IP Set
1. WAF & Shield → IP sets → Create IP set
2. 設定:
   - Name: `MyIPSet`
   - Description: `IP set to block my public IP`
   - Region: US East (N. Virginia)
   - IP Version: IPv4
   - IP address: 自分のパブリックIP/32
3. 作成をクリック

### Task 7: Creating a Web ACL
1. WAF コンソール → Old WAF Console → Create web ACL
2. Web ACL 設定:
   - Resource type: Regional resources
   - Region: US East (N. Virginia)
   - Name: `MyWebACL`
   - Description: `ACL to block my public IP`
3. AWS リソース関連付け:
   - Add AWS resources → Application Load Balancer → `WebServer-LB`
4. ルール追加:
   - Add rule → Add my own rules and rule groups → IP set
   - Name: `MyWebACL-Rule`
   - IP set: `MyIPSet`
   - IP address to use: Source IP address
   - Action: Block
5. Next → ルール優先度・メトリクスはデフォルト → Review → Create web ACL
6. 数分待機で作成完了

### Task 8: Testing the Working of the WAF
- ALB の DNS 名をブラウザで開く
- 自分の IP はブロックされているため **403 Forbidden** が表示

### Task 9: Unblocking the IP
1. WAF & Shield → IP sets → `MyIPSet` → 自分の IP を選択 → Delete
2. 確認ボックスに `delete` と入力 → Delete
3. 数分後、ALB の DNS 名にアクセス → `RESPONSE COMING FROM SERVER A/B` が表示され、アクセス復帰

## 学習成果
- ALB + Web サーバー構成での負荷分散確認
- WAF による IP ベースのアクセス制御設定と適用方法
- ブロックされたアクセスの動作確認と復旧手順
- Web ACL と IPセットの連携によるトラフィック制御の理解

# Implementing AWS WAF with ALB to Block SQL Injection, Geo Location, and Query String

## 概要
- **サービス内容**：AWS WAF はウェブアプリケーションファイアウォールで、SQL インジェクションやクロスサイトスクリプティングなどの一般的な攻撃からアプリケーションを保護します。
- **ラボ完了内容**：
  - 2 台の EC2 インスタンスを起動
  - Application Load Balancer（ALB）の作成
  - ターゲットグループ作成とトラフィック分散の確認
  - AWS WAF Web ACL の作成（Geo Location、Query String、SQL Injection ルールを追加）
  - WAF ルール適用後のアクセス制御確認

## ポイント
1. **多層防御の実践**
   - ALB でトラフィックを分散し、WAF で不正アクセスをブロック
2. **WAF ルールのカスタマイズ**
   - 特定国以外からのアクセスを制限
   - Query String に特定文字列が含まれる場合にブロック
   - SQL インジェクション攻撃を自動で防止
3. **セキュリティ運用**
   - WAF は DDoS 攻撃にも有効で、異常トラフィックの緩和が可能
4. **ラウンドロビンの確認**
   - ALB が 2 台の EC2 インスタンスにリクエストを均等に分散していることを確認

## ラボ手順

### Task 1: Task Details
- AWS マネジメントコンソールにサインイン
- 1 台目 EC2 インスタンスの作成
- 2 台目 EC2 インスタンスの作成
- ターゲットグループの作成
- Application Load Balancer の作成
- ALB の DNS を使って動作確認
- AWS WAF Web ACL の作成（Geo Location、Query String、SQL Injection ルール追加）
- WAF 適用後のアクセス確認
- ラボ完了後、必要に応じて AWS リソースを削除

### Task 2: Launch First EC2 Instance
1. リージョンを **US East (N. Virginia, us-east-1)** に設定
2. EC2 → Launch Instances
3. 名前: `MyEC2Server1`
4. AMI: Amazon Linux 2023 kernel 6.1
5. インスタンスタイプ: `t2.micro`
6. キーペア: `MyWebserverKey` を作成
7. セキュリティグループ作成:
   - SSH: Anywhere
   - HTTP: Anywhere
   - HTTPS: Anywhere
8. ユーザーデータに Apache HTTPD と HTML ページ作成スクリプトを追加
```bash
#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<html><h1> Welcome to Server 1 </h1></html>" > /var/www/html/index.html

## Task 3: Launch Second EC2 Instance
- Task 2 と同様、名前を `MyEC2Server2` に変更
- 既存のキーペアとセキュリティグループを使用
- ユーザーデータを以下に変更
#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<html><h1> Welcome to Server 2 </h1></html>" > /var/www/html/index.html


## Task 4: Create Target Group
- EC2 → Target Groups → Create target group
- ターゲットタイプ: Instances
- 名前: `MyWAFTargetGroup`
- プロトコル: HTTP、ポート: 80
- ヘルスチェック:
  - Protocol: HTTP
  - Healthy threshold: 3
  - Unhealthy threshold: 2
  - Timeout: 5 秒
  - Interval: 6 秒
- 作成した 2 台のインスタンスを登録
- ターゲットグループ作成完了

## Task 5: Create Application Load Balancer
- EC2 → Load Balancers → Create Load Balancer → Application Load Balancer
- 名前: `MyWAFLoadBalancer`
- Scheme: Internet-facing
- IP タイプ: IPv4
- VPC: Default、全 Availability Zones にマッピング
- セキュリティグループ: `MyWebserverSG`
- リスナー: HTTP 80、Default action: `MyWAFTargetGroup`
- 作成完了後、DNS 名をコピー

## Task 6: Test Load Balancer DNS
- DNS 名をブラウザに入力
- ページを更新し、2 台のサーバーにラウンドロビンでアクセスされることを確認
- SQL Injection と Query String を未防御でテスト
  - `/product?item=securitynumber'+OR+1=1--`
  - `/?admin=123456`

## Task 7: Create AWS WAF Web ACL
- WAF → Old WAF Console → Create web ACL
- Resource type: Regional resources、リージョン: US East (N. Virginia)
- 名前: `MyWAFWebAcl`
- AWS リソース: ALB `MyWAFLoadBalancer` を追加
- ルール追加:
  - **Geo Location Restriction**：特定国以外をブロック
  - **Query String Restriction**：Query String に `admin` が含まれる場合ブロック
  - **AWS Managed SQL Database Rule Group**：SQL Injection をブロック
- Default action: Allow
- ルール優先度とメトリクスはデフォルト
- 作成完了

## Task 8: Test WAF
- ALB DNS 名をブラウザに入力
- ラウンドロビンでページが表示されることを確認
- SQL Injection や Query String `admin` を含むリクエストは WAF によってブロックされることを確認

## 学習成果
- EC2 と ALB を組み合わせた負荷分散を理解
- WAF の Web ACL ルール作成（Geo Location、Query String、SQL Injection）の手順を習得
- ALB と WAF の組み合わせによる多層防御の概念を体験
- WAF によるリクエスト制御・DDoS 緩和の基礎を理解