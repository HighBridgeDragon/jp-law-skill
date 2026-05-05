# 法令ID検証の実行手順

このガイドでは、実際にe-Gov APIにアクセスして法令IDを検証する手順を説明します。

## 前提条件

以下の環境が必要です:

- **インターネット接続**: e-Gov APIへのアクセスが必要
- **bash**: シェルスクリプト実行環境
- **curl**: HTTP通信ツール

## クイックスタート

リポジトリをクローンして検証を実行:

```bash
# リポジトリをクローン
git clone https://github.com/HighBridgeDragon/jp-law-skill.git
cd jp-law-skill/jp-law

# 検証スクリプトを実行
bash scripts/validate-law-ids.sh
```

## 実行結果の解釈

### 成功例

すべての法令IDが有効な場合:

```
===========================================
law-aliases.md 法令ID検証スクリプト
===========================================

ネットワーク接続を確認中...
✓ ネットワーク接続OK

検証対象: 38 件の法令ID

[OK] 321CONSTITUTION - 日本国憲法
[OK] 129AC0000000089 - 民法
[OK] 140AC0000000045 - 刑法
...（中略）...
[OK] 503AC0000000035 - デジタル社会形成基本法

===========================================
検証結果サマリー
===========================================
総件数: 38
成功: 38
失敗: 0

✓ すべての法令IDが有効です
```

この場合、issue #12 を完了としてクローズできます。

### 失敗がある場合

無効な法令IDがある場合:

```
[OK] 321CONSTITUTION - 日本国憲法
[NG] INVALID123456789 - HTTP 400 - 法令ID、法令番号、又は法令履歴IDが誤っています。
...

===========================================
検証結果サマリー
===========================================
総件数: 38
成功: 37
失敗: 1

失敗したlaw_id:
INVALID123456789
```

この場合、次の「修正手順」に進んでください。

## 無効な法令IDの修正手順

### 1. 正しい法令IDを検索

```bash
# 法令名で検索
bash scripts/search-laws.sh "正式な法令名"
```

例:
```bash
bash scripts/search-laws.sh "個人情報の保護に関する法律"
```

レスポンスから正しい`law_id`を取得します。

### 2. law-aliases.mdを修正

`jp-law/references/law-aliases.md`を編集して、正しい`law_id`に置き換えます。

### 3. 再検証

```bash
bash scripts/validate-law-ids.sh
```

### 4. 結果を記録

`docs/validation-results.md`を更新して、検証結果を記録します:

```markdown
## 検証結果サマリー

| 項目 | 件数 |
|------|------|
| 総件数 | 38 |
| 成功 | 38 |
| 失敗 | 0 |

## 修正内容

### 個人情報保護法
- **旧law_id**: `INVALID123456789`
- **新law_id**: `415AC0000000057`
- **修正方法**: search-laws.shで検索して正しいIDを特定
```

### 5. Pull Requestを作成

修正をコミットしてPRを作成します:

```bash
git add jp-law/references/law-aliases.md docs/validation-results.md
git commit -m "fix: correct invalid law_id for [法令名]"
git push
```

## 個別検証

特定の法令IDのみを検証したい場合:

```bash
# 改正履歴APIで検証
bash scripts/fetch-revisions.sh 129AC0000000089
```

正常なレスポンス例:
```json
{
  "law_id": "129AC0000000089",
  "law_title": "民法",
  "law_revisions": [...]
}
```

エラーレスポンス例:
```json
{
  "code": "400043",
  "message": "法令ID、法令番号、又は法令履歴IDが誤っています。"
}
```

## トラブルシューティング

### ネットワークエラー

```
エラー: e-Gov API にアクセスできません

以下を確認してください:
  - インターネット接続が有効か
  - プロキシ設定が必要か
  - ファイアウォールでブロックされていないか
```

**対処法**:
1. インターネット接続を確認
2. プロキシ設定が必要な場合、環境変数を設定:
   ```bash
   export https_proxy=http://proxy.example.com:8080
   ```
3. 企業ネットワークの場合、ネットワーク管理者に確認

### API制限

大量のリクエストを短時間に送信すると、一時的にアクセスが制限される可能性があります。

**対処法**:
- スクリプトは0.5秒間隔でリクエストを送信します（既に対策済み）
- エラーが発生した場合、数分待ってから再実行

## 次のステップ

検証が完了したら:

1. **issue #12 にコメント**: 検証結果を報告
2. **issue #12 をクローズ**: すべてのlaw_idが有効な場合
3. **validation-results.mdを更新**: 検証結果を記録
4. **次のタスクへ**: issue #13（Agent Skills仕様バリデーション）に進む

## 関連資料

- [検証手順詳細](validate-law-ids.md)
- [スクリプト一覧](../scripts/README.md)
- [法令エイリアス](../references/law-aliases.md)
- [Issue #12](https://github.com/HighBridgeDragon/jp-law-skill/issues/12)
