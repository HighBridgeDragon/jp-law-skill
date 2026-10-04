# インストールガイド / Installation Guide

本スキル（`jp-law`）の各種 AI エージェントおよびクライアントへの導入手順と動作条件です。

## CLI / パッケージマネージャ

対応クライアント: Claude Code, Cursor, GitHub Copilot CLI, Gemini CLI ほか

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

上記コマンドでお使いのエージェント環境（プロジェクトの `.agents/skills` やグローバル設定など）に自動インストールされます。

## 各種クライアントへの導入手順（デスクトップ / Web アプリ）

Claude Desktop, claude.ai, OpenAI Codex, Goose, Gemini CLI 等への共通導入手順は、以下の共通ガイドをご確認ください。

👉 [**クライアント別共通インストールガイド (jp-skills-shared)**](https://github.com/HighBridgeDragon/jp-skills-shared/blob/main/docs/install-guide.md)

- Releases 添付の `jp-law.zip` を用いた導入手順
- 各クライアントでの配置先および動作要件

## 本スキル固有の動作要件・必須設定

### claude.ai / Claude Desktop の許可ドメイン

claude.ai のコード実行環境から本スキルを利用する場合、以下のドメインへの外部アクセス許可が必要です：

- **許可ドメイン**: `laws.e-gov.go.jp`

組織オーナー（Organization Owner）による許可ドメインへの追加設定を行ってください（手順詳細は上記共通ガイドの「動作条件」節を参照。個人プランには追加設定がありません）。許可ドメインを追加できない環境では、Claude Code 経由をご利用ください。

### 実行環境と依存関係

本スキルは同梱の bash スクリプト（`jp-law/scripts/*.sh`）から `curl` で e-Gov 法令 API V2 を呼び出します。エージェント側で bash および `curl` を実行できる環境が必要です。

- **Windows 環境**: スクリプトが bash で記述されているため、Git for Windows 付属の Git Bash または WSL（Windows Subsystem for Linux）の利用を推奨します。Claude Code は内部で bash を起動するため追加設定なしで動作します。PowerShell / cmd から直接 `*.sh` を実行することはできません。

## 出典

- [e-Gov 法令 API V2 仕様](https://laws.e-gov.go.jp/api/2/swagger-ui)
- クライアント仕様・規格の出典一覧は [共通インストールガイドの出典節](https://github.com/HighBridgeDragon/jp-skills-shared/blob/main/docs/install-guide.md#出典) を参照
