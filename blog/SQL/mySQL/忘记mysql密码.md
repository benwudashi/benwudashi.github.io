在my.ini文件（MySQL的配置文件）的[mysqld]下加一行skip-grant-tables

重启mysql:
windows:net stop mysql
       net start mysql
linux service restart mysqld
 重启MqSQL服务后，运行mysql -uroot -p,可以成功登入mysql

然后更新root账户的密码为'root'

命令：update mysql.user set authentication_string=password("root") where user="root";

然后输入flush privileges;（刷新账户信息）

执行quit或ctrl+Z退出

然后将my.ini文件中刚才加的skip-grant-tables这一行删掉，保存后再重启MySQL服务
