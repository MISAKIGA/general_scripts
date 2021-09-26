#! /bin/sh

######################################################################
##                                                                  ##
##   检查日志脚本， 运维                                              ##
##   远程日志检查版, 需要配合 check_logs 使用, 被扫描的机器上需要配置   ##
##   ，check_logs.sh 脚本。 注意：程序依赖 “sshpass”                  ##
##   MSGA Create by 2021/9/20                                       ##
##   version: 1.0.0                                                 ##
######################################################################


# 需要扫描日志文件的服务器 user@ip
remote_machine=(test1@127.0.0.1 test2@127.0.0.1)
# 对应的密码
machine_pwd=(123456 123456)

# 遍历执行命令
for(( i=0;i<${#remote_machine[@]};i++)) do

    echo "+++++++++++++++++++++【START SCAN】++++++++++++++++++++++++++++"
    echo "准备扫描：${remote_machine[i]} 日志文件"
    # 执行 ssh 命令
    # 执行机器需要有 sshpass
    ${sshpass_path}/sshpass -p ${machine_pwd[i]} ssh ${remote_machine[i]} ". .bashrc; sh ~/check_logs/check_logs.sh"
    echo "++++++++++++++++++++++++【END】+++++++++++++++++++++++++++++"
done