# 導入方法

## Claude Code / Cursor / GitHub Copilot CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## claude.ai / Claude Desktop

本 Release に添付の `jp-law.zip` をダウンロードし、Settings > Features からアップロードします。

Custom Skill は面をまたいで同期しません。Claude Code に導入済みでも、claude.ai では別途アップロードが必要です。

## 動作条件

`jp-law.zip` を導入しても、以下を満たさない環境では動作しません。

- **プラン**: Pro / Max / Team / Enterprise のいずれかであること。
- **コード実行**: 有効になっていること。本スキルは同梱の bash スクリプトから API を呼び出します。
- **ネットワークアクセス**: Skill のサンドボックスから `laws.e-gov.go.jp` へ到達できること。claude.ai のネットワークアクセスは user / admin 設定により full / partial / none のいずれかになります。
- **Claude API 経由では動作しません**: API の Skills サンドボックスはネットワークアクセスを持たないため、原理的に e-Gov 法令 API を呼び出せません。

## 実測結果（2026-09-24）

zip のアップロードと skill の認識は**成功**しました。一方で、**既定のネットワーク設定では `laws.e-gov.go.jp` へ到達できませんでした**。skill は起動しますが、API 呼び出しの段階で接続がブロックされます。

claude.ai で実際に利用するには、組織のオーナーまたはユーザーのネットワーク設定で `laws.e-gov.go.jp` を許可ドメインに追加する必要があります。許可できない環境では、Claude Code 経由（`npx skills add`）をご利用ください。

## 出典

- [Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [How to create custom Skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Create and edit files with Claude](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude)
