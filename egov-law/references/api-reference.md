---
name: e-Gov Law API V2 Reference
description: 4エンドポイントの詳細仕様（パラメータ・レスポンス・ページネーション）
---

# e-Gov Law API V2 Reference

Base URL: `https://laws.e-gov.go.jp/api/2`

OpenAPI spec: `https://laws.e-gov.go.jp/api/2/swagger-ui/lawapi-v2.yaml`

認証不要。レスポンス形式は JSON / XML（全エンドポイント共通で `response_format` パラメータまたは Accept ヘッダで切り替え可能。既定は JSON）。

---

## 1. GET /laws -- 法令一覧取得

指定条件に該当する法令の一覧を返す。必須パラメータなし。

### Query Parameters

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `law_id` | string | - | 法令ID（部分一致） |
| `law_num` | string | - | 法令番号（部分一致）例: `昭和二十二年政令第十六号` |
| `law_num_era` | string (enum) | - | 元号。`Meiji` `Taisho` `Showa` `Heisei` `Reiwa` |
| `law_num_year` | integer | - | 法令番号の年 |
| `law_num_type` | string (enum) | - | `Constitution` `Act` `CabinetOrder` `ImperialOrder` `MinisterialOrdinance` `Rule` `Misc` |
| `law_num_num` | string | - | 法令番号の号数 |
| `law_title` | string | - | 法令名または法令略称（部分一致） |
| `law_title_kana` | string | - | 法令名読み（部分一致） |
| `law_type` | string[] (enum) | - | 法令種別（カンマ区切りで複数指定可）。値は `law_num_type` と同じ |
| `asof` | date | - | 法令の時点。指定時点以前で最新の改正履歴を `revision_info` に格納。省略時は現時点 |
| `category_cd` | string[] (enum) | - | 事項別分類コード（複数可）。`001`(憲法)〜`050`(外事) |
| `mission` | string[] (enum) | - | `New`(新規制定/被改正) `Partial`(一部改正) |
| `repeal_status` | string[] (enum) | - | `None` `Repeal` `Expire` `Suspend` `LossOfEffectiveness` |
| `promulgation_date_from` | date | - | 公布日（以後） |
| `promulgation_date_to` | date | - | 公布日（以前） |
| `amendment_law_id` | string | - | 改正法令の法令ID（部分一致）。指定時 `asof` は無視される |
| `omit_current_revision_info` | boolean | - | `true` で `current_revision_info` を省略。既定 `false` |
| `order` | string | - | 並び順。`+law_info.law_id,-revision_info.amendment_promulgate_date` 形式。既定 `law_info.law_id` |
| `limit` | integer | - | 取得件数上限。既定 `100` |
| `offset` | integer | - | 取得開始位置。既定 `0` |
| `response_format` | string (enum) | - | `json` or `xml` |

### Response (200)

