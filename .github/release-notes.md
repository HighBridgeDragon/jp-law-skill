# 導入方法

## CLI / パッケージマネージャ

対応クライアント: Claude Code, Cursor, GitHub Copilot CLI, Gemini CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## デスクトップ / Web アプリ（zip 導入）

本 Release に添付の `jp-law.zip` をダウンロードして導入します。

- **claude.ai / Claude Desktop**: Settings > Features から `jp-law.zip` をアップロードします（アップロードできるのは本 Release 添付の zip のみです）。
- **ChatGPT Desktop / Goose Desktop ほか**: `~/.agents/skills/jp-law`（またはプロジェクトの `.agents/skills/jp-law`）に展開して配置します。

各クライアント別の詳細な導入手順や動作条件（ネットワーク設定・スクリプト実行環境等）は [インストールガイド (docs/install.md)](https://github.com/HighBridgeDragon/jp-law-skill/blob/main/docs/install.md) を参照してください。

## 主な動作条件

- **スクリプト実行**: 本スキルは同梱の bash スクリプトから API を呼び出すため、各環境でシェル/スクリプト実行が有効である必要があります。
- **ネットワークアクセス**: サンドボックスや実行環境から `laws.e-gov.go.jp` へ到達できる必要があります。
- **Web 版 Gemini / Claude API**: シェル実行サンドボックスやネットワークアクセスを持たないため、原理的に動作しません（CLI やデスクトップ版をご利用ください）。

## 出典

- [Agent Skills (agentskills.io)](https://agentskills.io)
- [Agent Skills (Anthropic)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [How to create custom Skills (Claude)](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Build skills (OpenAI ChatGPT & Codex)](https://learn.chatgpt.com/docs/build-skills)
