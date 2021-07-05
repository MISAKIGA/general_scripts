#! /bin/sh
remote_check(){

    list_file=$1
    src_file=$2
    dest_file=$3

    cat $list_file | while read line
    do
        host_ip=`echo $line | awk '{print $1}'`
        username=`echo $line | awk '{print $2}'`
        password=`echo $line | awk '{print $3}'`
        echo "$host_ip"
        dir_path=`dirname $dest_file`
	echo "创建文件夹：$dir_path"
        # 创建路径
        echo `./remote_mk.exp $host_ip $username $password $dir_path`
        echo "复制文件"
        # 复制脚本到服务器
        echo `./remote_scp.exp $host_ip $username $password $src_file $dest_file`
	echo "执行文件"
        # 执行check日志脚本
        echo `./remote_run.sh $host_ip $username $password $dest_file` 
    done
}

remote_check "./connect_list.conf" "/root/test.sh" "/root/scripts/check_logs/test.sh"
