---
name: egov-law
description: 日本の法令を検索・取得するスキル。e-Gov法令API V2を使用し、法令名検索、条文取得、改正履歴、キーワード検索が可能。Use this skill when researching Japanese laws, regulations, or legal texts.
license: MIT
---

# e-Gov 法令調査スキル

e-Gov法令API V2経由で日本の法令を調査する。認証不要。`mcp-server-fetch` でREST APIを呼び出す。

## 基本ルール

- Base URL: `https://laws.e-gov.go.jp/api/2`
- レスポンス形式: JSON（既定）
- 認証: 不要
- 呼び出し方法: `fetch` ツール（mcp-server-fetch）でGETリクエスト

## エンドポイント選択

ユーザーの要求に応じて適切なエンドポイントを選ぶ:

```
「○○法の第X条を見せて」
  → law-aliases.md で law_id を引く
  → GET /law_data/{law_id}?elm=MainProvision-Article_X

「○○に関する法律を探して」
  → GET /laws?law_title=○○

「△△というキーワードを含む条文を探して」
  → GET /keyword?keyword=△△

「○○法の改正履歴を調べて」
  → law-aliases.md で law_id を引く
  → GET /law_revisions/{law_id}

「○○法の全文を取得して」
  → GET /law_data/{law_id}
  ※ 大規模法令は全文取得を避け、elm パラメータで条文単位取得を推奨
```

## 各エンドポイントの使い方

### 1. 法令検索 — GET /laws

法令名で検索し、law_id を特定する。

```
fetch https://laws.e-gov.go.jp/api/2/laws?law_title=個人情報保護&limit=5
```

主要パラメータ: `law_title`(法令名), `law_type`(種別), `category_cd`(分類コード), `limit`, `offset`

レスポンスの `laws[].law_info.law_id` が法令ID。詳細は [api-reference.md](references/api-reference.md) 参照。

### 2. 法令本文取得 — GET /law_data/{law_id_or_num_or_revision_id}

法令の全文または特定条文を取得する。

```
# 民法第709条のみ取得（トークン節約）
fetch https://laws.e-gov.go.jp/api/2/law_data/129AC0000000089?elm=MainProvision-Article_709

# 民法全文（注意: 大量データ）
fetch https://laws.e-gov.go.jp/api/2/law_data/129AC0000000089
```

**elm パラメータで条文を絞り込む**（ハイフン区切りで階層指定）:

| 指定例 | 取得範囲 |
|---|---|
| `MainProvision-Article_1` | 第1条全体 |
| `MainProvision-Article_1-Paragraph_2` | 第1条第2項 |
| `MainProvision-Part_3-Chapter_2` | 第3編第2章全体 |
| `SupplProvision[1]` | 附則（1番目） |

レスポンスの `law_full_text` はtag/attr/children再帰構造。解析方法は [response-format.md](references/response-format.md) 参照。

### 3. 改正履歴 — GET /law_revisions/{law_id_or_num}

```
fetch https://laws.e-gov.go.jp/api/2/law_revisions/129AC0000000089
```

`revisions[]` 配列に改正履歴が新しい順で格納される。`law_revision_id` を使って特定時点の法令本文を取得可能。

### 4. キーワード検索 — GET /keyword

法令本文中のキーワードを全文検索する。

```
fetch https://laws.e-gov.go.jp/api/2/keyword?keyword=損害賠償&limit=10
```

- `keyword` は必須。`AND`, `OR`, `NOT`, ワイルドカード(`*`, `?`)対応
- ヒット箇所は `<span>` タグで囲まれる
- `limit` は条文位置数の総和の上限（法令件数ではない）

## トークン節約ガイダンス

法令全文は非常に大きい（民法: 数万行）。以下を守ること:

1. **条文単位で取得する**: `elm=MainProvision-Article_709` のように `elm` パラメータを常に使う
2. **必要な条文だけ取得する**: 「第709条から第724条まで」のような範囲指定はできないため、1条ずつ取得する
3. **検索→特定→取得の順序**: まず `/laws` や `/keyword` で該当法令・条文を特定してから `/law_data` で取得
4. **全文取得は最終手段**: ユーザーが明示的に全文を要求した場合のみ

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

## 出力フォーマット

法令情報をユーザーに提示する際の推奨フォーマット:

```
【法令名】○○法（law_id: XXXXX）
【条文】第X条（第Y項）
【内容】
条文テキストをここに記載

【出典】e-Gov法令検索 https://laws.e-gov.go.jp/law/XXXXX
```

改正履歴を提示する場合:

```
【法令名】○○法
【改正履歴】（直近N件）
- YYYY-MM-DD: ○○法の一部を改正する法律（令和X年法律第X号）
- YYYY-MM-DD: ...
```
