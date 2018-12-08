# ISUCON8 本選マニュアル

# はじめに

## スケジュール

- 10:00 競技開始
- 18:00 競技終了
- 以後主催者により結果チェックと追試


## ISUCON8 本選 ポータルサイト

本選は以下のポータルサイトからベンチマーク走行のリクエスト・結果チェックを行って進行します。
競技の開始時間になりましたら、事前に通知されているIDとパスワードを用いてポータルサイトへログインしてください。

**このページは18:00を過ぎると即座に閲覧不可能になります。ご注意ください。**

**https://portal.isucon8.flying-chair.net/**

ポータルサイトでは、ベンチマーカーが負荷をかける対象となるサーバーを1台選択することができます。
後述する競技後の追試でもこの設定を利用します。

**追試が実行できない場合は失格になるので、競技終了までにこの情報が正しいことを必ず確認してください。**

ポータルサイトでは、ベンチマーク走行の処理状況も確認できます。
ベンチマーク走行が待機中もしくは実行中の間はリクエストは追加できません。


## サーバー、ネットワーク構成について

競技者には、同一スペックの4台のサーバーが与えられます。
サーバーには連番のプライベートIPが割り振られており、初期構成ではすべてのサーバーに同じアプリケーションがデプロイされています。

各サーバーにはNICが3つ接続されていて、それぞれグローバルIPとプライベートIPとベンチマーカーIPが割り振られています。
各IPアドレスはポータルサイトから確認することができます。

競技者がサーバーに接続して作業を行う際や、Webブラウザ等で動作確認を行う際は **グローバルIP** を使用することができます。
サーバー間で通信を行う際は **プライベートIP** を使用することができます。
ベンチマーク走行は **ベンチマーカーIP** に対して実行されます。

グローバルIP側の帯域制限は、50Mbpsです。
プライベートIP側、ベンチマーカーIP側の帯域制限は、それぞれ1Gbpsです。


# 作業開始

以下の順序で作業を開始してください。


## 1. サーバーへのログイン

ポータルサイトに書かれてるグローバルIPアドレスに対して `ssh` してください。
サーバーはパスワード認証になっていて、ユーザー名は `isucon` 、パスワードはポータルサイト上で確認できます。

サーバーには本選終了後の主催者による確認作業(追試)のため、 `isucon-admin` ユーザーのアカウントがあります。

**`isucon-admin` ユーザーのアカウントに関して、アカウントの削除や既存の公開鍵の削除を行ったことにより主催者による追試をおこなうことができない場合は、失格とします。**


## 2. アプリケーションの動作確認

ポータルのサーバ情報の hostname を元に `https://{hostname}.isucon8.flying-chair.net` というURLでアクセスしてください。

`GET /` へアクセスすることで、トップページにアクセスすることができます。
画面右上の「サインアップ」から、ユーザを作成することができます。

#### 動作試験用いすこん銀行アカウント

以下のいすこん銀行アカウント (bank id) をベンチマークに影響しない富豪アカウントとして自由に使って構いません。
それぞれ残高は10億あります。

```
isucon-{001..100}
```


## 3. 負荷走行

ベンチマーク走行を行う際はポータルサイト上からリクエストします。
リクエストの際には対象となるサーバーの設定が必要です。

ポータルサイト上のServersタブにアクセスして、ベンチマーク走行を実行したいサーバーにチェックを入れて、設定を保存してください。

ポータルサイト上のDashboardタブにアクセスして、Enqueueをクリックすると、ベンチマーク走行リクエストがキューイングされ、主催者が用意したベンチマークサーバにより順次処理されます。
詳細については後述します。


## 参照実装の切り替え方法

`/etc/systemd/system/isucoin.service` の中の以下の行の、 `go` の部分を各言語 (`perl,ruby,python,php`) に修正します。

```
ExecStartPre = /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.go.yml build
ExecStart = /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.go.yml up
ExecStop = /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.go.yml down
```

例) Perl に変更する場合。

```
ExecStartPre = /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.perl.yml build
ExecStart = /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.perl.yml up
ExecStop = /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.perl.yml down
```

その後、再起動を行います。

```console
$ sudo systemctl daemon-reload
$ sudo systemctl restart isucoin
```

## リカバリ方法

参照実装で起動している MySQL のデータは Docker の local volume (webapp_mysql) に保存されています。Docker の外に出すなどの場合は mysqldump 等でデータを dump して、それを使用するのがよいでしょう。

```console
$ mysqldump -uroot -proot --host 127.0.0.1 --port 13306 isucoin > isucoin.dump
```

