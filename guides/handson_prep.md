# 事前準備マニュアル（運営向け）

> 目的：  
> 参加者がスムーズに **Managed Identity + Azure OpenAI** を体験できるよう、  
> 事前に運営側で整える設定をまとめています。

---

## 全体フロー

1. Azure OpenAI リソースの作成  
2. モデルのデプロイ  
3. Managed Identity（MI）用 RBAC 設定方針の整理  
4. テスト VM で事前疎通確認  
5. 当日のロール付与手順

---

## 1. Azure OpenAI の作成

Portal → **Azure OpenAI** → Create  

| 項目 | 値（例） |
|------|----------|
| リソースグループ | `rg-handson-ai` |
| 名前 | `aoai-handson` |
| リージョン | サポート地域 |
| Public access | Enabled |

> 今回は **API キーを配布しない** 前提。  
> 参加者は **Managed Identity 経由** でアクセスします。

---

## 2. モデルデプロイ

Azure OpenAI Studio → **Deployments** → Create

| 項目 | 値 |
|------|----|
| Model | gpt-4.1-mini（例） |
| Deployment name | `handson-gpt` |

> 参加者用サンプルと名前を合わせておくと説明が楽です。

---

## 3. Managed Identity 用 RBAC 設定

### 付与するロール

| ロール | 目的 |
|--------|------|
| Cognitive Services OpenAI User | Azure OpenAI 呼び出し権 |

付与対象：

> **人ではなく、VM の Managed Identity**

---

### スコープ

```text
/subscriptions/<sub>/resourceGroups/rg-handson-ai/providers/Microsoft.CognitiveServices/accounts/aoai-handson
```

> リソーススコープで最小権限に。

---

## 4. テスト VM で事前検証（必須）

### 4-1. テスト VM を準備

- 本番と同じ Windows VM（B2ms 推奨）  

### 4-2. MI を ON

VM → ID → System assigned = **On**

CLI で `principalId` 取得：

```bash
az vm show -g rg-handson -n vm-test --query identity.principalId -o tsv
```

---

### 4-3. RBAC 付与

```bash
az role assignment create \
  --assignee <principalId> \
  --role "Cognitive Services OpenAI User" \
  --scope /subscriptions/<sub>/resourceGroups/rg-handson-ai/providers/Microsoft.CognitiveServices/accounts/aoai-handson
```

---

### 4-4. Python で動作確認

参加者と同じ手順で `ai.py` を実行し、応答が返ることを確認。

> ここで成功していれば当日も安心。

---

## 5. 当日のロール付与（参加者VM）

### principalId を一覧で取得

```bash
az vm list -g <参加者RG> \
  --query "[].{name:name, principalId:identity.principalId}" \
  -o table
```

### まとめて付与

```bash
for vm in vm01 vm02 vm03; do
  PID=$(az vm show -g <参加者RG> -n $vm --query identity.principalId -o tsv)

  az role assignment create \
    --assignee $PID \
    --role "Cognitive Services OpenAI User" \
    --scope /subscriptions/<sub>/resourceGroups/rg-handson-ai/providers/Microsoft.CognitiveServices/accounts/aoai-handson
done
```

> 反映まで **1〜3分程度** 待つことがあります。

---

## トラブル対応集

| 症状 | 原因 | 対処 |
|------|------|------|
401 Unauthorized | ロール未反映 | 数分待つ / 付与再確認 |
エンドポイント解決不可 | URL typo | 正しい endpoint を貼り直す |
API キー要求 | 認証方法ミス | `DefaultAzureCredential` を確認 |
タイムアウト | NSG/ネットワーク | Outbound 規則を確認 |

---

これで、当日は **体験と解説に集中** できます。
