# sandbox-php-fpm-log
Q. PHPスクリプトを動かした際に出てきたログやエラーをファイルに記録するにはどうしたらよいか？

A. php-fpm の設定ファイルで以下の設定を追記して、php-fpm サービスを再起動する

```
# アクセスログを記録する場合
access.log = /var/log/php-fpm/access.log

# エラーログ
php_admin_value[error_log] = /var/log/php-fpm/error.log
php_admin_flag[log_errors] = on
```

# 動作確認方法

- AMIとして「Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type」を選択し、ユーザデータとして `install.sh` の中身をコピペしたEC2インスタンスを立ち上げる。
- http://<立ち上げたEC2インスタンスのパブリックIPアドレス>:80/index.html をブラウザで開く
- http://<立ち上げたEC2インスタンスのパブリックIPアドレス>:80/index.php をブラウザで開く
- 立ち上げたEC2インスタンスにSSHでアクセスする。
- `ls -al /var/log/nginx` を実行して、アクセスログとエラーログが記録されていることを確認する
- `ls -al /var/log/php-fpm` を実行して、アクセスログとエラーログが記録されていることを確認する
