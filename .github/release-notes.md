# 導入方法

## CLI / パッケージマネージャ

対応クライアント: Claude Code, Cursor, GitHub Copilot CLI, Gemini CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## デスクトップ / Web アプリ（zip 導入）

本 Release に添付の `jp-law.zip` をダウンロードして導入します。

- **claude.ai / Claude Desktop**: Settings > Capabilities から `jp-law.zip` をアップロードします（アップロードできるのは本 Release 添付の zip のみです。Code > Download ZIP の zip は構造が異なるため使えません）。
- **OpenAI Codex / Goose ほか**: `~/.agents/skills/jp-law`（またはプロジェクトの `.agents/skills/jp-law`）に展開して配置します（展開後の `jp-law/` フォルダ直下に `SKILL.md` がある状態で配置し、二重フォルダにならないようご注意ください）。

各クライアント別の詳細な導入手順は [インストールガイド (docs/install.md)](https://github.com/HighBridgeDragon/jp-law-skill/blob/main/docs/install.md) を参照してください。

## 主な動作条件

- **スクリプト実行**: 本スキルは同梱の bash スクリプトから API を呼び出すため、各環境でシェル/スクリプト実行が有効である必要があります。
- **ネットワークアクセス**: サンドボックスや実行環境から `laws.e-gov.go.jp` へ到達できる必要があります。claude.ai では、通信がブロックされる場合に許可ドメインへ `laws.e-gov.go.jp` を追加する必要があります。
- **claude.ai / Claude Desktop 利用時の要件**: 有料プラン（Pro / Max / Team / Enterprise）およびコード実行の有効化が必要です。
- **Web 版 Gemini / Claude API**: シェル実行サンドボックスや外部ネットワークアクセスを持たないため、原理的に動作しません（CLI やデスクトップ版をご利用ください）。

## 出典

- [Agent Skills (agentskills.io)](https://agentskills.io)
- [Agent Skills (Anthropic)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [How to create custom Skills (Claude)](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Build skills (OpenAI Codex)](https://developers.openai.com/codex/skills/)
