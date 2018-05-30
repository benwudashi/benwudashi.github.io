#!/bin/bash
. /etc/profile
. ~/.bash_profile ##加载环境变量
ftp_host=192.168.10.10
ftp_user=ftp_user
ftp_pass=ftp_pass
date_str=`date +%Y%m%d%H`
data_dir=/tmp/benwudashi
data_file=ry_${date_str}_data.txt
log_file=$data_dir/log/data_$date_str.log
ftp_mark_file=$data_dir/log/isUploadSucess.txt
## 判断日志目录是否存在，不存在则创建
if [ ! -d "${data_dir}/log" ];then
mkdir -p $data_dir/log
chmod 777 -R $data_dir
fi
touch $log_file
## 上传文件到ftp
function upload2ftp()
{
  if [ -f $data_dir/$data_file ];then
  ## "启用ftp上传文件"
  echo "启用ftp上传文件" >> $log_file
  rm -f $ftp_mark_file
  ##判断FTP传输文件是否成功
  exec 6>&1 1>$ftp_mark_file   ##打开一个文件描述符6，保存文件描述符1的属性，然后将描述1重定向到isUploadSucess.txt文件
  ftp -v -n $ftp_host << END
  user $ftp_user $ftp_pass
  binary
  lcd $data_dir
  prompt
  put  $data_file
  close
  bye
END
  exec 1>&6    ##将重定向的标准输出从文件描述符6恢复到描述符1
  exec 6>&-   ##关闭文件描述符6
    cat $ftp_mark_file >>$log_file ## 将文件描述符中内容记录到日志
    if grep -q "Transfer complete" $ftp_mark_file;then
        ## "ftp上传文件${data_dir}/${data_file} success!"
        echo "ftp上传文件${data_dir}/${data_file}  success!" >> $log_file
        rm -f ${data_dir}/${data_file} ## 删除上传成功的文件
EOF
    else
        rm -f  ${data_dir}/${data_file}
        echo "ftp上传文件${data_dir}/${data_file} failure!" >> $log_file
    fi
    else
      echo "文件${data_dir}/${data_file}不存在，无法上传" >> $log_file
  fi
}
## 运行函数
upload2ftp
