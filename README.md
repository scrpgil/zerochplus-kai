# zerochplus改造PJ
zerochplusを改造してやる夫スレ＆アスキーアート用機能を拡張していくプロジェクトです。

## ご意見、ご要望について
色々意見いただけると助かります。
https://forms.gle/XVZGwfRa93JVGXqK8

## 開発環境の立ち上げ方。

以下のコマンドを実行します。

```
docker compose build
docker compose up
```

立ち上げ終わったら、 http://localhost:8080/test/admin.cgi にアクセスすると0chの管理画面が開きます。
ファイル共有しているのでプロジェクト配下のファイルを編集したら本番に反映されます。
bbsフォルダをgitignoreしてるので、掲示板作成時のディレクトリはbbsを推奨します。
