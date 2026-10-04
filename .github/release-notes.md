# 導入方法

## CLI / パッケージマネージャ

対応クライアント: Claude Code, Cursor, GitHub Copilot CLI, Gemini CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## デスクトップ / Web アプリ（zip 導入）

本 Release に添付の `jp-law.zip` をダウンロードして導入します。

- **claude.ai / Claude Desktop**: Skills 設定から `jp-law.zip` をアップロードします（アップロードできるのは本 Release 添付の zip のみです。Code > Download ZIP の zip はリポジトリ全体を含み構造が異なるため使えません。また、Custom Skill は面をまたいで同期しないため個別にアップロードが必要です。操作手順詳細は [インストールガイド](https://github.com/HighBridgeDragon/jp-law-skill/blob/main/docs/install.md) を参照）。
- **OpenAI Codex**: `~/.agents/skills/`（またはプロジェクトの `.agents/skills/`）直下に展開後の `jp-law` フォルダを配置します（配置後のパス: `~/.agents/skills/jp-law/SKILL.md`）。二重フォルダ（`jp-law/jp-law/`）にならないようご注意ください。
- **Goose ほか対応クライアント**: 各ツールの設定手順に従って配置します（詳細は下記インストールガイドを参照）。

各クライアント別の詳細な導入手順は [インストールガイド (docs/install.md)](https://github.com/HighBridgeDragon/jp-law-skill/blob/main/docs/install.md) を参照してください。

## 主な動作条件

- **スクリプト実行**: 本スキルは同梱の bash スクリプトから API を呼び出すため、各環境でシェル/スクリプト実行が有効である必要があります。
- **ネットワークアクセス**: サンドボックスや実行環境から `laws.e-gov.go.jp` へ到達できる必要があります。claude.ai では許可ドメインへの追加が必要となるため、追加できない環境では Claude Code 経由をご利用ください（設定条件の詳細はインストールガイドを参照）。
- **claude.ai / Claude Desktop 利用時の要件**: コード実行の有効化が必要です（詳細はインストールガイドを参照）。
- **Web 版 Gemini / Claude API**: シェル実行サンドボックスや外部ネットワークアクセスを持たないため、原理的に動作しません（CLI やデスクトップ版をご利用ください）。

## 出典

- [Agent Skills (agentskills.io)](https://agentskills.io)
- [Agent Skills (Anthropic)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [How to create custom Skills (Claude)](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Using Skills in Claude (Claude Help)](https://support.claude.com/en/articles/12512180-using-skills-in-claude)
- [Create and edit files with Claude (Claude Help)](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude)
- [Build skills (OpenAI Codex)](https://developers.openai.com/codex/skills/)
- [Goose (Block)](https://block.github.io/goose/)
