---
name: レスポンス構造リファレンス
description: law_full_textのtag/attr/children再帰構造とタグ一覧
---

# law_full_text レスポンス構造リファレンス

`/law_data/{law_id_or_num_or_revision_id}` エンドポイントが返すJSONの `law_full_text` フィールドの構造。

## レスポンス全体の構造

```json
{
  "attached_files_info": null,
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
  "revision_info": { "law_revision_id": "...", "law_title": "...", ... },
  "law_full_text": { "tag": "Law", "attr": {...}, "children": [...] }
}
```

## ツリー構造の基本パターン

`law_full_text` は再帰的な `tag` / `attr` / `children` ノードで構成される。

### ノードの型

**要素ノード** (オブジェクト):

```json
{
  "tag": "Article",
  "attr": { "Num": "709" },
  "children": [ ... ]
}
```

**テキストノード** (文字列): `children` 配列内に直接文字列として出現する。

```json
{
  "tag": "ArticleTitle",
  "attr": {},
  "children": ["第七百九条"]
}
```

**混在パターン**: テキストとインライン要素が `children` 内で混在する。Rubyタグが典型例。

```json
{
  "tag": "ArticleCaption",
  "attr": {},
  "children": [
    "（失",
    { "tag": "Ruby", "attr": {}, "children": [
        "踪",
        { "tag": "Rt", "attr": {}, "children": ["そう"] }
    ]},
    "の宣告）"
  ]
}
```

## 全体の階層構造

```
Law
├── LawNum                          法令番号テキスト
└── LawBody
    ├── LawTitle                    法令名
    ├── EnactStatement              制定文（複数可）
    ├── Preamble                    前文（憲法等）
    │   └── Paragraph
    ├── TOC                         目次
    │   ├── TOCLabel
    │   ├── TOCPart / TOCChapter / TOCSection / TOCSubsection / TOCDivision
    │   │   └── ArticleRange
    │   └── TOCSupplProvision
    ├── MainProvision               本則
    │   ├── Part                    編
    │   │   ├── PartTitle
    │   │   └── Chapter             章
    │   │       ├── ChapterTitle
    │   │       └── Section         節
    │   │           ├── SectionTitle
    │   │           └── Subsection  款
    │   │               ├── SubsectionTitle
    │   │               └── Division  目
    │   │                   ├── DivisionTitle
    │   │                   └── Article
    │   └── Article                 条（編/章がない法令では直下）
    ├── SupplProvision              附則（複数可）
    │   ├── SupplProvisionLabel
    │   ├── Paragraph / Article
    │   └── SupplProvisionAppdxTable
    │       └── SupplProvisionAppdxTableTitle
    └── AppdxTable                  別表
        ├── AppdxTableTitle
        ├── RelatedArticleNum
        └── TableStruct
```

## 条文内部の構造

```
Article
├── ArticleCaption                  見出し（括弧付き）例:「（不法行為による損害賠償）」
├── ArticleTitle                    条名 例:「第七百九条」
└── Paragraph                      項
    ├── ParagraphNum                項番号（第1項は空、第2項以降は「２」「３」等）
    ├── ParagraphCaption            項見出し（稀）
    ├── ParagraphSentence           項本文
    │   └── Sentence                文（本文・ただし書等）
    ├── Item                        号
    │   ├── ItemTitle               号番号（「一」「二」等）
    │   ├── ItemSentence
    │   │   └── Sentence
    │   └── Subitem1                号細分（一段目）
    │       ├── Subitem1Title       「イ」「ロ」等
    │       ├── Subitem1Sentence
    │       └── Subitem2            号細分（二段目）
    │           └── Subitem3        号細分（三段目）
    │               └── Subitem4    号細分（四段目）
    └── List                        列記
        └── ListSentence
            └── Sentence
```

## 表・その他の構造

```
TableStruct
├── TableStructTitle                表題（任意）
├── Table
│   └── TableRow
│       └── TableColumn             セル
│           └── Sentence / Column
├── Remarks                         備考
│   ├── RemarksLabel
│   └── Item
└── Column                          段組み
    └── Sentence

ArithFormula                        算式
```

## 主要タグ一覧

### 法令全体

| タグ | 説明 |
|------|------|
| `Law` | ルートノード |
| `LawNum` | 法令番号（テキスト） |
| `LawBody` | 法令本体 |
| `LawTitle` | 法令名 |
| `EnactStatement` | 制定文 |
| `Preamble` | 前文 |

### 目次

