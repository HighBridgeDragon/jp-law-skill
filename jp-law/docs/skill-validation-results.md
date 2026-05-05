# Agent Skills 仕様バリデーション結果

**検証日時**: 2026-05-05 10:27 (+0900)
**検証者**: anthropic-code-agent
**検証方法**: `npx --yes skills-ref validate ./jp-law` + 自前チェック（PowerShell / bash）

## 実行環境

| 項目 | 値 |
| --- | --- |
| OS | Microsoft Windows 10.0.26200 (Windows 11 Home) |
| Node.js | v24.15.0 (fnm 経由) |
| npm | 11.12.1 |
| skills-ref | 0.1.5 |

## 検証結果サマリー

| 項目 | 件数 |
| --- | --- |
| 総検証項目 | 5 |
| PASS | 5 |
| FAIL | 0 |

**総合判定**: PASS

## 検証詳細

### 1. `skills-ref validate ./jp-law` 実行

- **実行コマンド**: `npx --yes skills-ref validate ./jp-law`
- **期待値**: 標準出力に `Valid skill: ./jp-law` を含み、終了コード 0
- **実際の出力**:

  ```text
  Valid skill: ./jp-law
  ```

  終了コード: `0`

- **判定**: PASS

### 2. name / description フロントマター必須

- **実行コマンド**: `npx --yes skills-ref read-properties ./jp-law`
- **期待値**: JSON 出力に `name` と `description` を含み、いずれも非空
- **実際の出力**:

  ```json
  {
    "name": "jp-law",
    "description": "日本の法令を検索・取得するスキル。e-Gov法令API V2を使用し、法令名検索、条文取得、改正履歴、キーワード検索が可能。Use this skill when researching Japanese laws, regulations, or legal texts.",
    "license": "MIT"
  }
  ```

- **判定**: PASS（`name` と `description` がともに非空で取得できた）

### 3. name 命名規則（小文字・ハイフン・64 字以内）

- **実行コマンド**: `Select-String -Path jp-law/SKILL.md -Pattern '^name: [a-z][a-z0-9-]{0,63}$'`
- **期待値**: 1 行マッチし、内容が `name: jp-law`
- **実際の出力**:

  ```text
  jp-law\SKILL.md:2:name: jp-law
  ```

- **判定**: PASS（`jp-law` は 6 文字、先頭が英小文字、英数字とハイフンのみ）

### 4. ディレクトリ名と name 値の一致

- **実行コマンド**:

  ```powershell
  $dir  = Split-Path -Leaf (Resolve-Path ./jp-law)
  $name = (Select-String -Path jp-law/SKILL.md -Pattern '^name:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
  "dir=$dir name=$name match=$($dir -eq $name)"
  ```

- **期待値**: 両方とも `jp-law`
- **実際の出力**:

  ```text
  dir=jp-law name=jp-law match=True
  ```

- **判定**: PASS

### 5. SKILL.md ≤ 500 行

- **実行コマンド**: `wc -l jp-law/SKILL.md`（bash）/ `(Get-Content jp-law/SKILL.md | Measure-Object -Line).Lines`（PowerShell）
- **期待値**: 500 以下
- **実際の出力**:

  ```text
  $ wc -l jp-law/SKILL.md
  161 jp-law/SKILL.md
  ```

  参考: PowerShell の `Measure-Object -Line` では 114 行（非空行のみカウント）。
  どの計測方法でも 500 行を大きく下回る。

- **判定**: PASS

## 是正内容

今回の検証では SKILL.md の修正は不要でした。是正は発生していません。

## 備考

- skills-ref 0.1.5 は frontmatter の構造的妥当性のみ判定するため、
  命名規則 / ディレクトリ名一致 / 行数は自前チェックでカバーしている。
- 検証実行中に SKILL.md / scripts / references への変更は行っていない（読み取りのみ）。

## 関連

- Issue: [#13 Agent Skills仕様バリデーション](https://github.com/HighBridgeDragon/jp-law-skill/issues/13)
- 検証手順: [skill-validation-guide.md](skill-validation-guide.md)
- 検証対象: [../SKILL.md](../SKILL.md)
