# 基礎編: Azure Portal/RBAC/タグ/コスト確認

## 目的
- Azure Portalの基本操作を習得
- RBAC（ロールベースアクセス制御）の概念を理解
- タグによるリソース管理とコストビューの確認

## 前提
- 各参加者に `rg-user-xxx` が割当済み
- Contributor 権限が付与済み

## 手順

### 1. Azure Portal にサインイン
��� https://portal.azure.com

配布されたユーザー名/パスワードでサインインします。

### 2. 自分のリソースグループを確認
```bash
az group show -g <rg-user-xxx> --query "{name:name,tags:tags}" -o json
```

### 3. RBAC（権限）を確認
```bash
az role assignment list --scope "/subscriptions/<SUB_ID>/resourceGroups/<rg-user-xxx>" -o table
```

- 自分に `Contributor` ロールが付与されていることを確認
- Contributorでできること/できないことを理解

### 4. タグの確認と追加
Portal で:
1. リソースグループ → Tags
2. 既存タグの確認（WorkshopName/Student/LifecycleEndDate）
3. 任意で追加タグ `name : <your-name>` を付与

### 5. コストビューの確認
1. Portal → Cost Management
2. サブスクリプション/リソースグループ単位のコスト確認
3. タグ別のコスト分析ビュー作成（オプション）

## まとめ
- Azure Portalでのリソース管理の基本を体験
- RBACによる権限管理の重要性を理解
- タグとコストビューで運用の基礎を体験
