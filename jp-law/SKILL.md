---
name: jp-law
description: 日本の法令を検索・取得するスキル。e-Gov法令API V2を使用し、法令名検索、条文取得、改正履歴、キーワード検索が可能。Use this skill when researching Japanese laws, regulations, or legal texts.
license: MIT
---

# e-Gov 法令調査スキル

e-Gov法令API V2経由で日本の法令を調査する。認証不要。同梱スクリプト（`scripts/`）でAPIを呼び出す。

## 基本ルール

- Base URL: `https://laws.e-gov.go.jp/api/2`
- レスポンス形式: JSON（既定）
- 認証: 不要
- 呼び出し方法: `bash scripts/<script>.sh` で実行（curl のみ依存、外部ツール不要）

## エンドポイント選択

ユーザーの要求に応じて適切なエンドポイントを選ぶ:

```text
「○○法の第X条を見せて」
  → law-aliases.md で law_id を引く
  → bash scripts/fetch-law.sh {law_id} MainProvision-Article_X

「○○に関する法律を探して」
  → bash scripts/search-laws.sh ○○

「△△というキーワードを含む条文を探して」
  → bash scripts/search-keyword.sh △△

「○○法の改正履歴を調べて」
  → law-aliases.md で law_id を引く
  → bash scripts/fetch-revisions.sh {law_id}

「○○法の全文を取得して」
  → bash scripts/fetch-law.sh {law_id}
  ※ 大規模法令は全文取得を避け、elm パラメータで条文単位取得を推奨

「○○法の2020年時点の条文を見せて」
  → curl -s "https://laws.e-gov.go.jp/api/2/law_data/{law_id}?elm=MainProvision-Article_X&asof=2020-01-01"
  ※ elm なしの場合: ?asof=2020-01-01 のみ
```

## 各エンドポイントの使い方

### 1. 法令検索 — search-laws.sh

法令名で検索し、law_id を特定する。

```bash
bash scripts/search-laws.sh 個人情報保護 5
# Usage: bash scripts/search-laws.sh <law_title> [limit]
```

主要パラメータ: `law_title`(法令名), `limit`(件数、既定10)

レスポンスの `laws[].law_info.law_id` が法令ID。詳細は [api-reference.md](references/api-reference.md) 参照。

### 2. 法令本文取得 — fetch-law.sh

法令の全文または特定条文を取得する。

```bash
# 民法第709条のみ取得（トークン節約）
bash scripts/fetch-law.sh 129AC0000000089 MainProvision-Article_709

# 民法全文（注意: 大量データ）
bash scripts/fetch-law.sh 129AC0000000089
# Usage: bash scripts/fetch-law.sh <law_id> [elm]
```

**elm パラメータで条文を絞り込む**（ハイフン区切りで階層指定）:

| 指定例 | 取得範囲 |
|---|---|
| `MainProvision-Article_1` | 第1条全体 |
| `MainProvision-Article_1-Paragraph_2` | 第1条第2項 |
| `MainProvision-Part_3-Chapter_2` | 第3編第2章全体 |
| `SupplProvision[1]` | 附則（1番目） |

レスポンスの `law_full_text` はtag/attr/children再帰構造。解析方法は [response-format.md](references/response-format.md) 参照。

### 3. 改正履歴 — fetch-revisions.sh

```bash
bash scripts/fetch-revisions.sh 129AC0000000089
# Usage: bash scripts/fetch-revisions.sh <law_id>
```

`revisions[]` 配列に改正履歴が新しい順で格納される。`law_revision_id` を使って特定時点の法令本文を取得可能。

### 4. キーワード検索 — search-keyword.sh

法令本文中のキーワードを全文検索する。

```bash
bash scripts/search-keyword.sh 損害賠償 10
# Usage: bash scripts/search-keyword.sh <keyword> [limit]
```

