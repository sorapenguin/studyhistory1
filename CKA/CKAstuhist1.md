# Kubernetes ラボ: Web サーバーの Pod デプロイと複数コンテナ管理

## 概要
このラボでは、Kubernetes クラスター上で Web サーバー Pod を作成・設定し、複数コンテナ Pod の操作まで学習します。  
学習内容には以下が含まれます:
- Kubernetes クラスターの構成確認
- Pod 作成と Apache Web サーバーのデプロイ
- Webページの作成と公開
- Pod 内のコンテナ操作（SSH、ファイル作成）
- 複数コンテナ Pod の作成と管理

所要時間: 約 60 分  
事前準備: 基本的な Linux コマンドの知識  
参考: [Ubuntu Command Line Tutorial](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview)

## ポイント
- Pod は Kubernetes の最小デプロイ単位で、コンテナをまとめて管理可能
- Kubelet はノード単位で Pod を管理するエージェント
- kubectl はクラスタ操作のための統一 CLI ツール
- 複数コンテナ Pod はサイドカーやマイクロサービス連携で重要
- 作業後は不要な Pod を削除して環境を整理する

---

# タスク 1: ラボ環境の起動
# Start Lab ボタンをクリックして環境を起動
# SSH 接続情報が提供される (Master / Worker-1 / Worker-2)
# 環境準備には 1 分未満
# SSH 情報を使って Master / Worker ノードにアクセス

---

# タスク 2: クラスター構成の確認
kubectl version
systemctl status kubelet
kubectl get pods --all-namespaces

---

# タスク 3: Apache Web サーバー Pod の作成
kubectl run server --image=httpd
kubectl get pods
kubectl exec server -it -- bash
cd /usr/local/apache2/htdocs
echo "<html>Hi, We are testing web server</html>" > index.html
exit
kubectl describe pods server | grep IP
curl <ip-of-pod>/index.html
kubectl delete pods server

---

# タスク 4: 複数コンテナ Pod の作成
nano dual_Cont_pod.yaml

# dual_Cont_pod.yaml の内容
apiVersion: v1
kind: Pod
metadata:
  name: testpod1
spec:
  containers:
    - name: c00
      image: ubuntu
      command: ["/bin/bash", "-c", "while true; do echo Hello-Coder; sleep 5 ; done"]
    - name: c01
      image: ubuntu
      command: ["/bin/bash", "-c", "while true; do echo Hello-Programmer; sleep 5 ; done"]

kubectl apply -f dual_Cont_pod.yaml
kubectl get pods
kubectl exec -it testpod1 -c c00 -- /bin/bash
echo "Hello from inside the container" > myfile.txt
exit
kubectl exec -it testpod1 -c c00 -- ls /
kubectl delete pods --all

---

# 学習成果
- Kubernetes クラスターのコンポーネント確認
- Apache Web サーバー Pod の作成・デプロイ
- Webページ作成とコンテンツ公開
- Pod 内でのコンテナ操作（SSH、ファイル作成、ログ確認）
- 複数コンテナ Pod の作成・管理
- Pod の削除による環境整理

---