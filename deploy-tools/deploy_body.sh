#!/bin/bash -x

echo "start deploy by ${USER}"
GOOS=linux go build -o app src/isucon/app.go
for server in webapp; do
    ssh -t $server "sudo systemctl stop isucon.golang.service"
    scp ./app $server:/home/isucon/webapp/go/isucon
    rsync -av ./src/isucon/views/ $server:/home/isucon/webapp/go/src/isucon/views/
    ssh -t $server "sudo systemctl start isucon.golang.service"
done

echo "finish deploy by ${USER}"