| タグ | 説明 |
|------|------|
| `TOC` | 目次 |
| `TOCLabel` | 「目次」ラベル |
| `TOCPart` / `TOCChapter` / `TOCSection` / `TOCSubsection` / `TOCDivision` | 目次内の編/章/節/款/目 |
| `TOCSupplProvision` | 目次内の附則 |
| `ArticleRange` | 条範囲（例:「第一条〜第五条」） |

### 本則の構造単位

| タグ | 説明 |
|------|------|
| `MainProvision` | 本則 |
| `Part` / `PartTitle` | 編 |
| `Chapter` / `ChapterTitle` | 章 |
| `Section` / `SectionTitle` | 節 |
| `Subsection` / `SubsectionTitle` | 款 |
| `Division` / `DivisionTitle` | 目 |

### 条文

| タグ | 説明 |
|------|------|
| `Article` | 条 |
| `ArticleCaption` | 条の見出し |
| `ArticleTitle` | 条名（「第一条」等） |
| `Paragraph` | 項 |
| `ParagraphNum` | 項番号（第1項は空children） |
| `ParagraphCaption` | 項見出し |
| `ParagraphSentence` | 項の文 |
| `Item` | 号 |
| `ItemTitle` | 号番号（「一」「二」等） |
| `ItemSentence` | 号の文 |
| `Subitem1` 〜 `Subitem4` | 号細分（1段〜4段） |
| `Subitem1Title` 〜 `Subitem4Title` | 号細分番号 |
| `Subitem1Sentence` 〜 `Subitem4Sentence` | 号細分の文 |
| `Sentence` | 文（テキストの最小単位） |

### 附則・別表

| タグ | 説明 |
|------|------|
| `SupplProvision` | 附則 |
| `SupplProvisionLabel` | 「附則」ラベル |
| `SupplProvisionAppdxTable` | 附則別表 |
| `SupplProvisionAppdxTableTitle` | 附則別表題名 |
| `AppdxTable` | 別表 |
| `AppdxTableTitle` | 別表題名 |
| `RelatedArticleNum` | 関連条文番号 |

### 表・書式

| タグ | 説明 |
|------|------|
| `TableStruct` | 表構造の外枠 |
| `TableStructTitle` | 表題 |
| `Table` | 表本体 |
| `TableRow` | 行 |
| `TableColumn` | セル |
| `Column` | 段組み |
| `List` | 列記 |
| `ListSentence` | 列記文 |
| `ArithFormula` | 算式 |
| `Remarks` | 備考 |
| `RemarksLabel` | 備考ラベル |

### インライン要素

| タグ | 説明 |
|------|------|
| `Ruby` | ルビ（親文字とRtを含む） |
| `Rt` | ルビテキスト |

## attr 属性一覧

### Law ルートノードの属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `Lang` | `"ja"` | 言語 |
| `Era` | `"Meiji"`, `"Showa"` | 元号（英語） |
| `Year` | `"29"` | 元号年 |
| `Num` | `"089"`, `"000"` | 法令番号 |
| `LawType` | `"Act"`, `"Constitution"` | 法令種別 |
| `PromulgateMonth` | `"04"` | 公布月 |
| `PromulgateDay` | `"27"` | 公布日 |

### LawTitle の属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `Kana` | `"みんぽう"` | 読み仮名 |
| `Abbrev` | `""` | 略称 |
| `AbbrevKana` | `""` | 略称読み |

### 構造単位・条文の属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `Num` | `"709"`, `"1"`, `"398_22"` | 番号（枝番はアンダースコア区切り） |
| `OldNum` | `"true"` | 旧番号体系であることを示す |
| `Delete` | `"true"` | 削除済みの条項 |
| `Extract` | `"true"` | 抄（一部抽出） |

### Sentence の属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `Num` | `"1"`, `"2"` | 文番号（項内の第何文か） |
| `Function` | `"main"`, `"proviso"` | 本文 or ただし書き |
| `WritingMode` | `"vertical"` | 縦書き指定 |

### SupplProvision の属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `AmendLawNum` | `"平成一八年六月二一日法律第七八号"` | 改正法令番号 |
| `Extract` | `"true"` | 抄 |

### TableColumn の属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `BorderTop` | `"none"` | 上罫線 |
| `BorderBottom` | `"none"` | 下罫線 |
| `BorderLeft` | `"none"` | 左罫線 |
| `BorderRight` | `"none"` | 右罫線 |
| `rowspan` | `"2"` | 行結合 |
| `colspan` | `"3"` | 列結合 |

