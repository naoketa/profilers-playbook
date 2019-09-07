# OS, ミドルウェアの設定テンプレート

## 対象ソフトウェア

* バージョンは、5/3時点でのstable版の最新を想定

* OS
    * [CentOS 7.6.1810](https://www.centos.org/)

* web(proxy, webdav)
    * [H2O 2.2.5](https://h2o.examp1e.net/)
        * まだunixドメイン/tcpのルーティングが併用できないのでNginxのほうが良さそう
        * 2倍くらいの性能差
    * [Nginx 1.16.0](https://nginx.org/)

* db
    * [MariaDB(MySQL) 10.3](https://mariadb.org/)
    * [PostgreSQL 11.2](https://www.postgresql.org/)
    * [MongoDB 4.0.9](https://www.mongodb.com/jp)
    * [Redis 5.0.4](https://redis.io/)

## 特に確認しておきたい項目

* web
    * 複数台構成への変更方法(proxy化)
    * 静的ファイルの配信設定

* db
    * コネクションに関する設定
    * キャッシュのクラスタリングに関する設定

# すること

## 5/11まで

* 過去のISUCON参加者の設定ファイルを拝借(バージョン差異は考慮しない)
    * [x] OS
    * [x] H2O
    * [x] Nginx
    * [x] MySQL
    * [x] PostgreSQL
    * [x] MongoDB
    * [x] Redis

* 特に重要な設定について、設定ファイルにコメント追加
    * web
        * [x] 複数台構成への変更方法
        * [-] 静的ファイルの配信設定(h2oで一部残。動作確認が必要)

    * db
        * [x] コネクションに関する設定
        * [x] キャッシュのクラスタリングに関する設定 -> 使わないでしょ。未調査

## 5/12以降、できればしたいこと

* [ ] 重要ではない設定でも理解しておきたい(特にnginx周りの設定の大半がよくわかっていない)
* [ ] memcachedも必要かも(デフォルトでアプリが利用している可能性がありそう)
* [ ] 対象バージョンでの動作確認(インストール手順まとめや複数台構成変更方法等も含む)
    * postgresqlのpt-query-digestの動作確認等
    * mongoDBをそもそも触った機会が少ない
* [ ] Goからの利用方法(ライブラリ検討、サンプルアプリ開発)
* [ ] チューニング方法の調査(クエリキャッシュ等)
* [ ] ansible化

# その他

* WebDAV機能とは
  * Webサーバーを活用して、ファイル共有と編集ができる技術や機能のこと
