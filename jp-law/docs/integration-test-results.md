# スキル統合テスト 結果記録

Issue [#14](https://github.com/HighBridgeDragon/jp-law-skill/issues/14)「スキル統合テスト（Claude Code動作確認）」の実行結果を記録するテンプレートです。

実行手順は [integration-test-guide.md](integration-test-guide.md) を参照してください。

## 実行環境

| 項目 | 値 |
|---|---|
| 実行日時 | 2026-05-05 |
| 実行者 | Ryo Takahashi（Claude Code エージェント実行） |
| Claude Code バージョン | 2.1.119 |
| OS | Windows 11 Home 10.0.26200 |
| スキル読み込み方法 | リポジトリ直下 `jp-law/` をワーキングディレクトリとし `bash scripts/*.sh` を直接実行 |

## サマリー

| 項目 | 値 |
|---|---|
| 総ケース数 | 6 |
| PASS | 6 |
| FAIL | 0 |
| 未実行 | 0 |
| PASS 率 | 6/6 |

## TC-1: 民法第709条の表示

**入力プロンプト**: 民法第709条を表示して

**判定**: PASS

### 呼出ログ抜粋

```text
$ bash scripts/fetch-law.sh 129AC0000000089 MainProvision-Article_709
→ GET https://laws.e-gov.go.jp/api/2/law_data/129AC0000000089?elm=MainProvision-Article_709
レスポンスサイズ: 約 1KB（条文単位取得）
```

### レスポンス抜粋

```text
law_info.law_id           = "129AC0000000089"
revision_info.law_title   = "民法"
law_full_text.tag         = "Article" (Num="709")
ArticleCaption            = "（不法行為による損害賠償）"
ArticleTitle              = "第七百九条"
Sentence                  = "故意又は過失によって他人の権利又は法律上保護される利益を
                             侵害した者は、これによって生じた損害を賠償する責任を負う。"
```

### 必須条件チェック

- [x] `references/law-aliases.md` で `民法` → `129AC0000000089` を解決
- [x] `scripts/fetch-law.sh` を `elm` に `MainProvision-Article_709`（または同等の条文単位 elm 指定）を指定して呼出
- [x] 第709条本文（不法行為に基づく損害賠償の条文）を返却

### 望ましい条件チェック

- [x] 条文番号・条見出しが正確（「第七百九条」「（不法行為による損害賠償）」）
- [x] 出典 URL が `https://laws.e-gov.go.jp/law/129AC0000000089` 形式で提示可能
- [x] elm 指定により全文取得を回避（トークン節約: レスポンス ≒ 1KB）

### 所見

エイリアス解決と elm 指定での条文単位取得が想定通り機能。レスポンスは `Article` ノードのみを返し、民法全文（数万行）の取得を完全に回避できている。`law_full_text` は tag/attr/children 再帰構造のため、エージェント側で `Sentence` の末端文字列を抽出する処理が必要だが、SKILL.md の出力フォーマットに沿って整形可能。

## TC-2: 個人情報保護法の検索

**入力プロンプト**: 個人情報保護に関する法律を検索して

**判定**: PASS

### 呼出ログ抜粋

```text
$ bash scripts/search-laws.sh 個人情報保護
→ GET https://laws.e-gov.go.jp/api/2/laws?law_title=個人情報保護&limit=10
レスポンスサイズ: 約 11KB（10件分のメタ情報）
total_count: 17, count: 10, next_offset: 10
```

### レスポンス抜粋

```text
1. 413R00000001003  会計検査院情報公開・個人情報保護審査会規則
2. 415AC0000000057  個人情報の保護に関する法律（略称: 個人情報保護法）★正式法令
3. 415AC0000000058  行政機関の保有する個人情報の保護に関する法律（廃止）
4. 415AC0000000059  独立行政法人等の保有する個人情報の保護に関する法律（廃止）
5. 415AC0000000060  情報公開・個人情報保護審査会設置法
6. 415CO0000000507  個人情報の保護に関する法律施行令
7. 415CO0000000548  行政機関の保有する個人情報の保護に関する法律施行令（廃止）
8. 415CO0000000549  独立行政法人等の保有する個人情報の保護に関する法律施行令（廃止）
9. 415CO0000000550  情報公開・個人情報保護審査会設置法施行令
10. 417M60000002027 情報公開・個人情報保護審査会事務局組織規則
（残り 7 件は next_offset=10 で続取得可能）
```

### 必須条件チェック

- [x] `scripts/search-laws.sh` で名称マッチを実行
- [x] 候補の `law_id` を提示
- [x] 複数候補がある場合は順序付きで列挙

### 望ましい条件チェック

- [x] 正式名称「個人情報の保護に関する法律」(`415AC0000000057`) を含む
- [ ] 類似法令（マイナンバー法等）も併記 — 名称マッチ範囲外のため未含。マイナンバー法を併記するには別クエリ（行政手続における特定の個人を識別するための番号の利用等に関する法律）が必要
- [x] 各候補に簡潔な説明を付与（公布年・略称・施行情報をレスポンスから取得可能）

### 所見

検索クエリ「個人情報保護」で 17 件ヒット、上位 10 件が返却。本命の `415AC0000000057` は 2 番目に出現。`abbrev` フィールドに「個人情報保護法」が格納されており、エージェントは略称表示を活用できる。マイナンバー法は名称に「個人情報保護」を含まないためヒットせず、必要なら別クエリでの追加検索が望ましい。`current_revision_status` で「Repeal」（廃止）法令も判別可能で、ユーザー提示時に廃止法令を除外する処理が望ましい。

## TC-3: 会社法の改正履歴

**入力プロンプト**: 会社法の改正履歴を見せて

**判定**: PASS

### 呼出ログ抜粋

```text
$ bash scripts/fetch-revisions.sh 417AC0000000086
→ GET https://laws.e-gov.go.jp/api/2/revisions/417AC0000000086
レスポンスサイズ: 約 30KB（改正履歴メタのみ）
revisions[]: 26 件超（新しい順）
```

### レスポンス抜粋（直近・未施行含む）

```text
1. 2028-06-13 (UnEnforced)        民事関係手続等における情報通信技術の活用等の推進を
                                   図るための関係法律の整備に関する法律
                                   (令和五年法律第五十三号 / 506AC0000000033)
2. 2027-12-05 (UnEnforced)        譲渡担保契約及び所有権留保契約に関する法律の
                                   施行に伴う関係法律の整備等に関する法律
                                   (令和七年法律第五十七号)
3. 2026-05-21 (UnEnforced)        民事訴訟法等の一部を改正する法律
                                   (令和四年法律第四十八号)
4. 2026-05-01 (CurrentEnforced)   金融商品取引法及び投資信託及び投資法人に関する
                                   法律の一部を改正する法律 (令和六年法律第三十二号)
5. 2025-10-01 (PreviousEnforced)  民事関係手続等における情報通信技術の活用等の推進
                                   ... 以下省略（直近10件以降は省略可）
```

### 必須条件チェック

- [x] `references/law-aliases.md` で `会社法` → `417AC0000000086` を解決
- [x] `scripts/fetch-revisions.sh` を会社法 `law_id` で呼出
- [x] 改正一覧を新しい順で返却

### 望ましい条件チェック

- [x] 各改正に施行日（`amendment_enforcement_date`）と改正法名（`amendment_law_title`）を含む
- [x] 件数が多いため直近 N 件に絞って提示可能（`current_revision_status` で施行状態を判別）
- [x] `law_revision_id` で特定時点の本文取得が可能であることを示唆（`law_data/{law_revision_id}` で参照可）

### 所見

API は新しい順で返却済みで、エージェントによる並べ替えは不要。`current_revision_status` の値（`UnEnforced` / `CurrentEnforced` / `PreviousEnforced`）が用意されているため、未施行の改正を区別して提示できる。改正回数が多いため、ユーザー提示時は直近 5〜10 件に絞り、必要に応じてユーザーに「全件表示しますか」と確認する設計が望ましい。

## TC-4: AIに関する法律の有無

**入力プロンプト**: AIに関する法律はあるか

**判定**: PASS

### 呼出ログ抜粋

```text
$ bash scripts/search-keyword.sh AI 5
→ {"code":"404001","message":"取得結果が０件です。"}

$ bash scripts/search-keyword.sh 人工知能 5
→ total_count: 160, sentence_count: 5
  ヒット例:
    - 332AC0000000026 租税特別措置法
    - 345AC0000000090 情報処理の促進に関する法律（先端半導体・人工知能関連技術債）

$ bash scripts/search-laws.sh 人工知能 5
→ total_count: 2, count: 2
  - 507AC0000000053 人工知能関連技術の研究開発及び活用の推進に関する法律
                    （略称: ＡＩ法、令和七年法律第五十三号、2025-09-01施行）
  - 507CO0000000281 人工知能戦略本部令
```

### レスポンス抜粋（人工知能 - search-keyword）

```text
items[0]: 租税特別措置法
  position: mainprovision
  text: "...官民データ活用推進基本法（平成二十八年法律第百三号）第二条第二項に
        規定する<span>人工知能</span>..."
items[1]: 情報処理の促進に関する法律
  position: mainprovisiontoc / caption / mainprovision
  text: "第六章　先端半導体・<span>人工知能</span>関連技術債"
```

### 必須条件チェック

- [x] `scripts/search-keyword.sh` を実行（`AI` / `人工知能` の 2 クエリを試行）
- [x] 試行したクエリと件数を明示（AI: 0件 / 人工知能: 160件）
- [x] ヒット 0 件の場合は「該当なし」を明示（`AI` クエリは 404001「取得結果が０件です。」を返却したため明示）

### 望ましい条件チェック

- [x] 複数クエリ（AI / 人工知能）を順次試行
- [x] ヒットした場合は法令名と該当条文の冒頭を抜粋
- [x] さらに `search-laws.sh` で法令名検索を行い、正面の AI 法（`507AC0000000053` 人工知能関連技術の研究開発及び活用の推進に関する法律）を発見

### 所見

`AI`（短い英字 2 文字）は API 側で 0 件扱い。`人工知能` で 160 件ヒットし、さらに `search-laws.sh` で法令名検索すると 2025 年 9 月施行の通称「ＡＩ法」（`507AC0000000053`）が確認できた。`search-keyword.sh` だけで止めると AI 法本体を見逃す恐れがあるため、キーワード検索 + 法令名検索の併用が望ましい。SKILL.md にこのパターン（短い英略 → 日本語訳語 + 法令名検索の合わせ技）を追記すると親切。

## TC-5: トークン節約ガイダンス

**入力プロンプト**: （TC-1〜TC-4 の操作を通じて確認）

**判定**: PASS

### 呼出ログ抜粋

```text
TC-1: fetch-law.sh 129AC0000000089 MainProvision-Article_709
      → elm 指定あり（条文単位）
TC-2: search-laws.sh 個人情報保護
      → 検索系のためサイズ小（メタ情報のみ）
TC-3: fetch-revisions.sh 417AC0000000086
      → 改正履歴メタのみ（本文取得なし）
TC-4: search-keyword.sh AI / 人工知能, search-laws.sh 人工知能
      → 検索系のため本文取得なし
```

### 観測対象

TC-1〜TC-4 を通じて観測した、大規模法令（民法・会社法等）操作時の `fetch-law.sh` 呼び出しパターン。

### 観測結果（elm 呼び出しパターン）

```text
- 大規模法令（民法）への問い合わせ（TC-1）: elm=MainProvision-Article_709 を指定
  → 全文取得（数万行）を回避し、約 1KB のレスポンスに圧縮
- 会社法（TC-3）: 本文取得不要のため fetch-law.sh 自体を呼ばず fetch-revisions.sh のみで完結
  → 検索→特定→取得の順序を尊重
- 個人情報保護法（TC-2）/ AI関連法（TC-4）: 本文取得不要のため search 系のみ
  → 必要最小限のメタ情報のみ取得
- elm 指定なしの全文取得は一度も発生しなかった
```

### 必須条件チェック

- [x] 大規模法令の操作で `elm` 指定なしの全文取得を回避
- [x] `elm` パラメータが条文単位（例: `MainProvision-Article_709`）で指定されている

### 望ましい条件チェック

- [ ] 章・節単位（例: `MainProvision-Chapter_3`）でのまとめ取得が適切に選択される — TC-1〜TC-4 では章・節単位の取得が必要なシナリオがなく観測対象なし（N/A）
- [x] 検索 → 特定 → 取得の順序で進行（TC-2/TC-4 は検索のみで完結、TC-1 はエイリアス解決→条文単位取得の順）
- [x] 全文取得を実行する場合はユーザーに確認 — 今回は全文取得シナリオなし（必須条件は適用外、SKILL.md「全文取得は最終手段」のガイダンスを順守）

### 所見

TC-1〜TC-4 を通じて、SKILL.md L107-114「トークン節約ガイダンス」が想定する挙動を満たしている。特に TC-1 で民法（数万行規模）に対して `elm=MainProvision-Article_709` を指定し全文取得を完全に回避できた点が大きい。章・節単位（`Chapter_X` / `Section_X`）のまとめ取得は TC-6（会社法第2編第2章「株式」）として追加・実行済み（PASS）。

## TC-6: 会社法第2編第2章「株式」のまとめ取得

**入力プロンプト**: 会社法の株式に関する章（第二編第二章）を表示して

**判定**: PASS

### 呼出ログ抜粋

```text
$ bash scripts/fetch-law.sh 417AC0000000086 MainProvision-Part_3-Chapter_2
→ GET https://laws.e-gov.go.jp/api/2/law_data/417AC0000000086?elm=MainProvision-Part_3-Chapter_2
レスポンスサイズ: 約 15KB（第三編 持分会社 第二章 社員、Article 10 件）
※ 上記は第三編（持分会社）の第二章を返すため、会社法の構造を確認のうえ elm を修正

$ bash scripts/fetch-law.sh 417AC0000000086 MainProvision-Part_2-Chapter_2
→ GET https://laws.e-gov.go.jp/api/2/law_data/417AC0000000086?elm=MainProvision-Part_2-Chapter_2
レスポンスサイズ: 約 420KB（章単位まとめ取得）
Article ノード件数: 154 件
```

### レスポンス抜粋

```text
law_info.law_id           = "417AC0000000086"
revision_info.law_title   = "会社法"
law_full_text.tag         = "Chapter" (Num="2")
ChapterTitle              = "第二章　株式"
配下 Article: 第104条 ... 第235条 (154 件)
第百四条（株主の責任）
  株主の責任は、その有する株式の引受価額を限度とする。
```

### 必須条件チェック

- [x] `references/law-aliases.md` で `会社法` → `417AC0000000086` を解決
- [x] `scripts/fetch-law.sh` を `elm` に章単位指定（`MainProvision-Part_2-Chapter_2`）で呼出
- [x] レスポンスに該当章配下の複数条文（`Article` ノード）が含まれる（154 件）
- [x] 法令全文取得は行われない（章単位レスポンスサイズ約 420KB、全文取得 約 2,952KB の 14% 相当）

### 望ましい条件チェック

- [x] 章タイトル（`ChapterTitle`）が含まれる（"第二章　株式"）
- [x] 章まとめ取得のレスポンスサイズが全文取得より大幅に小さい
       （観測値: 章まとめ 約 420KB vs 全文 約 2,952KB → 約 7.0 倍削減）
       ※ 154 件を条文単位で個別取得した場合の推定合計は 第104条 単体 1.5KB × 154 = 約 231KB 相当
         （ただし各呼出にヘッダオーバーヘッドが加算されるため実際はより大きくなる）
- [x] 出力フォーマットは SKILL.md 末尾の推奨フォーマットに沿う

### 所見

`MainProvision-Part_3-Chapter_2` を最初に試みたところ、会社法の第三編（持分会社）第二章「社員」（第580条〜第589条、10件）が返却された。第三編は持分会社に関する編であり、問い合わせ意図（株式に関する章）とは異なる。会社法の実際の構造を確認すると、株式会社の株式規定（第104条〜第235条）は第二編（株式会社）第二章に位置するため、`MainProvision-Part_2-Chapter_2` を指定することで正しい章（"第二章 株式"、154件）を取得できた。章単位 elm の指定は法令の編章構造を事前に把握した上で行う必要があることが確認できた。また、章まとめ取得（420KB）は全文取得（2,952KB）と比べて約 7 倍の削減効果があり、SKILL.md のトークン節約ガイダンスの有効性を実測で裏付けている。

## 発見した問題と起票 Issue

特になし。全 6 ケース PASS。SKILL.md への軽微な改善提案として TC-4 所見の「キーワード検索 + 法令名検索の併用パターン」を追記する余地があるが、Issue #25 で対応中。

## 関連

- Issue: [#14](https://github.com/HighBridgeDragon/jp-law-skill/issues/14)
- 実行手順: [integration-test-guide.md](integration-test-guide.md)
- スキル定義: [../SKILL.md](../SKILL.md)
- 法令エイリアス: [../references/law-aliases.md](../references/law-aliases.md)
