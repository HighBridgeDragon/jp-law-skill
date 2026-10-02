# 導入方法

## Claude Code / Cursor / GitHub Copilot CLI / Gemini CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## デスクトップ / Web アプリ

### claude.ai / Claude Desktop

本 Release に添付の `jp-law.zip` をダウンロードし、Settings > Features からアップロードします。

アップロードできるのは本 Release に添付された `jp-law.zip` だけです。リポジトリ画面の **Code > Download ZIP** で取得した zip は、展開時のトップが `jp-law-skill-main/` になるため使えません。

Custom Skill は面をまたいで同期しません。Claude Code に導入済みでも、claude.ai では別途アップロードが必要です。

#### 動作条件

`jp-law.zip` を導入しても、以下を満たさない環境では動作しません。

- **プラン**: Pro / Max / Team / Enterprise のいずれかであること。
- **コード実行**: 有効になっていること。本スキルは同梱の bash スクリプトから API を呼び出します。
- **ネットワークアクセス**: Skill のサンドボックスから `laws.e-gov.go.jp` へ到達できること。claude.ai のネットワークアクセス設定で通信がブロックされる場合は、許可ドメインに `laws.e-gov.go.jp` を追加する必要があります（これを満たせない環境では Claude Code 経由をご利用ください）。
- **Claude API 経由では動作しません**: API の Skills サンドボックスはネットワークアクセスを持たないため、原理的に e-Gov 法令 API を呼び出せません。

### ChatGPT Desktop / Goose Desktop / その他の Agent Skills 対応アプリ

本 Release に添付の `jp-law.zip` をダウンロード・展開し、お使いのクライアントのスキルディレクトリ（例: `~/.agents/skills/jp-law`）に配置します。

- **ChatGPT Desktop**: `~/.agents/skills/jp-law`（またはプロジェクトの `.agents/skills/jp-law`）に配置すると、サイドバーの「Skills」から利用できます。
- **Goose Desktop**: `~/.agents/skills/jp-law` に配置すると自動認識されます。ローカル環境で直接 bash / curl を実行可能です。
- **Web版 Gemini についての注意**: Web 版 Gemini（gemini.google.com）の Skills はプロンプトベースの拡張であり、スクリプト実行サンドボックスを持たないため動作しません（Gemini CLI または Google Antigravity をご利用ください）。

## 出典

- [Agent Skills (agentskills.io)](https://agentskills.io)
- [Agent Skills (Anthropic)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [How to create custom Skills (Claude)](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Build skills (OpenAI ChatGPT & Codex)](https://learn.chatgpt.com/docs/build-skills)
