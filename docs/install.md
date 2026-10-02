# インストールガイド / Installation Guide

本スキル（`jp-law`）の各種 AI エージェントおよびクライアントへの導入手順と動作条件です。

## CLI / パッケージマネージャ

対応クライアント: Claude Code, Cursor, GitHub Copilot CLI, Gemini CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

上記コマンドでお使いのエージェント環境（プロジェクトの `.agents/skills` やグローバル設定など）に自動インストールされます。

## デスクトップ / Web アプリ

[Releases](https://github.com/HighBridgeDragon/jp-law-skill/releases) に添付されている `jp-law.zip` をダウンロードして利用します。

### claude.ai / Claude Desktop

1. [Releases](https://github.com/HighBridgeDragon/jp-law-skill/releases) から `jp-law.zip` をダウンロードします。
2. Settings > Capabilities を開き、`jp-law.zip` をアップロードします。

> [!IMPORTANT]
> アップロードできるのは **Releases に添付された `jp-law.zip`** だけです。GitHub リポジトリ画面の **Code > Download ZIP** で取得した zip は、展開時のルートが `jp-law-skill-main/` になり `SKILL.md` が直下に来ないため、skill として認識されません。

Custom Skill は面をまたいで同期しません。Claude Code に導入済みでも、claude.ai では別途アップロードが必要です。

#### 動作条件（claude.ai / Claude Desktop）

zip を導入しても、以下を満たさない環境では動作しません。

- **プラン**: Pro / Max / Team / Enterprise のいずれかであること。
- **コード実行**: 有効になっていること。本スキルは同梱の bash スクリプトから API を呼び出します。
- **ネットワークアクセス**: サンドボックスから `laws.e-gov.go.jp` へ到達できること。claude.ai のネットワーク設定でブロックされる場合は、許可ドメインに `laws.e-gov.go.jp` を追加する必要があります（これを満たせない環境では Claude Code 経由をご利用ください）。
- **Claude API 経由**: API の Skills サンドボックスはネットワークアクセスを持たないため、原理的に e-Gov 法令 API を呼び出せません。

### ChatGPT Desktop / OpenAI Codex

[OpenAI のスキル仕様](https://developers.openai.com/codex/skills/) に準拠した配置手順です。

1. [Releases](https://github.com/HighBridgeDragon/jp-law-skill/releases) から `jp-law.zip` をダウンロードして展開します。
2. 展開された `jp-law` フォルダ（直下に `SKILL.md` があるフォルダ）を、ユーザー共通スキルディレクトリ（`~/.agents/skills/jp-law`）またはプロジェクト直下の `.agents/skills/jp-law` に配置します（二重フォルダ `jp-law/jp-law/` にならないよう配置パスをご確認ください）。
3. OpenAI の仕様に従い、エージェント環境（ChatGPT Desktop や Codex）からスキルとして読み込まれます。

### Goose

Block 主導のオープンソースエージェント Goose は [Agent Skills オープン標準](https://agentskills.io/clients) に対応しています。

1. [Releases](https://github.com/HighBridgeDragon/jp-law-skill/releases) から `jp-law.zip` をダウンロードして展開します。
2. 展開された `jp-law` フォルダを `~/.agents/skills/jp-law` に配置します（`~/.agents/skills/jp-law/SKILL.md` となるように配置してください）。
3. Goose のスキル設定に基づき読み込まれ、ローカルのシェル環境を通じてスクリプトが実行されます。

### Google Gemini についての注意

- **Gemini CLI / Google Antigravity**: Agent Skills（`SKILL.md`）仕様に準拠しており、ローカル端末上でシェルスクリプトを実行して正常に動作します。
- **Web 版 Gemini（gemini.google.com）**: Gemini Web の Skills はプロンプト・指示ベースの拡張であり、サンドボックス内でのシェルスクリプト実行機構を持ちません。そのため、本スキルは Web 版 Gemini では動作しません。Gemini CLI または Google Antigravity をご利用ください。

## 実行環境と依存関係

本スキルは同梱の bash スクリプト（`jp-law/scripts/*.sh`）から `curl` で e-Gov 法令 API V2 を呼び出します。エージェント側で bash および `curl` を実行できる環境が必要です。

### Windows ユーザー向け注意

スクリプトは bash で記述されているため、Windows 環境では Git for Windows 付属の Git Bash または WSL（Windows Subsystem for Linux）の利用を推奨します。Claude Code は内部で bash を起動するため追加設定なしで動作します。PowerShell / cmd から直接 `*.sh` を実行することはできません。

## 出典

- [Agent Skills (agentskills.io)](https://agentskills.io)
- [Agent Skills Overview (Anthropic)](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [How to create custom Skills (Claude Help)](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- [Build skills (OpenAI Codex)](https://developers.openai.com/codex/skills/)
- [e-Gov 法令 API V2 仕様](https://laws.e-gov.go.jp/api/2/swagger-ui)
