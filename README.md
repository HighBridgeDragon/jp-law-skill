# jp-law

[![skills.sh](https://skills.sh/b/HighBridgeDragon/jp-law-skill)](https://skills.sh/HighBridgeDragon/jp-law-skill)

**Search and retrieve Japanese laws and regulations from the official e-Gov Law API V2.** An [Agent Skill](https://agentskills.io) for Claude Code, Cursor, GitHub Copilot, and other compatible AI agents. No authentication required.

e-Gov 法令 API V2 を活用した日本法令調査スキル（Claude Code / AI Agent 向け）。法令名検索、条文取得、改正履歴、キーワード検索、過去時点の条文取得を AI エージェントから直接実行できます。

姉妹スキル: 国会審議の調査は [jp-diet-minutes-skill](https://github.com/HighBridgeDragon/jp-diet-minutes-skill) を併用すると、法令と国会審議を行き来する調査が可能になります。

## Install

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## What it does / 機能

インストール後、エージェントに以下のように依頼できます:

- "Show me Article 709 of the Japanese Civil Code" / 「民法第 709 条の条文を見せて」
- "Find Japanese laws about personal information protection" / 「個人情報保護に関する法律を探して」
- "List recent amendments to the Companies Act" / 「会社法の最近の改正履歴を教えて」
- "Search for articles containing '損害賠償'" / 「損害賠償を含む条文をキーワード検索して」
- "Show Article 709 of the Civil Code as it stood on 2020-01-01" / 「2020 年 1 月 1 日時点の民法第 709 条を見せて」

代表的なユースケース: 法務リサーチ、契約レビュー、コンプライアンス確認、法改正のモニタリング、税務・労務根拠条文の確認、学術調査。

## Capabilities / 提供機能

| Capability | Endpoint | 用途 |
|---|---|---|
| Law name search / 法令名検索 | `GET /laws` | 法令名から law_id を特定（既定 100 件/req） |
| Article retrieval / 条文取得 | `GET /law_data` | 法令本文または特定条文を取得。`elm` で条文単位、`asof` で時点指定可 |
| Amendment history / 改正履歴 | `GET /law_revisions` | 法令の改正履歴と各時点の law_revision_id を取得 |
| Full-text keyword search / キーワード検索 | `GET /keyword` | 全法令本文の横断検索（既定 100、最大 1000 件/req、AND/OR/NOT・ワイルドカード対応） |

Supported agents / 対応エージェント: [Claude Code](https://docs.anthropic.com/en/docs/claude-code), GitHub Copilot (Copilot CLI), Cursor, Cline, Claude Desktop, and any other [Agent Skills](https://agentskills.io)-compatible runtime.

## 依存

本スキルは同梱の bash スクリプト（`jp-law/scripts/*.sh`）から `curl` で API を呼び出します。エージェント側で bash を実行できれば動作します:

| エージェント | 推奨実行手段 |
|---|---|
| Claude Code | 標準同梱の `Bash` ツール（追加セットアップ不要） |
| GitHub Copilot CLI / Cursor / Cline / Claude Desktop | エージェントのシェル実行機能（または bash 実行可能な MCP サーバ） |
| その他 | 任意のシェル統合 |

### Windows ユーザー向け注意

スクリプトは bash で書かれているため、Windows では Git for Windows 付属の Git Bash か WSL の利用を推奨します。Claude Code は内部で bash を起動するため追加設定なしで動作します。PowerShell / cmd から直接 `*.sh` を実行することはできません。

## e-Gov 法令 API V2

- [公式サイト](https://laws.e-gov.go.jp/)
- [Swagger UI](https://laws.e-gov.go.jp/api/2/swagger-ui)
- [Redoc](https://laws.e-gov.go.jp/api/2/redoc/)

### 対象範囲

- ✅ **国の法令**: 憲法、法律、政令、勅令、府省令、規則、その他（`law_type` enum: `Constitution` / `Act` / `CabinetOrder` / `ImperialOrder` / `MinisterialOrdinance` / `Rule` / `Misc`）
- ❌ **対象外**: 条約、告示、通達、ガイドライン、地方自治体の条例・規則

条約・告示・通達等が必要な場合は各府省の公式サイトや官報を、地方条例は各自治体の例規集を直接参照してください。

## 関連スキル

- [jp-diet-minutes-skill](https://github.com/HighBridgeDragon/jp-diet-minutes-skill) — 国会会議録の検索・取得（NDL 国会会議録 API）

## 開発者向け

### 法令ID検証

`jp-law/references/law-aliases.md`に記載された全法令IDの有効性を検証できます:

```bash
cd jp-law
bash scripts/validate-law-ids.sh
```

詳細は [docs/validate-law-ids.md](docs/validate-law-ids.md) を参照してください。

### スクリプト一覧

- `fetch-law.sh` - 法令本文データ取得
- `fetch-revisions.sh` - 改正履歴取得
- `search-laws.sh` - 法令名検索
- `search-keyword.sh` - キーワード検索
- `validate-law-ids.sh` - 法令ID検証
- `extract-law-ids.sh` - 法令ID一覧抽出

詳細は [jp-law/scripts/README.md](jp-law/scripts/README.md) を参照してください。

## ライセンス

[MIT](LICENSE)
