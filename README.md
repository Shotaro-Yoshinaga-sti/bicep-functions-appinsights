# Azure Functions & Application Insights Bicep サンプル

このリポジトリは、Bicep を使って Azure Functions と Application Insights をリンクする方法を検証・学習するためのサンプルです。

## ファイル構成

### テンプレートファイル

| ファイル | 説明 |
|---------|------|
| `main.bicep` | Azure FunctionsとApplication Insightsの連携 |
| `main2.bicep` | Cloud Role Name設定を含むAzure FunctionsとApplication Insightsの連携 |

### main.bicep

- Azure Functions と Application Insights の連携
- `APPLICATIONINSIGHTS_CONNECTION_STRING` を使用した接続設定
- 公式ドキュメント（[App settings reference for Azure Functions]）によると、`APPINSIGHTS_INSTRUMENTATIONKEY`または`APPLICATIONINSIGHTS_CONNECTION_STRING`のいずれかを設定できるが、`APPINSIGHTS_INSTRUMENTATIONKEY`は2025年3月31日でサポート終了予定（[Connection strings in Application Insights]）のため、`APPLICATIONINSIGHTS_CONNECTION_STRING`を使用
- Application InsightsとFunction Appの関連付けは`hidden-linkタグ`としてAzure内部で自動管理される
- `hidden-linkタグ`は`APPLICATIONINSIGHTS_CONNECTION_STRING`設定時にAzureが自動的に作成するため、Bicepテンプレートでの明示的な設定は不要

### main2.bicep

- `main.bicep`の機能に加えて、環境変数 `WEBSITE_CLOUD_ROLENAME` を設定
- Application Insights のApplication Mapで各Functionを個別に識別可能
- `WEBSITE_CLOUD_ROLENAME`を設定しない場合は、Function Appのリソース名が自動的にCloud Role Nameとして使用される
  - **未設定の場合**: Function Appのリソース名（例：`func-app-api-abc123`）がそのまま表示
  - **設定した場合**: 意味のある名前（例：`API-Service`, `Worker-Service`）で表示され、運用効率が向上

## 構成内容

### 共通リソース

- 2つの Azure Functions（Linux, Python ランタイム）
- 各 Function 用のストレージアカウント
- Application Insights（Log Analytics Workspace連携）
- 各 Function から Application Insights への接続設定

## デプロイ方法

### 基本バージョン（main.bicep）

1. Azure CLI でリソースグループを作成

   ```bash
   az group create --name rg-functions-basic --location japaneast
   ```

2. 基本的なBicep ファイルをデプロイ

   ```bash
   az deployment group create \
     --confirm-with-what-if \
     --resource-group rg-functions-basic \
     --template-file main.bicep \
   ```

### Cloud Role Name設定バージョン（main2.bicep）

Application Mapで各Functionを識別するためにAzure Functionsの環境変数`WEBSITE_CLOUD_ROLENAME`でアプリケーション指定している

1. Azure CLI でリソースグループを作成

   ```bash
   az group create --name rg-functions-advanced --location japaneast
   ```

2. 高度なBicep ファイルをデプロイ

   ```bash
   az deployment group create \
     --confirm-with-what-if \
     --resource-group rg-functions-advanced \
     --template-file main2.bicep \
   ```

## 検証方法

1. Azure Portal で Application Insights を開く
2. 「ライブメトリクス」で Function の実行を確認
3. 「ログ」でテレメトリデータを確認

## クリーンアップ

リソースを削除する場合：

```bash
# 基本バージョンのリソースグループ削除
az group delete --name rg-functions-basic --yes

# 高度バージョンのリソースグループ削除  
az group delete --name rg-functions-advanced --yes
```

## 参考

- [App settings reference for Azure Functions]
- [Configure monitoring for Azure Functions]
- [Connection strings in Application Insights]
- [What does "hidden-link:" mean in Azure Resource Manager Tags]
- [Application Insights の概要 - OpenTelemetry の可観測性]
- [Cloud Role Name の設定方法]

[App settings reference for Azure Functions]: <https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings>
[Configure monitoring for Azure Functions]: <https://learn.microsoft.com/en-us/azure/azure-functions/configure-monitoring>
[Connection strings in Application Insights]: <https://learn.microsoft.com/en-us/azure/azure-monitor/app/connection-strings>
[What does "hidden-link:" mean in Azure Resource Manager Tags]: <https://stackoverflow.com/questions/38578122/what-does-hidden-link-mean-in-azure-resource-manager-tags>
[Application Insights の概要 - OpenTelemetry の可観測性]: <https://learn.microsoft.com/ja-jp/azure/azure-monitor/app/app-insights-overview>
[Cloud Role Name の設定方法]: <https://docs.microsoft.com/ja-jp/azure/azure-monitor/app/app-map?tabs=net#set-or-override-cloud-role-name>
