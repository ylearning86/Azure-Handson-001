# VM デプロイ & Managed Identity 設定スクリプト 使用方法

## 📋 概要

このスクリプトは、ハンズオンの途中から参加した方や、手順を飛ばしてしまった方のために用意されています。

以下を自動で実行します：
- ✅ 仮想ネットワーク（VNet）の作成
- ✅ サブネットの作成
- ✅ Windows VM の作成（Public IP なし）
- ✅ Managed Identity の有効化

## 🚀 使い方

### 前提条件

1. Azure PowerShell モジュールがインストールされていること
   ```powershell
   Install-Module -Name Az -AllowClobber -Scope CurrentUser
   ```

2. Azure にログイン済みであること
   ```powershell
   Connect-AzAccount
   ```

3. 適切なサブスクリプションが選択されていること
   ```powershell
   Set-AzContext -Subscription "<サブスクリプション名またはID>"
   ```

### 実行方法

```powershell
# パスワードをセキュアに入力
$password = Read-Host "VM の管理者パスワードを入力してください" -AsSecureString

# スクリプトを実行
.\Setup-VM-CatchUp.ps1 `
    -ResourceGroupName "rg-handson-<自分の名前>" `
    -YourName "<自分の名前>" `
    -AdminUsername "azureuser" `
    -AdminPassword $password `
    -Location "japaneast"
```

### パラメータ説明

| パラメータ | 必須 | 説明 | 例 |
|-----------|------|------|-----|
| ResourceGroupName | ✅ | リソースグループ名 | `rg-handson-yamada` |
| YourName | ✅ | あなたの名前（VM名に使用） | `yamada` |
| AdminUsername | ✅ | VM の管理者ユーザー名 | `azureuser` |
| AdminPassword | ✅ | VM の管理者パスワード（SecureString） | `Read-Host -AsSecureString` で入力 |
| Location | ❌ | デプロイ先のリージョン（省略時: japaneast） | `japaneast` |

### パスワード要件

- 12文字以上
- 大文字、小文字、数字、特殊文字を含む
- 管理者名を含まない

例: `P@ssw0rd1234!`

## 📊 実行結果

スクリプトは以下の順序で処理を行います：

```
[1/5] 仮想ネットワークを作成しています...
  ✓ 仮想ネットワーク 'vnet-handson' を作成しました

[2/5] サブネットを作成しています...
  ✓ サブネット 'vm-subnet' を作成しました

[3/5] ネットワークインターフェースを作成しています...
  ✓ ネットワークインターフェース 'vm-yamada-nic' を作成しました
  （注意: Public IP は割り当てていません - 閉域環境）

[4/5] Windows VM を作成しています...
  （この処理には数分かかります...）
  ✓ Windows VM 'vm-yamada' を作成しました

[5/5] Managed Identity を有効化しています...
  ✓ Managed Identity を有効化しました
```

## 🎯 次のステップ

スクリプト実行後：

1. **Azure Portal で Bastion を使って VM に接続**
   - Azure Portal → VM → 接続 → Bastion

2. **講師に Managed Identity の権限付与を依頼**
   - Azure OpenAI へのアクセス権限が必要です

3. **ハンズオンのセクション 3-2 から継続**
   - Python のインストール
   - AI 要約の実行

## ⚠️ 注意事項

- このスクリプトで作成される VM には **Public IP が付与されていません**（閉域環境）
- VM への接続は **Azure Bastion** を使用してください
- 既に同名のリソースが存在する場合は、エラーが発生します
- VNet やサブネットが既に存在する場合は、既存のものを使用します

## 🛠 トラブルシューティング

### エラー: リソースグループが見つからない

```powershell
# リソースグループを事前に作成してください
New-AzResourceGroup -Name "rg-handson-<自分の名前>" -Location "japaneast"
```

### エラー: VM 名が既に使用されている

- 別の名前を `-YourName` パラメータで指定してください

### エラー: Managed Identity の権限が反映されない

- 権限の反映には **数分かかる** ことがあります
- 講師に確認してください

## 🧹 後片付け

ハンズオン終了後は、必ずリソースを削除してください：

```powershell
Remove-AzVM -ResourceGroupName "rg-handson-<自分の名前>" -Name "vm-<自分の名前>" -Force
Remove-AzNetworkInterface -ResourceGroupName "rg-handson-<自分の名前>" -Name "vm-<自分の名前>-nic" -Force
```

または、リソースグループごと削除：

```powershell
Remove-AzResourceGroup -Name "rg-handson-<自分の名前>" -Force
```
