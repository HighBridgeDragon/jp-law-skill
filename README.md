# jp-law

e-Gov法令API V2を活用した日本法令調査スキル（Claude Code / AI Agent向け）

日本の法令の検索・条文取得・改正履歴・キーワード検索をAIエージェントから直接実行できます。

## インストール

```bash
npx skills add HighBridgeDragon/jp-law-skill
```

## 対応プラットフォーム

[Agent Skills](https://agentskills.io) 仕様に準拠したAIエージェント:

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- GitHub Copilot (Copilot CLI)
- Cursor
- その他 Agent Skills 対応環境

## 機能

| 機能 | エンドポイント | 例 |
|------|---------------|-----|
| 法令名検索 | GET /laws | 「個人情報保護」で法令を検索 |
| 条文取得 | GET /law_data | 民法第709条を取得 |
| 改正履歴 | GET /law_revisions | 会社法の改正履歴を一覧 |
| キーワード検索 | GET /keyword | 「損害賠償」を含む条文を検索 |

## 使用例

スキルをインストール後、AIエージェントに以下のように依頼できます:

- 「民法第709条の条文を見せて」
- 「個人情報保護に関する法律を探して」
- 「会社法の最近の改正履歴を教えて」
- 「損害賠償に関する条文をキーワード検索して」

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