配布される4台のサーバすべてに同じデータは存在しますが、競技開始時に mysqldump 実行してバックアップしておくことを強くお勧めします。
競技中にデータをロストしても、運営からの救済は基本的に行いません。

# アプリケーションについて

## ストーリー

- いすこん銀行は、いすこん銀行の口座とAPIで連携した「仮想椅子取引所ISUCOIN」を開設
- 世界的に椅子ブームを追い風に取引も順調
- 社長は世界的SNS「いすばた」とプロモーション契約を締結し「いすばたシェア」機能を実装
- しかし、「いすばたシェア」の驚異的な拡散力により負荷に耐えられないことが発覚
- 社長「緊急メンテナンスをいれていいので18時までに改修しろ。18時にプロモーション開始だ」

## 概要

仮想の椅子取引所

椅子の買い注文と売り注文を行うことができ、注文の条件を満たせば取引が成立します。
成立した取引を示すロウソクチャートは毎秒更新されており、チャートはゲストユーザーからも参照することができます。

- 詳細仕様: [docs/WEBAPP_SPEC.md](WEBAPP_SPEC.md)

## 外部API

アプリケーションは2つの外部APIを利用しており、ビジネス的な観点でそれらを必ず利用しなければなりません。

#### いすこん銀行API (isubank)

口座の入出金や残高確認を行うことができる外部API

- 詳細仕様: [docs/ISUBANK_SPEC.md](ISUBANK_SPEC.md)


### 分析API (isulogger)

リアルタイム分析を提供する外部API

ログ送信内容の改変は認められず、欠落も認められません。  
データの送信遅延に関しては10秒までが許容されています。  

- 詳細仕様: [docs/ISULOGGER_SPEC.md](ISULOGGER_SPEC.md)


### [開発用] isubankとisulogger のモックアプリケーション

アプリケーションをローカルで開発する際に、利用可能なモックアプリケーションを用意しておりますので、必要に応じてご利用いただくことができます。  
※ ただし、モックアプリケーションは実際の外部サービスと異なりエラーを返すことはありませんのでご注意ください

#### 利用方法

1. 下記の方法でdocker-composeでアプリケーションと一緒にmockserviceを起動する(go言語の場合)
2. 手動で`POST initialize` を叩いて設定を反映する

```
cd webapp
docker-compose -f docker-compose.yml -f docker-compose.mockservice.yml -f docker-compose.go.yml up [-d]

curl https://127.0.0.1/initialize -k \
    -d bank_endpoint=http://mockservice:14809 \
    -d bank_appid=mockbank \
    -d log_endpoint=http://mockservice:14690 \
    -d log_appid=mocklog
```

# ルール詳細

指定された競技用サーバー上のアプリケーションのチューニングを行い、それに対するベンチマーク走行のスコアで競技を行います。 
与えられた競技用サーバーのみでアプリケーションの動作が可能であれば、どのような変更を加えても構いません。 
ベンチマーカーとブラウザの挙動に差異がある場合、ベンチマーカーの挙動を正とします。 
また、初期実装は言語毎に若干の挙動の違いはありますが、ベンチマーカーに影響のない挙動に関しては仕様とします。 

## ベンチマーク走行

ベンチマーク走行は以下のように実施されます。

1. 初期化処理の実行 `POST /initialize` (30秒以内)
2. アプリケーション互換性チェックの走行 (適宜: 数秒〜数十秒)
3. 負荷走行 (60秒)
4. 負荷走行後の確認 (適宜: 数秒〜数十秒)

各ステップで失敗が見付かった場合にはその時点で停止します。

負荷走行中のエラーについては、後述の成功とみなすリクエスト以外を原則エラーとし、負荷走行開始からの合計エラー数が規定値を超えた場合は負荷走行を失敗とみなします。

- 50x系エラーに関してはリトライを行いますが、リトライを含めて10秒以内に返せなかった場合はタイムアウトとみなしエラーとします。
- エラーの既定値は、20回から始まり獲得スコアに応じて増加し、最大50回となっています。
- 負荷走行完了前に後述のアクティブユーザーが0人となってしまった場合もエラーとなります。


## スコア計算

スコアは上記3の負荷走行中に成功したリクエスト数をベースに計算されます。
リクエスト当たりの点数は以下のルールで計算され、その合計がベンチマーク走行のスコアとなります。

| スコア対象 | スコア |
|------------|--------|
| `GET /` 及びページを表示するために必要な静的ファイル一式 | 1 |
| `GET /info` | 1 |
| `POST /signup` | 3 |
| `POST /signin` | 3 |
| `GET /orders` | 1 |
| `POST /orders` | 5 |
| `DELETE /order/{id}` | 5 |
| 取引成立した注文 | 10 |

