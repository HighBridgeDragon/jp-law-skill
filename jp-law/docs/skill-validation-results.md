# Agent Skills 仕様バリデーション結果

**検証日時**: 未実行
**検証者**: 未実行
**検証方法**: `npx skills-ref validate ./jp-law` + 自前チェック（grep / wc / basename 相当）

## 実行環境

| 項目 | 値 |
|------|-----|
| OS | 未取得 |
| Node.js | 未取得 |
| npm | 未取得 |
| skills-ref | 未取得 |

## 検証結果サマリー

| 項目 | 件数 |
|------|------|
| 総検証項目 | 5 |
| PASS | 0 |
| FAIL | 5 |

**総合判定**: FAIL（未検証）

## 検証詳細

### 1. `skills-ref validate ./jp-law` 実行

- **実行コマンド**: `npx --yes skills-ref validate ./jp-law`
- **期待値**: 標準出力に `Valid skill: ./jp-law` を含み、終了コード 0
- **実際の出力**:

  ```text
  （未取得）
  ```

- **判定**: FAIL（未検証）

### 2. name / description フロントマター必須

- **実行コマンド**: `npx --yes skills-ref read-properties ./jp-law`
- **期待値**: JSON 出力に `name` と `description` を含み、いずれも非空
- **実際の出力**:

  ```text
  （未取得）
  ```

- **判定**: FAIL（未検証）

### 3. name 命名規則（小文字・ハイフン・64 字以内）

- **実行コマンド**: `Select-String -Path jp-law/SKILL.md -Pattern '^name: [a-z][a-z0-9-]{0,63}$'`（PowerShell）
  / `grep -E '^name: [a-z][a-z0-9-]{0,63}$' jp-law/SKILL.md`（bash 相当）
- **期待値**: 1 行マッチし、内容が `name: jp-law`
- **実際の出力**:

  ```text
  （未取得）
  ```

- **判定**: FAIL（未検証）

### 4. ディレクトリ名と name 値の一致

- **実行コマンド**: `Split-Path -Leaf (Resolve-Path ./jp-law)` と SKILL.md の `name` 値を比較
- **期待値**: 両方とも `jp-law`
- **実際の出力**:

  ```text
  （未取得）
  ```

- **判定**: FAIL（未検証）

### 5. SKILL.md ≤ 500 行

- **実行コマンド**: `(Get-Content jp-law/SKILL.md | Measure-Object -Line).Lines`（PowerShell）
  / `wc -l jp-law/SKILL.md`（bash 相当）
- **期待値**: 500 以下
- **実際の出力**:

  ```text
  （未取得）
  ```

- **判定**: FAIL（未検証）

## 是正内容

未実行のため、是正は発生していません。

## 備考

このドキュメントは TDD の Red 状態（全項目 FAIL）として作成されています。
Green 状態への遷移後、`skill-validation-guide.md` に従った検証コマンドを実行し、
出力と判定を本ファイルに転記してください。

## 関連

- Issue: [#13 Agent Skills仕様バリデーション](https://github.com/HighBridgeDragon/jp-law-skill/issues/13)
- 検証手順: [skill-validation-guide.md](skill-validation-guide.md)
- 検証対象: [../SKILL.md](../SKILL.md)
