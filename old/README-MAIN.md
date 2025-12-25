# ��� Azure ハンズオン - 閉域 AI & Container Apps

## 概要
このリポジトリは、Azure初学者向けのハンズオン教材集です。閉域環境でのセキュアなAI利用から、Container Appsを使ったモダンなアプリケーション開発まで、実践的なシナリオを体験できます。

## 対象者
- Azureを初めて触る方
- クラウドのセキュリティ基礎を学びたい方
- AIを安全に業務利用したい方
- コンテナ技術に興味がある方

## 全体構成

### ��� シナリオ一覧

| シナリオ | 内容 | 所要時間 | 難易度 |
|---------|------|---------|--------|
| [01-basics](scenarios/01-basics/) | Portal/RBAC/タグ/コスト | 20分 | ⭐ |
| [02-iaas-vm](scenarios/02-iaas-vm/) | Windows VM + Bastion + MI | 40分 | ⭐⭐ |
| [03-ai-private](scenarios/03-ai-private/) | 閉域AI（Managed Identity） | 30分 | ⭐⭐ |
| [04-container-apps-ai](scenarios/04-container-apps-ai/) | Container Apps + Blob + AI Search | 60分 | ⭐⭐⭐ |

### ��� 学習目標

- **セキュリティ**: 閉域ネットワーク、Managed Identity、Private Endpoint
- **AI活用**: Azure OpenAI、AI Search、RAGの基礎
- **運用管理**: RBAC、タグ、コスト管理
- **モダン開発**: Container Apps、スケール、CI/CD

## 前提条件

### 環境セットアップ
環境セットアップ（RG作成/RBAC付与/タグ適用）は別リポジトリで管理:
��� [Azure-Handson-setup](https://github.com/ylearning86/Azure-Handson-setup)

### 参加者に必要なもの
- Azure Portal にアクセスできるブラウザ
- 配布されたユーザーアカウント（当日配布）
- （オプション）Azure CLI がインストールされた環境

### 事前準備（運営側）
- 参加者ごとに `rg-user-xxx` を作成済み
- Contributor 権限を付与済み
- 必要に応じて Azure OpenAI リソース作成
- Container Apps 環境の事前作成（シナリオ04）

## クイックスタート

### 1. 基礎編（必須）
まずは Azure Portal の基本操作を習得:
```bash
cd scenarios/01-basics
# portal-rbac-cost.md を参照
```

### 2. VM閉域体験（推奨）
閉域でのVM利用とManaged Identityを体験:
```bash
cd scenarios/02-iaas-vm
# vm-bastion-mi.md を参照
```

### 3. AI閉域体験（人気）
APIキー不要で安全にAIを使う:
```bash
cd scenarios/03-ai-private
# ai-summary-with-mi.md を参照
```

### 4. Container Apps + AI（上級）
モダンなコンテナアプリとRAG:
```bash
cd scenarios/04-container-apps-ai
# HANDSON-ContainerApps-Blob-AI.md を参照
```

## 成果物の持ち帰り

ハンズオンで作成した要約レポートは、Blobに保存してSASリンクで共有できます:
- 手順: [scenarios/04-container-apps-ai/SAS-SHARING-GUIDE.md](scenarios/04-container-apps-ai/SAS-SHARING-GUIDE.md)
- スクリプト: [templates/scripts/Upload-And-Share-Blob.ps1](templates/scripts/Upload-And-Share-Blob.ps1)

## 上級者向け追加課題

速く終わった方向けの発展シナリオ:
- Container Apps のスケール/リビジョン管理
- Private Endpoint でのストレージ閉域化
- GitHub Actions OIDC による CI/CD
- コストタグ基準のダッシュボード作成

## セキュリティポリシー

⚠️ **このリポジトリには機密情報を含めません**

以下は絶対にコミットしないでください:
- ユーザー名/パスワード
- テナントID/サブスクリプションID
- API キー/接続文字列
- SAS トークン

すべて「当日配布」または環境変数で管理します。

## トラブルシューティング

### よくある質問

**Q. Managed Identity の権限反映に時間がかかる**
A. 数分かかることがあります。5分待ってから再試行してください。

**Q. Bastionで接続できない**
A. VM が正しいVNetに配置されているか確認してください。

**Q. Container Apps が起動しない**
A. イメージのPull権限とネットワーク設定を確認してください。

## 関連リソース

- [環境セットアップリポジトリ](https://github.com/ylearning86/Azure-Handson-setup)
- [Azure公式ドキュメント](https://learn.microsoft.com/azure/)
- [Azure OpenAI ドキュメント](https://learn.microsoft.com/azure/ai-services/openai/)
- [Container Apps ドキュメント](https://learn.microsoft.com/azure/container-apps/)

## ライセンス
MIT License

## 貢献
Pull Request歓迎です。機密情報を含まないようご注意ください。