以下を満たした場合リクエストが成功したと判定します。

- タイムアウトせずにレスポンスを返却する
- HTTPステータスコードが想定と一致する
- コンテンツの内容チェックを通過する

HTTPステータスコードは、基本的に参照実装と同一のものを想定しています。
ただし、静的コンテンツに関しては、HTTPの規則の範囲内でステータスコード200の代わりに304を返すことができます。

なお、各APIの成約事項はAPIドキュメントを参照してください。

#### エラーによる減点

エラーの回数に応じて下記の式で減点を行います

```
score * ( 1 - error_count / 100 )
```

* error_count の最大値は 50 なので最大で 50% 減点します


## アクティブユーザーの増加

負荷走行中、一定の条件下でアクティブユーザーが自然増加します。

ただし、リクエストがタイムアウトした場合、そのユーザーは離脱します。

また、各ユーザーのSNSシェア機能を有効化した場合、注文成立時にSNSシェアによってアクティブユーザーが流入します。


## 制約事項

以下の事項に抵触すると失格(fail)となり、点数が0点になります。

- `POST /initialize` へのレスポンスが30秒以内に戻らない場合
- アプリケーション互換性チェックに失敗した場合
- 負荷走行後の確認へのレスポンスがそれぞれ下記の規定秒数以内に戻らない場合
- publicディレクトリ以下の静的ファイルを改変した場合
- その他、ベンチマーカーのチェッカが失敗を検出したケース

最初に呼ばれる初期化処理 `POST /initialize` は用意された環境内で、チェッカツールが要求する範囲の整合性を担保します。
サーバーサイドで処理の変更・データ構造の変更などを行う場合、この処理が行っている内容を漏れなく提供してください。
また、この処理が30秒以上レスポンスを返さない場合、失格とします。

本選終了後に行われる主催者による確認作業(追試)において下記の点が確認できなかった場合は失格となります。

- アプリケーションは全て、保存データを永続化する必要があります。 
  つまり処理実施後に再起動が行われた場合、再起動前に行われた処理内容が再起動後に保存されている必要があります。
- アプリケーションは、ブラウザ上での表示を初期状態と同様に保つ必要があります。
- 以下に示すような、仕様に明記されている要件を満たせない改変を行ってはなりません。
    - 不正確なログを送信する
    - 取引の優先順位を著しく逸脱する
    - パスワードを平文で保存する

## リーダーボードの更新について

ポータルサイト上のリーダーボードのスコアは、競技終了前の1時間は表示は更新されなくなり、自チームのスコアのみ確認が可能になります。


## 特別賞

競技時間中のスコアが、最初に**15000** を超えた1チームを特別賞とします


## 最終スコア

**最終スコアは、競技時間終了後、再起動後に主催者によって実行した最初のスコアを採用する。**

### 本戦終了後に主催者によって行う作業手順

1. 全チームのサーバーを再起動
2. 全チームのベンチマークを管理者用のポータルからエンキューし計測
3. 2での結果がfailとなったチームのサーバーを再起動
4. 3の対称となったチームのベンチマークを2同様にポータルからエンキューし計測
5. 全チームのサーバーを再起動し、データ永続化チェック、画面表示の確認を行う  
   ここで確認ができなかったチームは失格とする
6. 5をパスしたチームの中からポータル上でのスコアを最終順位と決定する

### 本選終了後の注意事項

本選終了後は、サーバーに対して一切の操作を行わないでください。


# 既知の問題

- ブラウザでログインしている状態で、ベンチマークを回すと `/initialize` でユーザーを削除してしまうため、予期せぬ不具合が発生する場合があります。  
404を返しますが、念の為速やかにリロードしてください。

- 初期実装においてDBのトランザクションコミットに失敗した場合、いすこん銀行への送信済みデータとDB間で不整合が発生することが極稀にあります。  
この場合、ベンチマーカーは不整合を検知して失敗します。

- 負荷走行後のテストにおいて、ログの整合性チェックをせずに「ログが欠損しています」というエラーが発生することがあります。  
  これは、事後テストではランダムなユーザーに関して、未成約の注文をすべてキャンセルした後で、残高→ログの順に整合性テストを行っているが、残高のテストにパスした時点で規定の時間に達していた場合に発生する問題です。  
  基本的にアプリケーションが十分に高速化されていれば発生しない問題なのでログの経過時間などを目安に判断をしてください。

# その他

ベンチマークサーバやレギュレーションは、主催者は競技者に周知したうえで一時停止や変更を行うことがあります。

サポートは事前に連絡のあった discord のチャンネルにて行いますが、基本的に、本選環境の構成・操作方法やベンチマーカーの処理内容については返答しません。