#!/bin/bash

DATE=`date '+%Y%m%d-%H%M%S'`
LOGDIR=/root/isucon7-logs
LOGPATH=$LOGDIR/$DATE
PPROF_PORT=16061
PPROF_SAMPLING_TIME=90

mkdir -p $LOGPATH
rm $LOGDIR/latest 2&> /dev/null
ln -sf $LOGPATH $LOGDIR/latest

# pre todo
# nginxのlog format変更
# mysqlのslow log設定の追加

# restart
echo "PREPARE BENCH" 
systemctl stop nginx
systemctl stop isubata.golang
systemctl stop mysql

NGINX_LOG=/var/log/nginx
MYSQL_LOG=/var/log/mysql

mv $NGINX_LOG/access.log $NGINX_LOG/access-${DATE}.log
mv $MYSQL_LOG/mysql-slow.log $MYSQL_LOG/mysql-slow-${DATE}.log

systemctl start mysql
systemctl start isubata.golang
systemctl start nginx
echo "PREPARED BENCH" 

# initialize
#/home/isucon/isubata/db/init.sh
#zcat /home/isucon/isubata/bench/isucon7q-initial-dataset.sql.gz | sudo mysql isubata

# pprof
echo "START pprof"
if [ `ps aux | grep -v grep | grep pprof | wc -l` -ne 0 ]; then
  ps aux | grep pprof | grep -v grep | awk '{print $2}' | xargs kill -kill
fi
/home/isucon/local/go/bin/go tool pprof -seconds=$PPROF_SAMPLING_TIME -http=0.0.0.0:16061 http://127.0.0.1:6060/debug/pprof/profile > /tmp/pprof.log 2>&1 &

# benchmark
echo "START BENCH" 
#echo "START BENCH" | notify_slack
cd  /home/isucon/isubata/bench
./bin/bench -remotes=127.0.0.1 -output $LOGPATH/result.json

# log
cd /home/tools/kataribe
cat $NGINX_LOG/access.log | ./kataribe -f kataribe.toml > $LOGPATH/kataribe.log
pt-query-digest $MYSQL_LOG/mysql-slow.log > $LOGPATH/pt-query-digest.log
jq . $LOGPATH/result.json > $LOGPATH/jq-result.log
bash /home/isucon/isubata/db/check_db.sh > $LOGPATH/check-db.log

cd $LOGDIR
git add .
git commit -m "update logs"
git push origin master

echo "END BENCH"
#echo "END BENCH" | notify_slack
