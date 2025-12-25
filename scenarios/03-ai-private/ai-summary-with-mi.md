# AI閉域体験: Managed Identity で Azure OpenAI を使う

## 目的
- APIキー不要で Azure OpenAI を利用
- 閉域のまま要約を生成し、Blobに保存
- セキュアなAI利用パターンを体験

## 前提
- Windows VM が作成済み（scenarios/02 完了）
- VM の Managed Identity が有効化済み
- Azure OpenAI リソースへのアクセス権付与済み（講師が実施）

## 手順

### 1. Python をインストール
VM内のPowerShell（管理者）で:
```powershell
winget install Python.Python.3
```

### 2. ライブラリを導入
```powershell
pip install openai azure-identity azure-storage-blob
```

### 3. AI に要約させる（キー不要）
メモ帳で `ai_summary.py` を作成:
```python
from azure.identity import DefaultAzureCredential
from openai import AzureOpenAI

cred = DefaultAzureCredential()

client = AzureOpenAI(
    azure_ad_token_provider=lambda: cred.get_token("https://cognitiveservices.azure.com/.default").token,
    api_version="2024-10-01-preview",
    azure_endpoint="<講師から配布されたエンドポイント>"
)

res = client.chat.completions.create(
    model="<デプロイ名>",
    messages=[
        {"role": "user",
         "content": "今日のAzureハンズオン内容を、非エンジニアの上司向けに1分で説明してください。"}
    ]
)

summary = res.choices[0].message.content
print(summary)

# ファイルに保存
with open("handson-report.md", "w", encoding="utf-8") as f:
    f.write(summary)
```

実行:
```powershell
python ai_summary.py
```

### 4. Blob にアップロード
```python
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobClient

cred = DefaultAzureCredential()

blob = BlobClient(
    account_url="https://<storage>.blob.core.windows.net",
    container_name="reports",
    blob_name="handson-report.md",
    credential=cred
)

with open("handson-report.md", "rb") as data:
    blob.upload_blob(data, overwrite=True)

print("Uploaded to Blob!")
```

### 5. SAS リンクで共有
- Portal: Blob → Generate SAS → Read権限、24時間有効
- URLをコピーして共有

## まとめ
- **APIキー不要**: Managed Identity で安全に認証
- **閉域のまま利用**: Public IPなしで Azure OpenAI にアクセス
- **成果物を資産化**: Blobに保存し、SASで限定共有
