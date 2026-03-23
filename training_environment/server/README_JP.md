# トレーニングサーバー セットアップ手順

WorldSkills Competition トレーニング用の Docker Compose 環境です。
ローカルまたは GCP Compute Engine VM で動作します。

## ローカル セットアップ

### 前提条件

- Docker と Compose プラグイン (`docker compose version` で確認)

### 1. .env の設定

```bash
cp .env.example .env
```

`.env` を編集し、以下の変数を設定します。`GCP_*` 変数はローカル環境では不要です。

| 変数 | 説明 |
|---|---|
| MYSQL_ROOT_PASSWORD | MariaDB の root パスワード |
| MYSQL_USER | アプリケーション DB ユーザー名 |
| MYSQL_PASSWORD | アプリケーション DB パスワード |
| SSH_USER | SSH ログインユーザー名 |
| SSH_PASSWORD | SSH ログインパスワード |
| SSH_SUDO_ACCESS | SSH コンテナ内での sudo 許可 (`true` / `false`, デフォルト: `false`) |
| HTTP_PORT | Apache のホストポート (コンテナポート 80) |
| SSH_PORT | SSH のホストポート (コンテナポート 2222) |
| MARIADB_PORT | MariaDB のホストポート (コンテナポート 3306) |

### 2. 起動

```bash
./local-setup.sh
```

全 3 コンテナ (Apache, MariaDB, SSH) がビルド/プルされ、起動します。
healthy 状態になるまで待機し、接続情報が表示されます。

### 3. 動作確認

```bash
./local-check.sh
```

Apache, PHP, SSH, MariaDB の疎通とタイムゾーンをチェックします。
全項目が `[PASS]` になれば正常です。

### 4. 接続

```
HTTP      http://localhost:<HTTP_PORT>
SSH       ssh -p <SSH_PORT> <SSH_USER>@localhost
MariaDB   localhost:<MARIADB_PORT>  (user: <MYSQL_USER>)
```

## GCE セットアップ

### 前提条件

- Google Cloud SDK (`gcloud` CLI)
- Compute Engine API が有効な GCP プロジェクト

### 1. .env の設定

```bash
cp .env.example .env
```

`.env` を編集し、全ての変数を設定します:

| 変数 | 説明 |
|---|---|
| GCP_PROJECT | GCP プロジェクト ID (`changeme` のままでは実行不可) |
| GCP_ZONE | VM ゾーン (デフォルト: `us-central1-a`) |
| GCP_VM_NAME | VM インスタンス名 (デフォルト: `wsc-training`) |
| GCP_MACHINE_TYPE | マシンタイプ (デフォルト: `e2-micro`) |
| MYSQL_ROOT_PASSWORD | MariaDB の root パスワード |
| MYSQL_USER | アプリケーション DB ユーザー名 |
| MYSQL_PASSWORD | アプリケーション DB パスワード |
| SSH_USER | SSH ログインユーザー名 |
| SSH_PASSWORD | SSH ログインパスワード |
| SSH_SUDO_ACCESS | SSH コンテナ内での sudo 許可 (`true` / `false`, デフォルト: `false`) |
| HTTP_PORT | Apache のホストポート |
| SSH_PORT | SSH のホストポート |
| MARIADB_PORT | MariaDB のホストポート |

### 2. デプロイ

```bash
./gce-setup.sh
```

VM の作成、ファイアウォール設定、ファイルのアップロード、VM 上での Docker インストール、全コンテナの起動を行います。
完了時に VM の外部 IP が表示されます。

途中で失敗した場合、作成済みリソースの一覧が表示されます。手動でのクリーンアップが必要な場合があります。

### 3. 動作確認

```bash
./gce-check.sh <VM_EXTERNAL_IP>
```

Apache, PHP, SSH, MariaDB の疎通をチェックします。
全項目が `[PASS]` になれば正常です。

### 4. 接続

```
HTTP      http://<VM_IP>:<HTTP_PORT>
SSH       ssh -p <SSH_PORT> <SSH_USER>@<VM_IP>
MariaDB   <VM_IP>:<MARIADB_PORT>  (user: <MYSQL_USER>)
```

### ファイアウォールルール

| ルール | ポート | ソース |
|---|---|---|
| `<GCP_VM_NAME>-allow-http` | HTTP_PORT | 自分の IP のみ |
| `<GCP_VM_NAME>-allow-ssh` | SSH_PORT | 0.0.0.0/0 (全 IP) |
| `<GCP_VM_NAME>-allow-mariadb` | MARIADB_PORT | 自分の IP のみ |

