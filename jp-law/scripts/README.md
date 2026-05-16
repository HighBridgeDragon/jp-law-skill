# スクリプト一覧

このディレクトリには、e-Gov法令API V2を呼び出すためのシェルスクリプトと、
法令ID検証用のユーティリティスクリプトが含まれています。

## API呼び出しスクリプト

### fetch-law.sh

法令本文データを取得します。

```bash
bash scripts/fetch-law.sh [--max-time SEC] <law_id> [elm]
```

**パラメータ:**
- `--max-time SEC`: curl の最大実行時間（秒、オプション、デフォルト: 30）
- `law_id`: 法令ID（必須）
- `elm`: 取得する要素ID（オプション）

**例:**
```bash
# 民法全文を取得
bash scripts/fetch-law.sh 129AC0000000089

# 民法第1条のみ取得
bash scripts/fetch-law.sh 129AC0000000089 MainProvision-Article_1

# 大型法令の取得で 30 秒では足りない場合は --max-time で延長
bash scripts/fetch-law.sh --max-time 120 129AC0000000089
```

### fetch-revisions.sh

法令の改正履歴を取得します。

```bash
bash scripts/fetch-revisions.sh [--max-time SEC] <law_id>
```

**パラメータ:**
- `--max-time SEC`: curl の最大実行時間（秒、オプション、デフォルト: 30）
- `law_id`: 法令ID（必須）

**例:**
```bash
# 民法の改正履歴を取得
bash scripts/fetch-revisions.sh 129AC0000000089
```

### search-laws.sh

法令名で検索します。

```bash
bash scripts/search-laws.sh [--max-time SEC] <law_title> [limit]
```

**パラメータ:**
- `--max-time SEC`: curl の最大実行時間（秒、オプション、デフォルト: 30）
- `law_title`: 検索する法令名（必須）
- `limit`: 取得件数の上限（オプション、デフォルト: 10）

**例:**
```bash
# 「民法」を検索
bash scripts/search-laws.sh 民法

# 「著作権」を含む法令を最大20件取得
bash scripts/search-laws.sh 著作権 20
```

### search-keyword.sh

法令本文内のキーワードで検索します。

```bash
bash scripts/search-keyword.sh [--max-time SEC] <keyword> [limit]
```

**パラメータ:**
- `--max-time SEC`: curl の最大実行時間（秒、オプション、デフォルト: 30）
- `keyword`: 検索キーワード（必須）
- `limit`: 取得件数の上限（オプション、デフォルト: 10）

**例:**
```bash
# 「個人情報」を含む条文を検索
bash scripts/search-keyword.sh 個人情報

# 「電子署名」を含む条文を最大30件取得
bash scripts/search-keyword.sh 電子署名 30
```

## 検証・ユーティリティスクリプト

### validate-law-ids.sh

law-aliases.mdに記載された全法令IDをe-Gov APIで一括検証します。

```bash
bash scripts/validate-law-ids.sh [--max-time SEC]
```

**パラメータ:**
- `--max-time SEC`: ループ内 curl の最大実行時間（秒、オプション、デフォルト: 30）

**機能:**
- law-aliases.mdから全law_idを自動抽出
- 各law_idに対してGET /law_revisions/{law_id}を実行
- HTTP 200が返ることを確認
- 法令名を取得して表示
- 検証結果のサマリーを出力

**出力例:**
```
[OK] 321CONSTITUTION - 日本国憲法
[OK] 129AC0000000089 - 民法
[NG] INVALID123456789 - HTTP 400 - 法令IDが誤っています
...
検証結果サマリー
総件数: 38
成功: 37
失敗: 1
```

**注意:**
- インターネット接続が必要
- e-Gov APIへのアクセスが必要
- 全38件の検証には約20秒かかります（API負荷軽減のため0.5秒間隔）

### extract-law-ids.sh

law-aliases.mdから全法令IDを抽出して一覧表示します。

```bash
bash scripts/extract-law-ids.sh
```

**機能:**
- law-aliases.mdをパース
- カテゴリ別に整理して法令IDを出力
- Markdown形式で出力

**用途:**
- 法令ID一覧の確認
- ドキュメント生成
- 手動検証の参考資料

## 前提条件

すべてのスクリプトは以下を必要とします:

- **bash**: シェルスクリプト実行環境
- **curl**: HTTP通信（API呼び出しスクリプトのみ）
- **grep, sed**: テキスト処理
- **インターネット接続**: API呼び出しスクリプトと検証スクリプトのみ

## 関連ドキュメント

- [法令ID検証手順](../../docs/validate-law-ids.md) - 詳細な検証手順
- [主要法令エイリアス](../references/law-aliases.md) - 法令ID一覧
- [API リファレンス](../references/api-reference.md) - e-Gov API V2の詳細

## トラブルシューティング

### "Could not resolve host" エラー

DNSが解決できない場合:
1. インターネット接続を確認
2. プロキシ設定を確認
3. ファイアウォール設定を確認

### "法令IDが誤っています" エラー

law_idが無効な場合:
1. law-aliases.mdの記載を確認
2. search-laws.shで正しいlaw_idを検索
3. e-Gov APIの仕様変更を確認

詳細は [docs/validate-law-ids.md](../../docs/validate-law-ids.md) を参照してください。
