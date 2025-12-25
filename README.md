# 🧠 Azure ハンズオン  
## Windows サーバで「閉域 AI」を安全に使ってみよう

### 🎯 ゴール

このハンズオンでは次を体験します：

- Azure Portal の基本操作  
- Windows VM のデプロイ  
- **パブリックに出ない閉域ネットワーク**  
- **Managed Identity で AI を安全に利用（キー不要）**  
- 生成した要約を Blob に保存し、SAS で共有

> AI は「なんとなく使う」ではなく、  
> **設計して安全に使う**ことで価値が出ます。

### ⏱ 所要時間

**約 3 時間**

---

## 🚩 0. 事前案内（重要）

- サインイン情報は **当日配布**
- API キーや秘密情報は **入力しません**
- 作成したリソースは最後に **削除します**

---

## 🟦 1. 準備（Azure に慣れる）

### 1-1. Azure Portal にサインイン

👉 https://portal.azure.com  

> ユーザー名／パスワードは **当日配布** します。

### 1-2. MFA（多要素認証）

- スマホに **Microsoft Authenticator** をインストール  
- 画面の案内どおり登録  

> 企業利用では **必須** です。

### 1-3. RBAC（権限）を確認

あなたには：

> **共同作成者（Contributor）**

が付与されています。

- リソース作成 → **OK**  
- 他人への権限付与 → **NG**

### 1-4. タグを付ける

リソースグループ → **Tags**

```text
name : <自分の名前>
```

### 1-5. コストを確認

- 「コスト管理」でリソースの料金を確認

### 1-6. Advisor を確認

- コスト最適化  
- セキュリティ  
- パフォーマンス  

---

## 🟩 2. VM デプロイ体験（Windows / Portal）

> **ネットワーク → VM → ログイン → 通信確認** を体験します。

### 2-1. 仮想ネットワークを作成

| 項目 | 値 |
|---|---|
| 名前 | `vnet-handson` |
| アドレス空間 | `10.20.0.0/16` |

### 2-2. サブネットを作成

| 項目 | 値 |
|---|---|
| 名前 | `vm-subnet` |
| アドレス | `10.20.1.0/24` |

### 2-3. Windows VM を作成（Public IP なし）

| 項目 | 値 |
|---|---|
| 名前 | `vm-<自分の名前>` |
| イメージ | Windows Server 2022 |
| サイズ | Standard_B2ms |
| Public IP | **なし** |
| VNet | vnet-handson |
| Subnet | vm-subnet |

### 2-4. Bastion で接続（RDP）

- VM → **接続** → **Bastion**
- ブラウザ上で RDP 画面が開きます

> ※ 多少もっさりします（正常です）

### 2-5. インターネットに出られないことを確認

Windows 内の Edge で：

- 任意のサイトを開いてみる  
➡ つながらなければ **OK**

> 「閉域」を体感します。

### 2-6.（比較）Public IP を一時的に付与

- Public IP を追加  
- 再度接続して確認  

➡ 通信できることを確認後、  
**必ず Public IP を削除してください。**

---

## 🟨 3. 閉域 AI 体験（Managed Identity）

> API キーなしで、閉域のまま Azure OpenAI を利用します。

### 3-1. VM の Managed Identity を ON

VM → **設定 → ID → System assigned → ON**

> 権限付与は **講師が実施** します。

### 3-2. Python をインストール

PowerShell（管理者）で：

```powershell
winget install Python.Python.3
```

### 3-3. ライブラリを導入

```powershell
pip install openai azure-identity
```

### 3-4. AI に要約させる（キー不要）

メモ帳で **ai.py** を作成：

```python
from azure.identity import DefaultAzureCredential
from openai import AzureOpenAI

cred = DefaultAzureCredential()

client = AzureOpenAI(
    azure_ad_token_provider=cred.get_token,
    api_version="2024-10-01-preview",
    azure_endpoint="https://<当日案内>"
)

res = client.chat.completions.create(
    model="gpt-4.1-mini",
    messages=[
        {"role":"user",
         "content":"今日のハンズオン内容を、非エンジニアの上司向けに1分で説明してください。"}
    ]
)

print(res.choices[0].message.content)
```

実行：

```powershell
python ai.py
```

👉 **API キー不要** — VM の **Managed Identity** で認証しています。

### 3-5. 要約をファイルに保存

```powershell
python ai.py > report.md
```

---

## 🟪 4. Blob に保存して持ち帰る（SAS）

> 成果物を **閉域のまま** Azure に保存し、  
> あとで **期限付きリンク（SAS）** で共有します。

### 4-1. Blob にアップロード

（講師の案内に従い、設定済みストレージへ）

```powershell
az storage blob upload `
  --container-name reports `
  --file report.md `
  --name report-<自分>.md
```

### 4-2. 共有は「SAS」

- 読み取り専用  
- 有効期限付き  
- 必要な人だけに共有  

> 公開URLにはしません。

---

## 🧹 5. 片付け（重要）

- Public IP が残っていないか確認  
- 不要リソースを削除  

> 片付け = **コスト最適化**

---

## 🧠 まとめ

今日の学び：

- MFA / RBAC → **安全の基礎**  
- Portal で構造を理解  
- **閉域でも AI は使える**  
- Managed Identity → **キー不要で安全**  
- Blob + SAS → **成果を資産化**

---

## ⚠️ GitHub 公開に関する注意

この手順書には **機密情報を含めません**。

- ユーザー名  
- パスワード  
- テナント名  
- サブスクリプションID  
- 接続文字列  
- API キー  
- SAS

👉 すべて **当日配布** とします。

---

## 🛠 トラブル対応

- Managed Identity の権限反映は **数分かかる** ことがあります  
- うまく動かない場合は、講師へ相談してください