### コスト

全リソースが GCP 無料枠内: e2-micro (730 時間/月), 30 GB standard ディスク, 1 GB エグレス。

## リファレンス

### サービス構成

| サービス | イメージ | コンテナ名 | 内部ポート |
|---|---|---|---|
| Apache + PHP 8.4 | php:8.4-apache (カスタムビルド) | apache_php | 80 |
| MariaDB 11 | mariadb:11 | mariadb | 3306 |
| SSH | lscr.io/linuxserver/openssh-server:latest | ssh_server | 2222 |

全コンテナのタイムゾーンは UTC です。

### Apache + PHP

- DocumentRoot: `/var/www/html`
- mod_rewrite 有効、AllowOverride All
- Composer グローバルインストール済み
- PHP 拡張: pdo_mysql, gd (freetype + jpeg), zip, opcache (mbstring と curl はビルトイン)
- PHP 設定: `upload_max_filesize=64M`, `post_max_size=64M`, `memory_limit=128M`, `max_execution_time=120`
- エラー表示: `display_errors=On`, `error_reporting=E_ALL`
- `/phpinfo.php` がデフォルトで配置済み

### MariaDB

- 初回起動時に `init.sh` が 20 個のデータベースを作成 (`<MYSQL_USER>_01` ~ `<MYSQL_USER>_20`)
- `MYSQL_USER` に各データベースへの `ALL PRIVILEGES` を付与 (グローバル GRANT OPTION なし)
- データは `db_data` ボリュームに永続化

### SSH

- パスワード認証が有効
- UID/GID 33 (www-data) で動作し、Apache のファイル所有権と一致
- `web_data` ボリュームを介して Apache と `/var/www/html` を共有
- ホスト鍵は `ssh_config` ボリュームに永続化

### local-setup.sh

1. 必須 .env 変数が設定されているか検証
2. Docker と Compose プラグインがインストールされているか確認
3. `docker compose up -d --build` を実行 (Apache イメージのビルド、MariaDB と SSH イメージのプル)
4. 全 3 コンテナが healthy になるまで最大 60 秒待機
5. コンテナステータスと接続情報を表示

### local-check.sh

localhost に対して以下の 6 項目をチェック:

1. Apache HTTP レスポンス (200, 301, 302, 403 のいずれかを期待)
2. PHP 動作確認 (`/phpinfo.php` が 200 を返すか)
3. SSH ポート疎通 + OpenSSH バナー確認。`sshpass` がインストール済みの場合はパスワードログインも検証
4. MariaDB ポート疎通 + `MYSQL_USER` でのログイン + 20 データベースの存在確認
5. Apache コンテナ内から PDO 経由で MariaDB への接続確認
6. 全 3 コンテナのタイムゾーンが UTC であることを確認

### gce-setup.sh

1. 全 .env 変数の検証と `gcloud` CLI の存在確認
2. `https://ifconfig.me` で自分のグローバル IP を取得
3. VM インスタンスを作成 (Ubuntu 24.04 LTS, 30 GB pd-standard ディスク)。既存の場合はスキップ
4. ファイアウォールルールを 3 つ作成 (既存の場合はスキップ):
   - `<GCP_VM_NAME>-allow-http` — TCP `HTTP_PORT`, ソース: 自分の IP のみ
   - `<GCP_VM_NAME>-allow-ssh` — TCP `SSH_PORT`, ソース: 0.0.0.0/0 (参加者アクセス用に全 IP 許可)
   - `<GCP_VM_NAME>-allow-mariadb` — TCP `MARIADB_PORT`, ソース: 自分の IP のみ
5. VM の SSH が利用可能になるまで最大 150 秒待機
6. `gcloud compute scp` で `vm/` ディレクトリと `.env` を VM の `~/project/` にアップロード
7. VM 上で `setup.sh` を実行:
   - システムパッケージの更新 (`apt-get update && upgrade`)
   - Docker と Compose プラグインのインストール
   - ユーザーを docker グループに追加
   - `docker compose up -d --build` を実行
   - 全コンテナが healthy になるまで最大 90 秒待機
8. VM の外部 IP と接続情報を表示

### gce-check.sh

VM に対して以下の 4 項目をチェック:

1. Apache HTTP レスポンス
2. PHP 動作確認 (`/phpinfo.php`)
3. SSH ポート疎通 + OpenSSH バナー確認
4. MariaDB ポート疎通
