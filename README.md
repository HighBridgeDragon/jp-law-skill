# jp-law

[![skills.sh](https://skills.sh/b/HighBridgeDragon/jp-law-skill)](https://skills.sh/HighBridgeDragon/jp-law-skill)

**Search and retrieve Japanese laws and regulations from the official e-Gov Law API V2.** An [Agent Skill](https://agentskills.io) for Claude Code, Cursor, GitHub Copilot, and other compatible AI agents. No authentication required.

e-Gov法令API V2を活用した日本法令調査スキル（Claude Code / AI Agent向け）。日本の法令の検索・条文取得・改正履歴・キーワード検索をAIエージェントから直接実行できます。

## Install

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## What it does / 機能

Once installed, ask your agent things like:

- "Show me Article 709 of the Japanese Civil Code" / 「民法第709条の条文を見せて」
- "Find Japanese laws about personal information protection" / 「個人情報保護に関する法律を探して」
- "List recent amendments to the Companies Act" / 「会社法の最近の改正履歴を教えて」
- "Search for articles containing the keyword '損害賠償' (damages)" / 「損害賠償に関する条文をキーワード検索して」

Typical use cases: compliance research, contract review, legal due diligence, regulatory monitoring, academic research on Japanese law.

## Capabilities / 提供機能

| Capability | Endpoint | Script |
|------|---------------|-----|
| Law name search / 法令名検索 | `GET /laws` | `search-laws.sh` |
| Article retrieval / 条文取得 | `GET /law_data` | `fetch-law.sh` |
| Amendment history / 改正履歴 | `GET /law_revisions` | `fetch-revisions.sh` |
| Full-text keyword search / キーワード検索 | `GET /keyword` | `search-keyword.sh` |

Supported agents / 対応エージェント: [Claude Code](https://docs.anthropic.com/en/docs/claude-code), GitHub Copilot (Copilot CLI), Cursor, and any other [Agent Skills](https://agentskills.io)-compatible runtime.

## 依存

- `curl`（APIの呼び出しに使用、認証不要）

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

## e-Gov法令API V2

- [公式サイト](https://laws.e-gov.go.jp/)
- [Swagger UI](https://laws.e-gov.go.jp/api/2/swagger-ui)
- [Redoc](https://laws.e-gov.go.jp/api/2/redoc/)

## ライセンス

[MIT](LICENSE)
