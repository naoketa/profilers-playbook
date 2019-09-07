#!/bin/bash

DATE=`date '+%Y%m%d-%H%M%S'`
LOGPATH=/home/isucon/isubata/logs/$DATE
export PATH=$PATH:/home/isucon/isubata/tmp

mkdir $LOGPATH

# restart
systemctl stop nginx
systemctl stop isubata.golang
systemctl stop mysql

mv /var/log/nginx/access.log /var/log/nginx/access-${DATE}.log
mv /var/lib/mysql/mysqld-slow.log /var/lib/mysql/mysqld-slow-${DATE}.log

systemctl start mysql
systemctl start isubata.golang
systemctl start nginx

# initialize
#/home/isucon/isubata/db/init.sh
#zcat /home/isucon/isubata/bench/isucon7q-initial-dataset.sql.gz | sudo mysql isubata

# pprof
# TODO: スクリプトの中に埋め込む方法模索中
#echo "START pprof"
#ps aux | grep pprof | grep -v grep | awk '{print $2}' | xargs kill -kill
#/home/isucon/local/go-1.11/bin/go tool pprof -seconds=120 -http=10.0.2.15:16061 http://127.0.0.1:6060/debug/pprof/profile &

# benchmark
echo "START BENCH" 
#echo "START BENCH" | notify_slack
cd  /home/isucon/isubata/bench
./bin/bench -remotes=127.0.0.1 -output $LOGPATH/result.json

# log
cd /home/tools/kataribe
cat /var/log/nginx/access.log | ./kataribe -f kataribe.toml > $LOGPATH/kataribe.log
pt-query-digest /var/lib/mysql/mysqld-slow.log > $LOGPATH/pt-query-digest.log
jq . $LOGPATH/result.json > $LOGPATH/jq-result.log
bash /home/isucon/isubata/db/check_db.sh > $LOGPATH/check-db.log

cd $LOGPATH
git add .
git commit -m "update logs"
sudo -u isucon git push

echo "END BENCH"
#echo "END BENCH" | notify_slack
