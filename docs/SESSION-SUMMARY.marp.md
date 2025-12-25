---
marp: true
theme: default
paginate: true
---

# ハンズオン報告要約

- 参加者30名 / 9サブ均等分散
- 主題: Container Apps + Blob / 観測 / RBAC/タグ/コスト
- AI要素: Blob→AI Search（+OpenAI）で軽量RAG

---

## 実施内容（アジェンダ準拠）

- Handson#1: RG/タグ/RBAC/コストビュー確認
- Handson#2: VM基礎（NSG/JIT）+ MI概念
- Handson#3: Blob操作 / Static Website / Private Endpoint
- AIミニ枠: インデクサー作成→コンテナから検索/回答

---

## 得られたスキル

- リソース管理（RG/タグ/RBAC/コスト）
- ストレージ（Blob基礎/静的サイト/PE）
- コンテナ（デプロイ/環境変数/ログ/スケール）
- AI連携（社内資料検索・回答の導入）

---

## 成果物/設定

- 各RG: Storage / Key Vault（任意）/ App Insights
- 各サブ: Container Apps 環境（Env）
- タグ運用: WorkshopName / Student / LifecycleEndDate

---

## 上級者向け追加シナリオ

- スケール/リビジョン運用（replicas、トラフィック分割）
- Private Endpoint での到達性検証
- OIDC GitHub Actions による再デプロイ

---

## 次の一歩（提案）

- AI Search/OpenAI の枠調整、RAG PoC拡張
- コストタグ基準のダッシュボードと自動クリーンアップ
- 観測/セキュリティの継続学習
