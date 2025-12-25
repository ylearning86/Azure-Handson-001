# IaaS編: Windows VM + Bastion + Managed Identity

## 目的
- 閉域（Public IPなし）でVMをデプロイ
- Azure Bastionでセキュアに接続
- Managed Identityの基本を理解

## 前提
- リソースグループ `rg-user-xxx` が割当済み
- 演習時間: 約40分

## 手順

### 1. 仮想ネットワークを作成
Portal または CLI で VNet を作成:
```bash
az network vnet create \
  --resource-group <rg-user-xxx> \
  --name vnet-handson \
  --address-prefix 10.20.0.0/16 \
  --subnet-name vm-subnet \
  --subnet-prefix 10.20.1.0/24
```

### 2. Windows VM を作成（Public IP なし）
Portal で:
- Image: Windows Server 2022
- Size: Standard_B2ms
- Public IP: **なし**
- VNet: vnet-handson
- Subnet: vm-subnet

CLI の例:
```bash
az vm create \
  --resource-group <rg-user-xxx> \
  --name vm-<yourname> \
  --image Win2022Datacenter \
  --size Standard_B2ms \
  --vnet-name vnet-handson \
  --subnet vm-subnet \
  --public-ip-address "" \
  --admin-username azureuser \
  --admin-password '<複雑なパスワード>'
```

### 3. Bastion で接続
- VM → 接続 → Bastion
- ブラウザ上でRDP画面が開く

### 4. インターネットに出られないことを確認
VM内のブラウザで任意のサイトを開く → つながらなければOK（閉域を体感）

### 5. Managed Identity を有効化
VM → 設定 → Identity → System assigned → ON

### 6. （オプション）Blob へのアクセス権付与
```bash
az role assignment create \
  --assignee <VM-の-principal-id> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<SUB>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<STORAGE>"
```

## まとめ
- 閉域VMでセキュリティの基本を体験
- Bastionでのセキュアな接続方法を習得
- Managed Identityによるキー不要の認証を理解
