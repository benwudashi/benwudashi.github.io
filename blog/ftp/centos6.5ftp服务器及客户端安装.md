1、FTP服务器  
安装FTP服务器；  
（1）查看FTP版本  
命令： rpm -qa | grep vsftpd  
命令： yum list installed | grep vsftpd  
查看可安装版本： yum list | grep vsftpd  
输出： vsftpd.x86_64  
（2）安装与配置  
安装命令： yum -y install vsftpd.x86_64  
启动命令： service vsftpd start  
重启命令： service vsftpd restart  
开机启动查看： chkconfig --list | grep vsftpd  
开机启动设置： chkconfig vsftpd on  
（3）访问控制配置  
配置： sudo vi /etc/vsftpd/vsftpd.conf  
chroot_local_user=NO  
chroot_list_enable=YES  
chroot_list_file=/etc/vsftpd/chroot_list  
userlist_enable=YES  
userlist_deny=NO  
userlist_file=/etc/vsftpd/vsftpd.user_list  
anonymous_enable=NO  
#如果需要开启被动模式  
#pasv_enable=YES  
#pasv_min_port=6000  
#pasv_max_port=7000  
防火墙 ：  
 sudo vi /etc/sysconfig/iptables  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 20 -j ACCEPT  
创建用户：  
sudo useradd -s /bin/bash -d /var/ftp/ftpdata -m ftpuser -g ftp -G root  
设置密码命令：  
passwd ftpuser 密码设置为： ftppass  
控制用户访问：  
允许访问编辑： vim /etc/vsftpd/vsftpd.user_list 输入： ftpdata  
重启，即可使用工具等访问。  



客户端安装  
sudo rpm -Uvh http://mirror.centos.org/centos/6/os/x86_64/Packages/ftp-0.17-54.el6.x86_64.rpm  
sudo rpm -Uvh https://mirrors.aliyun.com/centos/6/os/x86_64/Packages/ftp-0.17-54.el6.x86_64.rpm  