```json
{
  "total_count": 11,
  "count": 3,
  "next_offset": 3,
  "laws": [
    {
      "law_info": { ... },
      "revision_info": { ... },
      "current_revision_info": { ... }
    }
  ]
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `total_count` | integer | 検索条件にマッチした全件数（limit/offset 適用前） |
| `count` | integer | 返却件数（limit/offset 適用後） |
| `next_offset` | integer\|null | 次ページの offset 値。末尾到達時は `null` |
| `laws[]` | array | 法令情報の配列 |
| `laws[].law_info` | object | 改正履歴に依存しない法令情報 |
| `laws[].revision_info` | object | `asof` 時点で最新の改正履歴情報 |
| `laws[].current_revision_info` | object | 現時点で最新の改正履歴情報（`omit_current_revision_info=true` で省略） |

---

## 2. GET /law_data/{law_id_or_num_or_revision_id} -- 法令本文取得

法令の本文（全文または部分）を取得する。

### Path Parameters

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `law_id_or_num_or_revision_id` | string | **YES** | 法令ID、法令番号、または法令履歴ID（完全一致） |

### Query Parameters

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `asof` | date | - | 法令の時点。law_revision_id 指定時は無視 |
| `elm` | string | - | 取得する法令本文の要素指定。例: `MainProvision-Article_1-Paragraph_1` |
| `response_format` | string (enum) | - | `json` or `xml` |
| `law_full_text_format` | string (enum) | - | 法令本文の形式。`json` or `xml`。`response_format` と異なる場合、`law_full_text` は Base64 エンコードで返却 |
| `json_format` | string (enum) | - | `full`(詳細版、既定) or `light`(簡易版)。JSON 形式時のみ有効 |
| `omit_amendment_suppl_provision` | boolean | - | `true` で改正法令の附則を除外。既定 `false` |
| `include_attached_file_content` | boolean | - | `true` で `attached_files_info.image_data` を返却。既定 `false` |

### Response (200)

```json
{
  "attached_files_info": {
    "image_data": "",
    "attached_files": [
      {
        "law_revision_id": "...",
        "src": "./pict/H11HO127-001.jpg",
        "updated": "2023-07-01T14:30:15+09:00"
      }
    ]
  },
  "law_info": { ... },
  "revision_info": { ... },
  "law_full_text": {
    "tag": "Law",
    "attr": {
      "Lang": "ja",
      "Era": "Meiji",
      "Year": "29",
      "Num": "089",
      "LawType": "Act",
      "PromulgateMonth": "04",
      "PromulgateDay": "27"
    },
    "children": [ ... ]
  }
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `attached_files_info` | object\|null | 添付ファイル情報。添付がない場合は `null` |
| `law_info` | object | 法令基本情報 |
| `revision_info` | object | 改正履歴情報 |
| `law_full_text` | object\|string | JSON 詳細版の場合は `{tag, attr, children}` ツリー構造。`response_format` と `law_full_text_format` が異なる場合は Base64 文字列 |

#### law_full_text JSON 構造（詳細版: json_format=full）

各 XML 要素が `{tag, attr, children}` オブジェクトにマッピングされる。`children` はオブジェクトまたはテキスト文字列の配列。

#### law_full_text JSON 構造（簡易版: json_format=light）

XML タグ名がキーとなるネスト構造。インライン要素（Ruby 等）はテキストにタグごと埋め込まれる。属性は `AmendLawNum`, `Extract`, `Paragraph` の `Num` のみフィールドとして含まれる。

#### elm パラメータの指定方法

要素を `-`（ハイフン）で結合して階層を指定する。

| 要素 | 意味 | 指定例 |
|---|---|---|
| `MainProvision` | 本則 | `MainProvision[1]` |
| `Part` | 編 | `Part_1` |
| `Chapter` | 章 | `Chapter_1` |
| `Section` | 節 | `Section_1` |
| `Article` | 条 | `Article_1` |
| `Paragraph` | 項 | `Paragraph_1` |
| `Item` | 号 | `Item_1` |
| `SupplProvision` | 附則 | `SupplProvision[1]` |
| `AppdxTable` | 別表 | `AppdxTable[1]` |

組み合わせ例: `MainProvision-Article_709-Paragraph_1`

---

## 3. GET /law_revisions/{law_id_or_num} -- 法令履歴一覧取得

指定した法令の改正履歴一覧を返す。履歴は `law_revision_id` の新しい順。

### Path Parameters

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `law_id_or_num` | string | **YES** | 法令ID または 法令番号（完全一致） |

### Query Parameters

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `law_title` | string | - | 法令名（部分一致）。`/正規表現/` で囲むと正規表現による完全一致 |
| `law_title_kana` | string | - | 法令名読み（部分一致） |
| `amendment_date_from` | date | - | 改正法令施行期日（以後） |
| `amendment_date_to` | date | - | 改正法令施行期日（以前） |
| `amendment_law_id` | string | - | 改正法令の法令ID（部分一致） |
| `amendment_law_num` | string | - | 改正法令の法令番号（部分一致） |
| `amendment_law_title` | string | - | 改正法令名（部分一致 or `/正規表現/`） |
| `amendment_law_title_kana` | string | - | 改正法令名読み（部分一致） |
| `amendment_promulgate_date_from` | date | - | 改正法令公布日（以後） |
| `amendment_promulgate_date_to` | date | - | 改正法令公布日（以前） |
| `amendment_type` | string[] (enum) | - | 改正種別。`1`(新規) `3`(被改正) `8`(廃止) |
| `category_cd` | string[] (enum) | - | 事項別分類コード |
| `current_revision_status` | string[] (enum) | - | 履歴の状態。`CurrentEnforced` `UnEnforced` `PreviousEnforced` `Repeal` |
| `mission` | string[] (enum) | - | `New` `Partial` |
| `remain_in_force` | boolean | - | 廃止後の効力 |
| `repeal_status` | string[] (enum) | - | `None` `Repeal` `Expire` `Suspend` `LossOfEffectiveness` |
| `repeal_date_from` | date | - | 廃止日（以後） |
| `repeal_date_to` | date | - | 廃止日（以前） |
| `updated_from` | date | - | データ更新日（以後） |
| `updated_to` | date | - | データ更新日（以前） |
| `response_format` | string (enum) | - | `json` or `xml` |

### Response (200)

```json
{
  "law_info": {
    "law_type": "Act",
    "law_id": "129AC0000000089",
    "law_num": "明治二十九年法律第八十九号",
    "law_num_era": "Meiji",
    "law_num_year": 29,
    "law_num_type": "Act",
    "law_num_num": "089",
    "promulgation_date": "1896-04-27"
  },
  "revisions": [
    {
      "law_revision_id": "129AC0000000089_20260401_506AC0000000033",
      "law_type": "Act",
      "law_title": "民法",
      "law_title_kana": "みんぽう",
      "abbrev": null,
      "category": "民事",
      "updated": "2026-04-01T00:01:25+09:00",
      "amendment_promulgate_date": "2024-05-24",
      "amendment_enforcement_date": "2026-04-01",
      "amendment_enforcement_comment": null,
      "amendment_scheduled_enforcement_date": null,
      "amendment_law_id": "506AC0000000033",
      "amendment_law_title": "民法等の一部を改正する法律",
      "amendment_law_title_kana": null,
      "amendment_law_num": "令和六年法律第三十三号",
      "amendment_type": "3",
      "repeal_status": "None",
      "repeal_date": null,
      "remain_in_force": false,
      "mission": "New",
      "current_revision_status": "CurrentEnforced"
    }
  ]
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `law_info` | object | 法令基本情報 |
| `revisions[]` | array | 改正履歴の配列（新しい順） |

---

## 4. GET /keyword -- キーワード検索

法令本文内のキーワード全文検索。ヒットした条文テキストを返す。

### Query Parameters

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `keyword` | string | **YES** | 検索キーワード。ワイルドカード(`*`, `?`)、AND/OR/NOT 検索対応 |
| `law_num` | string | - | 法令番号（部分一致） |
| `law_num_era` | string (enum) | - | 元号 |
| `law_num_year` | integer | - | 年 |
| `law_num_type` | string (enum) | - | 法令番号の法令種別 |
| `law_num_num` | string | - | 号数 |
| `law_type` | string[] (enum) | - | 法令種別（複数可） |
| `asof` | date | - | 法令の時点 |
| `category_cd` | string[] (enum) | - | 事項別分類コード（複数可） |
| `promulgation_date_from` | date | - | 公布日（以後） |
| `promulgation_date_to` | date | - | 公布日（以前） |
| `limit` | integer | - | `sentences` の `position` 数の総和の上限。既定 `100`、上限 `1000` |
| `offset` | integer | - | 取得開始位置。既定 `0` |
| `order` | string | - | 並び順 |
| `sentences_limit` | integer | - | 各法令あたりの `sentences` 表示件数制限 |
| `sentence_text_size` | integer | - | `text` の表示文字数（HTMLタグ含む）。既定 `100` |
| `highlight_tag` | string | - | ヒット箇所を囲むHTMLタグ名。既定 `span` |
| `response_format` | string (enum) | - | `json` or `xml` |

### Response (200)

```json
{
  "total_count": 2512,
  "sentence_count": 3,
  "next_offset": 3,
  "items": [
    {
      "law_info": {
        "law_type": "Act",
        "law_id": "129AC0000000089",
        "law_num": "明治二十九年法律第八十九号",
        "law_num_era": "Meiji",
        "law_num_year": 29,
        "law_num_type": "Act",
        "law_num_num": "089",
        "promulgation_date": "1896-04-27"
      },
      "revision_info": { ... },
      "sentences": [
        {
          "position": "mainprovision",
          "text": "...相手方に対して履行又は<span>損害賠償</span>の責任を負う。"
        }
      ]
    }
  ]
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `total_count` | integer | キーワードにヒットした法令の総件数 |
| `sentence_count` | integer | 返却された `sentences` の `position` 数の総和 |
| `next_offset` | integer\|null | 次ページの offset 値。末尾到達時は `null` |
| `items[]` | array | 法令単位の検索結果 |
| `items[].law_info` | object | 法令基本情報 |
| `items[].revision_info` | object | 改正履歴情報 |
| `items[].sentences[]` | array | ヒット箇所一覧 |
| `items[].sentences[].position` | string | ヒット箇所の法令構造上の位置（例: `mainprovision`, `caption`, `amendsupplprovision`） |
| `items[].sentences[].text` | string | 条文テキスト。ヒット箇所は `<span>` タグ（`highlight_tag` で変更可）で囲まれる |

---

## 共通オブジェクト定義

### law_info

改正履歴に依存しない法令のメタ情報。

| フィールド | 型 | 説明 |
|---|---|---|
| `law_type` | string | 法令種別 |
| `law_id` | string | 法令ID（例: `129AC0000000089`） |
| `law_num` | string | 法令番号（例: `明治二十九年法律第八十九号`） |
| `law_num_era` | string | 元号（`Meiji` `Taisho` `Showa` `Heisei` `Reiwa`） |
| `law_num_year` | integer | 年 |
| `law_num_type` | string | 法令番号の法令種別 |
| `law_num_num` | string | 号数 |
| `promulgation_date` | date | 公布日（`YYYY-MM-DD`） |

### revision_info

法令の改正履歴に関する情報。`/laws` では `revision_info` と `current_revision_info` の両方で使用。

| フィールド | 型 | 説明 |
|---|---|---|
| `law_revision_id` | string | 法令履歴ID（例: `129AC0000000089_20260401_506AC0000000033`） |
| `law_type` | string | 法令種別 |
| `law_title` | string | 法令名 |
| `law_title_kana` | string | 法令名読み |
| `abbrev` | string\|null | 法令略称（カンマ区切り） |
| `category` | string | 法令分野分類（例: `民事`） |
| `updated` | datetime | 正誤等による更新日時（ISO 8601） |
| `amendment_promulgate_date` | date | 改正法令公布日 |
| `amendment_enforcement_date` | date | 改正法令施行期日 |
| `amendment_enforcement_comment` | string\|null | 施行期日規定等の参考情報 |
| `amendment_scheduled_enforcement_date` | date\|null | 擬似的な施行期日（未施行法令で使用） |
| `amendment_law_id` | string\|null | 改正法令の法令ID |
| `amendment_law_title` | string\|null | 改正法令名 |
| `amendment_law_title_kana` | string\|null | 改正法令名読み |
| `amendment_law_num` | string\|null | 改正法令番号 |
| `amendment_type` | string | 改正種別。`1`(新規) `3`(被改正) `8`(廃止) |
| `repeal_status` | string | 廃止状態。`None` `Repeal` `Expire` `Suspend` `LossOfEffectiveness` |
| `repeal_date` | date\|null | 廃止日 |
| `remain_in_force` | boolean | 廃止後の効力 |
| `mission` | string | `New`(新規制定/被改正) or `Partial`(一部改正) |
| `current_revision_status` | string | 履歴の状態。`CurrentEnforced` `UnEnforced` `PreviousEnforced` `Repeal` |

---

## ページネーション

`/laws` と `/keyword` はページネーション対応。

- `limit`: 1ページあたりの取得件数（既定 `100`）
- `offset`: 取得開始位置（既定 `0`）
- レスポンスの `next_offset` を次リクエストの `offset` に渡す
- `next_offset` が `null` なら最終ページ

`/keyword` の `limit` は `sentences` の `position` 数の総和の上限であり、法令件数ではない点に注意（上限 `1000`）。

---

## エラーレスポンス

全エンドポイント共通。HTTP 400 / 500 時に返却。

```json
{
  "code": "400043",
  "message": "法令ID、法令番号、又は法令履歴ID（law_id_or_num_or_revision_id）が誤っています。"
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `code` | string | エラーコード（`400xxx` はクライアントエラー、`500xxx` はサーバエラー） |
| `message` | string | エラーメッセージ（日本語） |

確認されたエラーコード例:

| code | message |
|---|---|
| `400001` | 法令種別（law_type、law_num_type）が誤っています。 |
| `400004` | 日付（asof等）が誤っています。 |
| `400043` | 法令ID、法令番号、又は法令履歴ID（law_id_or_num_or_revision_id）が誤っています。 |
| `404003` | 指定のパラメータで取得できる添付ファイルは存在しません。 |
| `500001` | サーバ内処理で異常が発生しました。 |

---

## 列挙型一覧

### law_type / law_num_type

| 値 | 説明 |
|---|---|
| `Constitution` | 憲法 |
| `Act` | 法律 |
| `CabinetOrder` | 政令 |
| `ImperialOrder` | 勅令 |
| `MinisterialOrdinance` | 府省令 |
| `Rule` | 規則 |
| `Misc` | その他 |

### law_num_era

| 値 | 説明 |
|---|---|
| `Meiji` | 明治 |
| `Taisho` | 大正 |
| `Showa` | 昭和 |
| `Heisei` | 平成 |
| `Reiwa` | 令和 |

### amendment_type

| 値 | 説明 |
|---|---|
| `1` | 新規 |
| `3` | 被改正 |
| `8` | 廃止 |

### repeal_status

| 値 | 説明 |
|---|---|
| `None` | 廃止・失効等の状態なし |
| `Repeal` | 廃止 |
| `Expire` | 失効 |
| `Suspend` | 停止 |
| `LossOfEffectiveness` | 実効性喪失 |

### current_revision_status

| 値 | 説明 |
|---|---|
| `CurrentEnforced` | 現施行法令 |
| `UnEnforced` | 未施行法令 |
| `PreviousEnforced` | 過去施行法令 |
| `Repeal` | 廃止法令 |

### mission

| 値 | 説明 |
|---|---|
| `New` | 新規制定または被改正法令 |
| `Partial` | 一部改正法令 |

### 改正区分の判別方法

| 改正区分 | 条件 |
|---|---|
| 新規制定 | `amendment_type` = `1` かつ `mission` = `New` |
| 一部改正 | `mission` = `Partial` |
| 被改正法 | `amendment_type` = `3` かつ `mission` = `New` |
| 廃止 | `amendment_type` = `8` または `repeal_status` が `Repeal` / `Expire` / `LossOfEffectiveness` |

### category_cd（事項別分類コード）

| コード | 分類 | コード | 分類 |
|---|---|---|---|
| `001` | 憲法 | `026` | 統計 |
| `002` | 刑事 | `027` | 都市計画 |
| `003` | 財務通則 | `028` | 教育 |
| `004` | 水産業 | `029` | 外国為替・貿易 |
| `005` | 観光 | `030` | 厚生 |
| `006` | 国会 | `031` | 地方自治 |
| `007` | 警察 | `032` | 道路 |
| `008` | 国有財産 | `033` | 文化 |
| `009` | 鉱業 | `034` | 陸運 |
| `010` | 郵務 | `035` | 社会福祉 |
| `011` | 行政組織 | `036` | 地方財政 |
| `012` | 消防 | `037` | 河川 |
| `013` | 国税 | `038` | 産業通則 |
| `014` | 工業 | `039` | 海運 |
| `015` | 電気通信 | `040` | 社会保険 |
| `016` | 国家公務員 | `041` | 司法 |
| `017` | 国土開発 | `042` | 災害対策 |
| `018` | 事業 | `043` | 農業 |
| `019` | 商業 | `044` | 航空 |
| `020` | 労働 | `045` | 防衛 |
| `021` | 行政手続 | `046` | 民事 |
| `022` | 土地 | `047` | 建築・住宅 |
| `023` | 国債 | `048` | 林業 |
| `024` | 金融・保険 | `049` | 貨物運送 |
| `025` | 環境保全 | `050` | 外事 |
