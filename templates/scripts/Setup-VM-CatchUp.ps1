# ===============================================
# VM デプロイ & Managed Identity 設定スクリプト
# ===============================================
# 途中から参加した方のためのキャッチアップ用スクリプト
# このスクリプトは以下を自動実行します：
#   - 仮想ネットワークとサブネットの作成
#   - Windows VM の作成（Public IP なし）
#   - Managed Identity の有効化
# ===============================================

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$YourName,
    
    [Parameter(Mandatory=$true)]
    [string]$AdminUsername,
    
    [Parameter(Mandatory=$true)]
    [SecureString]$AdminPassword,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "japaneast"
)

# ===============================================
# 設定値
# ===============================================
$VNetName = "vnet-handson"
$VNetAddressPrefix = "10.20.0.0/16"
$SubnetName = "vm-subnet"
$SubnetAddressPrefix = "10.20.1.0/24"
$VMName = "vm-$YourName"
$VMSize = "Standard_B2ms"
$VMImage = "Win2022Datacenter"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "VM デプロイ & Managed Identity 設定開始" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ===============================================
# ステップ 1: 仮想ネットワークの作成
# ===============================================
Write-Host "[1/5] 仮想ネットワークを作成しています..." -ForegroundColor Yellow

$vnetExists = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($vnetExists) {
    Write-Host "  ✓ 仮想ネットワーク '$VNetName' は既に存在します" -ForegroundColor Green
    $vnet = $vnetExists
} else {
    $vnet = New-AzVirtualNetwork `
        -Name $VNetName `
        -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -AddressPrefix $VNetAddressPrefix
    
    Write-Host "  ✓ 仮想ネットワーク '$VNetName' を作成しました" -ForegroundColor Green
}

# ===============================================
# ステップ 2: サブネットの作成
# ===============================================
Write-Host "[2/5] サブネットを作成しています..." -ForegroundColor Yellow

$subnetConfig = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet -ErrorAction SilentlyContinue

if ($subnetConfig) {
    Write-Host "  ✓ サブネット '$SubnetName' は既に存在します" -ForegroundColor Green
} else {
    Add-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName `
        -VirtualNetwork $vnet `
        -AddressPrefix $SubnetAddressPrefix | Out-Null
    
    $vnet | Set-AzVirtualNetwork | Out-Null
    
    # 再取得
    $vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
    $subnetConfig = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet
    
    Write-Host "  ✓ サブネット '$SubnetName' を作成しました" -ForegroundColor Green
}

# ===============================================
# ステップ 3: ネットワークインターフェースの作成
# ===============================================
Write-Host "[3/5] ネットワークインターフェースを作成しています..." -ForegroundColor Yellow

$nicName = "$VMName-nic"
$nic = New-AzNetworkInterface `
    -Name $nicName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SubnetId $subnetConfig.Id

Write-Host "  ✓ ネットワークインターフェース '$nicName' を作成しました" -ForegroundColor Green
Write-Host "  （注意: Public IP は割り当てていません - 閉域環境）" -ForegroundColor Cyan

# ===============================================
# ステップ 4: Windows VM の作成
# ===============================================
Write-Host "[4/5] Windows VM を作成しています..." -ForegroundColor Yellow
Write-Host "  （この処理には数分かかります...）" -ForegroundColor Gray

# 資格情報オブジェクトの作成
$cred = New-Object System.Management.Automation.PSCredential($AdminUsername, $AdminPassword)

# VM 構成の作成
$vmConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize | `
    Set-AzVMOperatingSystem -Windows -ComputerName $VMName -Credential $cred | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $nic.Id | `
    Set-AzVMBootDiagnostic -Disable

# VM の作成
New-AzVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -VM $vmConfig `
    -Verbose

Write-Host "  ✓ Windows VM '$VMName' を作成しました" -ForegroundColor Green

# ===============================================
# ステップ 5: Managed Identity の有効化
# ===============================================
Write-Host "[5/5] Managed Identity を有効化しています..." -ForegroundColor Yellow

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm -IdentityType SystemAssigned | Out-Null

Write-Host "  ✓ Managed Identity を有効化しました" -ForegroundColor Green

# ===============================================
# 完了メッセージ
# ===============================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "✓ セットアップが完了しました！" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "作成されたリソース:" -ForegroundColor White
Write-Host "  - 仮想ネットワーク: $VNetName ($VNetAddressPrefix)" -ForegroundColor Gray
Write-Host "  - サブネット: $SubnetName ($SubnetAddressPrefix)" -ForegroundColor Gray
Write-Host "  - VM 名: $VMName" -ForegroundColor Gray
Write-Host "  - VM サイズ: $VMSize" -ForegroundColor Gray
Write-Host "  - Managed Identity: 有効" -ForegroundColor Gray
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Yellow
Write-Host "  1. Azure Portal で Bastion を使って VM に接続" -ForegroundColor White
Write-Host "  2. 講師に Managed Identity の権限付与を依頼" -ForegroundColor White
Write-Host "  3. ハンズオンのセクション 3-2 から継続" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  注意: Public IP は付与されていません（閉域環境）" -ForegroundColor Cyan
Write-Host "    接続は Bastion を使用してください" -ForegroundColor Cyan
Write-Host ""
