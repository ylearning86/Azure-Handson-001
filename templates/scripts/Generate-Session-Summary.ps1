param(
  [Parameter(Mandatory=$false)] [string[]] $InputPaths = @(
    "c:\git\Azure-Handson-setup\next-session-prompt.md",
    "c:\git\Azure-Handson-setup\docs\HANDSON-ContainerApps-Blob-AI.md"
  ),
  [Parameter(Mandatory=$false)] [string] $OutputPath = "c:\git\Azure-Handson-setup\docs\SESSION-SUMMARY-AI.md",
  [Parameter(Mandatory=$false)] [string] $AzureOpenAIEndpoint,
  [Parameter(Mandatory=$false)] [string] $Deployment = "gpt-4o-mini",
  [Parameter(Mandatory=$false)] [string] $ApiKey,
  [Parameter(Mandatory=$false)] [string] $ApiVersion = "2024-08-01-preview"
)

# 説明: 指定ファイルの内容をまとめ、Azure OpenAI (Chat Completions) に要約を依頼し、Markdownで保存します。
# 使い方例:
# pwsh -File scripts/Generate-Session-Summary.ps1 -AzureOpenAIEndpoint https://<resource>.openai.azure.com -Deployment gpt-4o-mini -ApiKey <key>

$context = "";
foreach ($p in $InputPaths) {
  if (Test-Path $p) {
    $context += "\n\n# SOURCE: $p\n" + (Get-Content -Path $p -Raw);
  }
}

# Azure OpenAI が未設定ならローカル要約（簡易）を出力
if (-not $AzureOpenAIEndpoint -or -not $ApiKey) {
  Write-Host "Azure OpenAI設定が無いため、ローカル要約テンプレートを生成します。" -ForegroundColor Yellow
  $template = @"
# ハンズオン報告用要約（AI生成テンプレート）

## 概要
- 参加者: 30名 / 9サブ均等分散
- 主題: Container Apps + Blob、観測、RBAC/タグ/コスト

## 実施内容
- Handson#1: 概要とPortal/CLI確認
- Handson#2: VM基礎 + セキュリティ初歩
- Handson#3: Blob/Static Website/Private Endpoint
- AIミニ枠: Blob→AI Search（+OpenAI）で軽量RAG

## 所感/次の一歩
- RAG PoC拡張、コストダッシュボード、継続学習

> Azure OpenAI を設定すると、上記を文脈に沿って自動要約します。
"@;
  Set-Content -Path $OutputPath -Value $template -Encoding UTF8
  Write-Host "Summary written to $OutputPath" -ForegroundColor Green
  exit 0
}

# Azure OpenAI で要約
$uri = "$AzureOpenAIEndpoint/openai/deployments/$Deployment/chat/completions?api-version=$ApiVersion";
$body = {
  "messages": [
    {"role": "system", "content": "あなたは事実に忠実な業務向け要約アシスタントです。見出し付きMarkdownで、簡潔かつ具体的に本日のハンズオンの報告を作成してください。箇条書きは5行以内でまとめ、誇張や断定は避けます。"},
    {"role": "user", "content": $context}
  ],
  "temperature": 0.2
} | ConvertTo-Json -Depth 8;

$headers = @{ "api-key" = $ApiKey; "Content-Type" = "application/json" };

try {
  $resp = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body;
  $text = $resp.choices[0].message.content;
  Set-Content -Path $OutputPath -Value $text -Encoding UTF8;
  Write-Host "Summary written to $OutputPath" -ForegroundColor Green;
} catch {
  Write-Host "Azure OpenAI 呼び出しに失敗しました: $($_.Exception.Message)" -ForegroundColor Red;
  exit 1
}
