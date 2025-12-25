# Azure Hands-on: Container Apps + Blob + AI (RAG)

## 目的
- Azure初学者が、Blobストレージとコンテナアプリを使ったクラウド基本操作を体験する。
- 可能なら Azure AI Search + Azure OpenAI を組み合わせ、Blob内の資料を質問応答できる軽量RAGを体験する。

## 前提
- 参加者: 約30名。9サブスクリプションに均等分散（各3〜4名）。
- 各参加者には `rg-user-xxx` が割当済みで Contributor 権限を付与済み。
- 各サブに Container Apps 環境（Env）を1つ事前作成。各参加者RGにアプリを1つずつ作成予定。
- リージョンは同一（例: Japan East）。

## 事前デプロイ（運営側）
1. Storage アカウント（Blob）を各 `rg-user-xxx` に1つ作成（名前は `st<workshop><user>` など重複回避）。
2. 各サブに Container Apps 環境（Env）を1つ作成（共通RGでも可）。
3. Application Insights と Log Analytics を作成し、Container Apps から送信可能にする。
4. （AIオプション）Azure AI Search（Basic/Vector対応）と Azure OpenAI リソースを作成。モデルデプロイ名とキー/エンドポイントを配布。
5. 既定タグを `config.json` に合わせて付与（WorkshopName/Student/LifecycleEndDateなど）。

## 参加者手順（Portal/CLI）

### 1) 自分の割当確認
```bash
# RG とタグ
az group show -g <RG_NAME> --query "{name:name,tags:tags}" -o json
# RBAC (権限確認例)
az role assignment list --scope "/subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>" -o table
```

### 2) Blob コンテナ作成とファイルアップロード
```bash
# ストレージアカウント名・RG・場所
ST=<storage_account>
RG=<rg-user-xxx>

# コンテナ作成
az storage container create --name docs --account-name "$ST" --auth-mode login
# ファイルアップロード
az storage blob upload --account-name "$ST" --container-name docs --name sample.md --file ./samples/sample.md --auth-mode login
```

### 3) コンテナアプリのデプロイ（環境変数にBlob情報）
```bash
# 事前に作成済みの Container Apps 環境名
ENV_NAME=<env-name-per-sub>
APP_NAME=chat-docs
RG=<rg-user-xxx>
IMAGE=<acr_or_ghcr_image>

az containerapp create \
  --name "$APP_NAME" \
  --resource-group "$RG" \
  --environment "$ENV_NAME" \
  --ingress external --target-port 8080 \
  --image "$IMAGE" \
  --env-vars \
    STORAGE_ACCOUNT="$ST" \
    STORAGE_CONTAINER="docs" \
    AI_SEARCH_ENDPOINT="$AI_SEARCH_ENDPOINT" \
    AI_SEARCH_KEY="$AI_SEARCH_KEY" \
    AI_SEARCH_INDEX="workshop" \
    AZURE_OPENAI_ENDPOINT="$AOAI_ENDPOINT" \
    AZURE_OPENAI_DEPLOYMENT="$AOAI_DEPLOYMENT" \
    AZURE_OPENAI_KEY="$AOAI_KEY"
```

> 代替案: OpenAI/AI Search のクォータがない場合は `AI_*` の環境変数を省略し、キーワード検索のみ対応のイメージを使用。

### 4) 観測（ログとメトリクス）
```bash
# Container Apps のログ閲覧（ライブ）
az containerapp logs show -n "$APP_NAME" -g "$RG" --follow
```

### 5) AIミニ: インデクサー作成（Blob→AI Search）
```bash
# 例: AI Search に index/skillset/datasource を作成（簡易例、運営が用意したスクリプトを推奨）
# 実環境では ARM/Bicep/REST を配布し、既定値で誤操作を防止
```

## 速い参加者向け追加シナリオ
- スケール/リビジョン運用: `az containerapp revision list` / `update` でトラフィック分割。replicas を 1→3。
- Private Endpoint 化: Storage を Private Endpoint でVNetに接続し、Container Apps から到達性確認。
- CI/CD: 既存 GitHub Actions OIDC で `IMAGE` と環境変数を差し替えて再デプロイ（`containerapp update`）。

## 運営チェックリスト
- サブごとの参加者数（3〜4名）と RG 作成済み確認。
- AI Search / OpenAI のクォータ（リージョン/モデル/レート）確認。
- Container Apps 環境はサブに1つ、リージョン統一。
- 料金と停止手順: LifecycleEndDate タグに基づくクリーンアップ案内。

## トラブルシュート
- 権限不足: RBACスコープがRGになっているか確認。
- 到達不可: Private Endpoint 有効時は DNS/リンクの設定確認。
- イメージ取得失敗: ACR/GHCR のPull権限とネットワーク制約を確認。