- `keyword` は必須。`AND`, `OR`, `NOT`, ワイルドカード(`*`, `?`)対応
- ヒット箇所は `<span>` タグで囲まれる
- `limit` は条文位置数の総和の上限（法令件数ではない）

## トークン節約ガイダンス

法令全文は非常に大きい（民法: 数万行）。以下を守ること:

1. **条文単位で取得する**: `elm=MainProvision-Article_709` のように `elm` パラメータを常に使う
2. **必要な条文だけ取得する**: 条文単位で1条ずつ取得する。ただし `elm` でChapter/Section等の上位要素を指定すれば、配下の複数条文をまとめて取得可能（例: `elm=MainProvision-Chapter_3` で章全体）
3. **検索→特定→取得の順序**: まず `/laws` や `/keyword` で該当法令・条文を特定してから `/law_data` で取得
4. **全文取得は最終手段**: ユーザーが明示的に全文を要求した場合のみ

## キーワード検索のフォールバック戦略

短い英字略語（AI / IoT / DX 等）は API でヒットしにくい。目的に応じてスクリプトを選び、0 件なら日本語訳語にフォールバックする:

| 目的 | スクリプト | フォールバック |
|---|---|---|
| **条文を探す** | `bash scripts/search-keyword.sh <キーワード>` | 0 件（`{"code":"404001"}`）なら日本語訳語（人工知能 / モノのインターネット / デジタルトランスフォーメーション 等）で再試行 |
| **法令名を探す** | `bash scripts/search-laws.sh <キーワード>` | 0 件なら日本語訳語で再試行 |

両者は併用可。入口がわからないときは条文 → 法令名の順で試すと効率的:

例: 「AI に関する法律」→ `bash scripts/search-keyword.sh AI`（0 件）→ `bash scripts/search-keyword.sh 人工知能`（条文 160 件）→ `bash scripts/search-laws.sh 人工知能` で `507AC0000000053`（人工知能関連技術の研究開発及び活用の推進に関する法律、通称ＡＩ法）を発見。

## よく使う法令

主要法令の law_id は [law-aliases.md](references/law-aliases.md) を参照。

よく参照される法令:

| 通称 | law_id |
|---|---|
| 民法 | `129AC0000000089` |
| 刑法 | `140AC0000000045` |
| 会社法 | `417AC0000000086` |
| 個人情報保護法 | `415AC0000000057` |
| 労働基準法 | `322AC0000000049` |
| 憲法 | `321CONSTITUTION` |

## 注意事項

1. **law_id と law_revision_id は別物**: `law_id`は法令を一意に識別、`law_revision_id`は特定の改正時点を識別する
2. **elm パラメータの条番号**: 枝番号はアンダースコア表記（例: 第398条の22 → `Article_398_22`）
3. **law_full_text の構造**: JSON詳細版（既定）はtag/attr/childrenの再帰ツリー。テキストはchildrenの末端に文字列として格納される
4. **キーワード検索のlimit**: `/keyword` の `limit` は法令件数ではなく条文位置数の総和の上限
5. **日付パラメータ**: `asof` で過去の時点の法令を取得可能（`YYYY-MM-DD` 形式）
6. **法令番号でも検索可能**: `/law_data` のパスパラメータには law_id 以外に法令番号も指定可能
7. **Base64に注意**: `law_full_text_format` と `response_format` を異なる値にすると `law_full_text` がBase64エンコードで返却される。通常はどちらも既定値（json）のまま使用すること

## 出力フォーマット

法令情報をユーザーに提示する際の推奨フォーマット:

```text
【法令名】○○法（law_id: XXXXX）
【条文】第X条（第Y項）
【内容】
条文テキストをここに記載

【出典】e-Gov法令検索 https://laws.e-gov.go.jp/law/XXXXX
```

改正履歴を提示する場合:

```text
【法令名】○○法
【改正履歴】（直近N件）
- YYYY-MM-DD: ○○法の一部を改正する法律（令和X年法律第X号）
- YYYY-MM-DD: ...
```
