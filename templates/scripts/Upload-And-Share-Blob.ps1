param(
  [Parameter(Mandatory=$true)] [string] $StorageAccount,
  [Parameter(Mandatory=$true)] [string] $ResourceGroup,
  [Parameter(Mandatory=$false)] [string] $Container = "reports",
  [Parameter(Mandatory=$true)] [string] $FilePath,
  [Parameter(Mandatory=$false)] [datetime] $Expiry = (Get-Date).AddDays(1),
  [Parameter(Mandatory=$false)] [switch] $CreateContainerIfMissing
)

<#+
.SYNOPSIS
  ローカルの要約ファイルを Blob にアップロードし、読み取り専用のSASリンクを生成して返します。
.DESCRIPTION
  - `az` CLI の `--auth-mode login` を使用し、現在のログインユーザー/MIで実行できます。
  - コンテナが存在しない場合は `-CreateContainerIfMissing` で作成します。
  - 生成するSASは Read権限のみ、有効期限は `-Expiry`（既定: 24時間）。
.EXAMPLE
  pwsh -File scripts/Upload-And-Share-Blob.ps1 -StorageAccount mystorage -ResourceGroup rg-user-001 -FilePath docs/SESSION-SUMMARY-AI.md
#>

function Ensure-Container {
  param($Account, $ContainerName)
  $exists = az storage container show --account-name $Account --name $ContainerName --auth-mode login --only-show-errors 2>$null | Out-String
  if (-not $exists) {
    Write-Host "Creating container '$ContainerName'..." -ForegroundColor Cyan
    az storage container create --account-name $Account --name $ContainerName --auth-mode login | Out-Null
  }
}

if ($CreateContainerIfMissing) {
  Ensure-Container -Account $StorageAccount -ContainerName $Container
}

$blobName = [System.IO.Path]::GetFileName($FilePath)
Write-Host "Uploading '$FilePath' to '$StorageAccount/$Container/$blobName'..." -ForegroundColor Cyan
az storage blob upload `
  --account-name $StorageAccount `
  --container-name $Container `
  --name $blobName `
  --file $FilePath `
  --overwrite `
  --auth-mode login | Out-Null

$expiryIso = $Expiry.ToUniversalTime().ToString("yyyy-MM-ddTHH:mmZ")

Write-Host "Generating read-only SAS until $expiryIso..." -ForegroundColor Cyan
$sas = az storage blob generate-sas `
  --account-name $StorageAccount `
  --container-name $Container `
  --name $blobName `
  --permissions r `
  --expiry $expiryIso `
  --auth-mode login --output tsv

# Blob URL
$blobUrl = "https://$StorageAccount.blob.core.windows.net/$Container/$blobName";
$full = "$blobUrl`?$sas";
Write-Host "SAS URL:" -ForegroundColor Green
Write-Host $full

# 出力をパイプでも使えるよう返す
$full
