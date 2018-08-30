cat oper.txt |/user/local/src/redis-cli -h 127.0.0.1 -p 6379 -a **** -n 1 --pipe
`-n 表示数据库` 相当于进入数据库后 `select 1`