### RemarksLabel の属性

| 属性 | 例 | 説明 |
|------|-----|------|
| `LineBreak` | `"true"` | 改行あり |

### OldStyle

| 属性 | 例 | 説明 |
|------|-----|------|
| `OldStyle` | `"false"` | 旧形式かどうか |

## 実データ例: 民法第709条

`GET /law_data/129AC0000000089_20260401_506AC0000000033` から取得した実際のJSON:

```json
{
  "tag": "Article",
  "attr": { "Num": "709" },
  "children": [
    {
      "tag": "ArticleCaption",
      "attr": {},
      "children": ["（不法行為による損害賠償）"]
    },
    {
      "tag": "ArticleTitle",
      "attr": {},
      "children": ["第七百九条"]
    },
    {
      "tag": "Paragraph",
      "attr": { "Num": "1" },
      "children": [
        {
          "tag": "ParagraphNum",
          "attr": {},
          "children": []
        },
        {
          "tag": "ParagraphSentence",
          "attr": {},
          "children": [
            {
              "tag": "Sentence",
              "attr": { "Num": "1", "WritingMode": "vertical" },
              "children": [
                "故意又は過失によって他人の権利又は法律上保護される利益を侵害した者は、これによって生じた損害を賠償する責任を負う。"
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### 読み取りのポイント

- `ArticleCaption` の `children[0]` で見出しテキストを取得
- `ArticleTitle` の `children[0]` で条名を取得
- 第1項は `ParagraphNum.children` が空配列（番号なし）、第2項以降は `["２"]` 等
- `Sentence` の `children[0]` で条文本文を取得
- `Sentence.attr.Function` が `"proviso"` ならただし書き

## 実データ例: 複数項・号を持つ条文（民法第95条）

```json
{
  "tag": "Article",
  "attr": { "Num": "95" },
  "children": [
    { "tag": "ArticleCaption", "attr": {}, "children": ["（錯誤）"] },
    { "tag": "ArticleTitle", "attr": {}, "children": ["第九十五条"] },
    {
      "tag": "Paragraph",
      "attr": { "Num": "1" },
      "children": [
        { "tag": "ParagraphNum", "attr": {}, "children": [] },
        { "tag": "ParagraphSentence", "attr": {}, "children": [
          { "tag": "Sentence", "attr": { "Num": "1", "WritingMode": "vertical" },
            "children": ["意思表示は、次に掲げる錯誤に基づくものであって、...取り消すことができる。"] }
        ]},
        {
          "tag": "Item",
          "attr": { "Num": "1" },
          "children": [
            { "tag": "ItemTitle", "attr": {}, "children": ["一"] },
            { "tag": "ItemSentence", "attr": {}, "children": [
              { "tag": "Sentence", "attr": { "Num": "1", "WritingMode": "vertical" },
                "children": ["意思表示に対応する意思を欠く錯誤"] }
            ]}
          ]
        },
        {
          "tag": "Item",
          "attr": { "Num": "2" },
          "children": [
            { "tag": "ItemTitle", "attr": {}, "children": ["二"] },
            { "tag": "ItemSentence", "attr": {}, "children": [
              { "tag": "Sentence", "attr": { "Num": "1", "WritingMode": "vertical" },
                "children": ["表意者が法律行為の基礎とした事情についてのその認識が真実に反する錯誤"] }
            ]}
          ]
        }
      ]
    },
    {
      "tag": "Paragraph",
      "attr": { "Num": "2" },
      "children": [
        { "tag": "ParagraphNum", "attr": {}, "children": ["２"] },
        { "tag": "ParagraphSentence", "attr": {}, "children": ["..."] }
      ]
    }
  ]
}
```

## テキスト抽出のパターン

条文テキストを取得するための典型的な走査:

1. **条を特定**: `tag === "Article"` かつ `attr.Num` が目的の番号
2. **項を走査**: `children` 内の `tag === "Paragraph"` を列挙
3. **本文を取得**: `Paragraph` > `ParagraphSentence` > `Sentence` の `children` を結合
4. **号を走査**: `Paragraph` > `Item` を列挙、`ItemTitle` で番号、`ItemSentence` > `Sentence` で本文
5. **テキスト結合**: `children` 配列内の文字列を結合。`Ruby` タグ内は最初のテキストノード（親文字）のみ取得し `Rt` は読み仮名として別途処理

### Num属性の枝番表記

条番号の枝番はアンダースコアで表現される:

- `"398_22"` = 第398条の22
- `"1"` = 第1条
