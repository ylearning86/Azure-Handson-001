# 👩‍💻 参加者用ハンズオン手順書（Windows + AI）

## 🎯 ゴール

このハンズオンでは次を体験します。

- Azure Portal に慣れる  
- Windows VM を構築して操作できる  
- **API キーを使わず、Managed Identity で安全に AI を利用する**  
- 今日のハンズオン内容を AI に要約させて持ち帰る

> ※ 今回は **インターネット経由で Azure OpenAI を利用** しますが、  
> **アクセス可能なのは「権限が付与された VM だけ」** です。  
> （人間が API キーを持つことはありません）

---

## 1️⃣ 準備

### 1-1. Azure にサインイン

1. ブラウザで https://portal.azure.com を開きます。
2. 配布されたユーザー名・パスワードでサインインします。

---

### 1-2. MFA（多要素認証）の登録

1. スマホに **Microsoft Authenticator** をインストールします。
2. 画面の案内に従って、アカウントを登録します。

> 企業利用では **MFA がほぼ必須** です。

---

### 1-3. 権限（RBAC）の確認

- あなたには **共同作成者（Contributor）** が付与されています。
- できること：リソースの作成・更新・削除  
- できないこと：他ユーザーへの権限付与

---

### 1-4. タグの設定

1. 事前に用意されたリソースグループを開きます。
2. 「タグ（Tags）」メニューを開きます。
3. 下記のようにタグを追加して保存します。

```text
name : <自分の名前（またはニックネーム）>
```

---

### 1-5. コストの確認

1. 左メニューから「コストの管理 + 請求」を開く  
2. 「コスト分析」でどのリソースにコストがかかっているか確認

> **作ったら消す、不要なものは残さない** — これがクラウドの基本です。

---

## 2️⃣ Windows VM を作ってみる（Portal 編）

> Azure でサーバー（VM）を作る流れを体験します。

### 2-1. 仮想ネットワーク（VNet）

1. 「仮想ネットワーク」を新規作成  
2. 次のように設定：

| 項目 | 値 |
|------|----|
| 名前 | `vnet-handson-<自分の名前>` |
| アドレス空間 | `10.10.0.0/16` |
| リソースグループ | 事前配布の RG |

---

### 2-2. サブネット

1. VNet → **サブネット**  
2. 次の設定で追加：

| 項目 | 値 |
|------|----|
| 名前 | `vm-subnet` |
| アドレス範囲 | `10.10.1.0/24` |

---

### 2-3. Windows VM（Public IP なし）

1. 「仮想マシン」 → 新規作成  
2. 参考設定：

| 項目 | 値 |
|------|----|
| 名前 | `vm-<自分の名前>` |
| イメージ | Windows Server 2022 |
| サイズ | `Standard_B2ms` |
| ユーザー名/パスワード | 当日案内 |
| パブリック IP | **なし** |
| 仮想ネットワーク | 先ほど作成した VNet |
| サブネット | `vm-subnet` |

> 直接インターネットから触れない構成を体験します。

---

### 2-4. Bastion でログイン

1. VM → **接続 → Bastion**  
2. まだなければ Bastion を作成  
3. ブラウザ経由でログイン（RDP）

---

## 3️⃣ Managed Identity で AI を呼び出す

> ここからが本番。**API キーなし** で AI を呼びます。

### 3-1. VM の Managed Identity を ON

1. VM → **ID（Identity）**  
2. System assigned → **有効化（On）**  
3. 保存

> AI への権限付与は講師側で行います。反映に数分かかることがあります。

---

### 3-2. Python セットアップ

Bastion で VM に入り、PowerShell（管理者）で：

```powershell
winget install Python.Python.3
pip install openai azure-identity
```

---

### 3-3. AI スクリプト作成

`ai.py` を作成し、次を貼ります：

```python
from azure.identity import DefaultAzureCredential
from openai import AzureOpenAI

credential = DefaultAzureCredential()

client = AzureOpenAI(
    azure_ad_token_provider=credential.get_token,
    api_version="2024-10-01-preview",
    azure_endpoint="https://<当日案内のエンドポイント名>.openai.azure.com"
)

res = client.chat.completions.create(
    model="gpt-4.1-mini",
    messages=[{
        "role": "user",
        "content": "今日のハンズオンで学んだ内容を、非エンジニア向けに要約してください。"
    }]
)

print(res.choices[0].message.content)
```

実行：

```powershell
python ai.py
```

> これで **キーなしで AI が動けば成功！**

---

## 4️⃣ 要約を保存して持ち帰る

```powershell
python ai.py > report.md
```

> 後で Blob にアップロードし、SAS で共有します（講師案内）。

---

## 5️⃣ 片付け

- Public IP が残っていないか確認  
- 不要なリソースは削除

---

## ✅ まとめ

- Portal の基本操作  
- Bastion による安全な接続  
- **Managed Identity → キー不要で安全な AI 利用**  
- AI で「上司向け要約」を自動生成  

> **“安全に設計して使う AI” を体験できれば成功です！**
