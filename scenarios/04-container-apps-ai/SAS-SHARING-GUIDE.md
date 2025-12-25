# Blob SAS 共有ガイド（持ち帰り用）

## 目的
- 閉域（Private Endpoint）で保存した要約を、期限付きのSASリンクで上司/チームへ共有します。
- 公開設定やキー共有を避け、最小権限・期限付きで安全に配布します。

## ポータル（初心者向け）
1. ストレージアカウント → Blob コンテナ `reports` → 対象ファイルを選択
2. "Generate SAS" をクリック
3. 権限は Read のみ、有効期限は 24時間程度
4. URL をコピーして共有

## CLI（上級者向け）
```bash
az storage blob generate-sas \
  --account-name <storage> \
  --container-name reports \
  --name <file> \
  --permissions r \
  --expiry 2025-12-26T09:00Z \
  --auth-mode login -o tsv
```
- Blob URLに `?<SAS>` を結合して共有します。

## 一括（スクリプト）
```powershell
pwsh -File scripts/Upload-And-Share-Blob.ps1 `
  -StorageAccount <storage> `
  -ResourceGroup <rg-user-xxx> `
  -FilePath c:\git\Azure-Handson-setup\docs\SESSION-SUMMARY-AI.md `
  -CreateContainerIfMissing `
  -Expiry (Get-Date).AddDays(1)
```
- 実行結果に表示される URL をそのまま共有できます。

## セキュリティ補足
- SASは期限切れで無効化されます。必要に応じて直ちに失効（キーのローテーション）も可能。
- Blobは Public にしません。共有はファイル単位の読み取りSASのみ。
- RBAC + User Delegation SAS を使うことで、アカウントキー不要の発行が可能です（`--auth-mode login`）。
