# ハンズオン報告用要約（Azure 初学者向け + AI要素）

## 概要
- 対象: 参加者約30名、9サブスクリプションに均等分散（各3–4名）。
- 主要テーマ: Azure Container Apps と Blob Storage の実践。観測（App Insights）、タグ/RBAC/コストの基礎も確認。
- AI要素: Blobの資料を Azure AI Search でインデックスし、（可能なら）Azure OpenAI と組み合わせた軽量RAGで社内資料のQ&Aを体験。

## 実施内容（アジェンダ準拠）
- Handson#1: Portal/CLIで RG/タグ/RBAC/コストビューを確認。
- Handson#2: 小型VMの基本操作（NSG/JIT）と Managed Identity の概念を紹介。
- Handson#3: Blob コンテナ作成、ファイル操作、Static Website有効化。Private Endpointの簡易体験。
- AIミニ枠: Blob→AI Search のインデクサー作成。コンテナアプリ（Container Apps）から検索/回答。

## 参加者が得たスキル
- リソース管理: RG/タグ/RBAC/コストの実践的理解。
- ストレージ: Blobの基本操作、静的サイト公開、プライベート化の要点。
- コンテナ: Container Apps のデプロイ、環境変数設定、ログ確認、スケール/リビジョンの考え方。
- AI連携: 自社資料を検索し回答する導入イメージ（クォータに応じて検索のみでも成立）。

## 成果物/設定
- 各 `rg-user-xxx` に Storage アカウント、（必要に応じて）Key Vault、App Insights/Log Analytics。
- サブごとに Container Apps 環境（Env）を1つ、参加者ごとにアプリ1つ。
- 既定タグ（WorkshopName/Student/LifecycleEndDate など）を付与し、後片付け手順を案内。

## 上級者向け追加シナリオ（任意）
- スケール/リビジョン運用: replicas増加、トラフィック分割。
- Private Endpoint: Blobのプライベート化と到達性検証。
- CI/CD: OIDCのGitHub Actionsでイメージ/環境変数を更新し再デプロイ。

## 次の一歩（提案）
- AI Search/OpenAI の利用枠調整と、社内ドキュメントのRAG PoC拡張。
- コストタグ基準のダッシュボード整備とクリーンアップ自動化。
- 受講者フィードバックを反映した継続学習（観測/セキュリティの深掘り）。
