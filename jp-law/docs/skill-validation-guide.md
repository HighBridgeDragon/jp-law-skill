# Agent Skills 仕様バリデーション手順

このドキュメントでは、`jp-law` スキルが Anthropic の Agent Skills 仕様に
準拠していることを検証する手順を説明します。Issue #13 の acceptance criteria
を満たすコマンド一式と、結果ドキュメントへの記入方法をまとめています。

## 目的

以下 5 項目を機械的に検証し、`skill-validation-results.md` に記録します。

1. `skills-ref validate ./jp-law` で skill 全体が valid と判定されること
2. SKILL.md フロントマターに `name` と `description` が存在すること
3. `name` が命名規則（小文字英数字とハイフン、先頭は英字、64 字以内）に従うこと
4. ディレクトリ名と `name` フィールドが一致すること
5. `SKILL.md` の総行数が 500 以下であること

`skills-ref` は frontmatter の構造的妥当性のみ確認するため、3〜5 は自前で検証します。

## 前提環境

| 項目 | バージョン要件 | 備考 |
| --- | --- | --- |
| OS | Windows 11 / macOS / Linux | 本ガイドは Windows + PowerShell を主に記述 |
| Node.js | >= 24.0.0（推奨） | fnm 等でバージョン切替を行うこと推奨。検証時の実測バージョンは [skill-validation-results.md](skill-validation-results.md) 参照 |
| npm | Node.js 同梱版 | Node.js に同梱 |
| skills-ref | 0.1.5 以上 | `npx --yes` で都度取得（インストール不要） |

### fnm セットアップ（PowerShell）

```powershell
fnm env --use-on-cd | Out-String | Invoke-Expression
fnm use 24       # 例: 24.15.0 など 24 系の最新を選択
node --version   # >= v24.0.0 を確認
npm --version
```

bash 環境（macOS/Linux）の場合は `eval "$(fnm env --use-on-cd)"` で
シェルにフックを注入したうえで `fnm use 24` を実行してください。

## 実行コマンド一覧

リポジトリのルート（`SKILL.md` が直下にある `jp-law/` の親）で実行します。

### 1. `skills-ref validate`

```powershell
npx --yes skills-ref validate ./jp-law
```

期待出力:

```text
Valid skill: ./jp-law
```

終了コード 0 を確認します。

### 2. `skills-ref read-properties`（name / description 取得）

```powershell
npx --yes skills-ref read-properties ./jp-law
```

JSON 形式で `name`、`description` が出力されることを確認します。

### 3. name 命名規則チェック

PowerShell:

```powershell
Select-String -Path jp-law/SKILL.md -Pattern '^name: [a-z][a-z0-9-]{0,63}$'
```

bash 相当:

```bash
grep -E "^name: [a-z][a-z0-9-]{0,63}$" jp-law/SKILL.md
```

該当行（`name: jp-law`）が 1 件返ることを確認します。マッチ 0 件は FAIL です。

### 4. ディレクトリ名と name の一致

PowerShell:

```powershell
$dir  = Split-Path -Leaf (Resolve-Path ./jp-law)
$name = (Select-String -Path jp-law/SKILL.md -Pattern '^name:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
"dir=$dir name=$name match=$($dir -eq $name)"
```

bash 相当:

```bash
dir=$(basename "$(realpath ./jp-law)")
name=$(awk '/^name:/ {print $2; exit}' jp-law/SKILL.md)
echo "dir=$dir name=$name"
[ "$dir" = "$name" ] && echo "match=true" || echo "match=false"
```

両者が `jp-law` で一致することを確認します。

### 5. SKILL.md 行数（≤ 500）

PowerShell:

```powershell
(Get-Content jp-law/SKILL.md | Measure-Object -Line).Lines
```

bash 相当:

```bash
wc -l jp-law/SKILL.md
```

500 以下であることを確認します。

## 結果ドキュメントへの記入手順

1. `skill-validation-results.md` を開きます（Red 状態のテンプレートが準備されています）。
2. 「実行環境」表に OS・Node.js・npm・skills-ref のバージョンを記入します。
3. 各検証項目について「実際の出力」コードブロックにコマンド出力を貼り付けます。
4. 期待値を満たした項目は「判定」を `PASS` に更新します。
5. 「検証結果サマリー」表の PASS / FAIL 件数を更新し、5 件すべて PASS なら
   「総合判定」を `PASS` に書き換えます。
6. 「検証日時」「検証者」も忘れず更新します。

## 失敗時の対応指針

| 失敗パターン | 想定される原因 | 対応 |
| --- | --- | --- |
| `skills-ref validate` が non-zero | frontmatter 破損、必須フィールド欠落 | SKILL.md 修正は別 Issue で扱い、本検証では FAIL を記録 |
| `name` 命名規則 NG | 大文字混入、64 字超過 | 別 Issue 起票し、SKILL.md 改修 PR を分離 |
| ディレクトリ名と `name` 不一致 | リポジトリ改名・移動の取り残し | リネーム PR を別途立ち上げ、本検証は FAIL のまま記録 |
| 行数 > 500 | SKILL.md 肥大化 | 別 Issue で分割リファクタを提案、本検証では FAIL を記録 |

本ガイドの実行範囲では SKILL.md は **読み取りのみ** とし、修正が必要な場合は
別 Issue / 別 PR でスコープを分離します（PR1 のスコープ外）。

## 参考資料

- [Agent Skills 公式仕様](https://docs.claude.com/en/docs/claude-code/skills)
- [skills-ref CLI](https://www.npmjs.com/package/skills-ref)
- [Issue #13](https://github.com/HighBridgeDragon/jp-law-skill/issues/13)
- 結果記録: [skill-validation-results.md](skill-validation-results.md)
- 検証対象: [../SKILL.md](../SKILL.md)
