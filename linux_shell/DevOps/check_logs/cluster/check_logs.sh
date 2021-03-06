#! /usr/bin/expect

######################################################################
##                                                                  ##
##   检查日志脚本， 运维福利                                          ##
##   MSGA Create by 2021/7/2                                        ##
######################################################################

init_var(){
    # 0 为启动，1 为关闭
    verbose=0
    # 检查日志行数(打印日志前 check_line_num 行)
    check_line_num=100
    # 需要匹配或者过滤的日志文件名，可以简称不填后缀名，自动匹配，按空格分隔
    filter_log_file=$1
    # 匹配模式：0 为 只匹配存在与 filter_log_file 内的日志文件
    # 其他为 过滤 filter_log_file 内的日志文件 
    matched_pattern=$2
}

main(){
    check_dirs
}

# TODO: 放到调度框架里定时运行
# 为了满足集群日志检查，加多一个可以同时获取多个机器的日志并检查其是否异常
# 步骤
# 1. 拿到集群服务器的 IP，遍历运行
# 2. 通过 IP 和用户列表使用 SSH 远程连接到服务器，指定文件夹并且扫描日志文件
# 3. 控制台显示这些日志

check_cluster_logs(){
    cluster_ip="192.168.124.137"
}

# 检查指定的多个目录下的所有日志，每个目录都会遍历其子目录的日志
check_dirs(){
    log_filepaths="/icep_data/eventCenter/realTimeStreaming/logs /data01/eventTransfor/transfor/producer"
    filter_log_file="server"
    matched_pattern=0
    
    for filepath in $log_filepaths
    do
        echo "$filepath"
        check_dir_all_logs $filter_log_file $matched_pattern $filepath 
    done
}

# -------
# 主程序，输入一个路径，遍历其路径下所有日志文件
# 参数：filter_log_file matched_pattern filepath
check_dir_all_logs(){
    # 初始化所有参数
    init_var $1 $2
    
    #测试指定目录 
    traverse_dir $3

    # 如果数组大于 0
    if [ ${#temp_logs_files[@]} -gt 0 ];then
        for log_file in ${temp_logs_files}
        do
            check_log_file $log_file $check_line_num $verbose
            echo "本次扫描了 ${#temp_logs_files[@]} 个日志文件。"
        done
    else
        echo "没有扫描到对应 log 文件。请检查目录！"
    fi

    unset temp_logs_files
}

# -----------------------------
# 递归遍历文件夹，并且获取文件路径
# 参数：filepath
traverse_dir()
{
    filepath=$1
    
    for file in `ls -a $filepath`
    do
        if [ -d ${filepath}/$file ]
        then
            if [[ $file != '.' && $file != '..' ]]
            then
                # 如果是文件夹则进行递归遍历
                traverse_dir ${filepath}/$file
            fi
        else
            # 查找指定后缀文件
            check_filename ${filepath} $file
        fi
    done
}
 
# -------------------------
# 获取后缀为txt或log的文件，并过滤指定的字符串数组
# 参数：filepath filename
check_filename()
{
    filepath=$1
    filename=$2
    file=$filepath/$filename
    
    if [ "${file##*.}"x = "txt"x ] || [ "${file##*.}"x = "log"x ];then
        
        # 过滤指定的日志文件，并存到数组中
        if [[ $matched_pattern -eq 0 && $filename =~ "${filter_log_file[@]}" ]];then
            temp_logs_files[${#temp_logs_files[@]}]=$file
        else if [[ $matched_pattern -eq 1 && ! $filename =~ "${filter_log_file[@]}" ]];then
            temp_logs_files[${#temp_logs_files[@]}]=$file
        fi
        fi
    fi 
}

#-----------------------


# ------------------
#temp_foldername="/export/servers/kafka_2.12-2.8.0/logs"
#echo $temp_foldername
#get_files(){
#    if [ $temp_foldername -d ]; then
#    echo $temp_foldername
        # 如果是一个文件夹，则进行遍历，查看是否有对应的日志文件，获取其文件夹下的所有文件路径
#        for filename in $temp_foldername/*
#        do
#            echo "文件有 $filename"
            # temp_filepath="$temp_foldername/$filename"
            # 扫描到文件路径后，将其存储在临时的数组里，后面用来遍历扫描日志文件
#            temp_logs_files[${#temp_logs_files[@]}]=$filename
#        done
#    else
#        echo "没有该文件夹噢！ $temp_foldername"
#    fi
#}
# 检查日志文件是否有异常, 统计INFO数量，与非INFO数量
#check_logs(){
    # 遍历文件名，扫遍该文件并统计日志异常数量
#    i=0
#    for log_filename in temp_logs_files
#    do
#        temp_machine_files_len = ${#temp_machine_files[@]}
        # 遍历判断是否是指定的日志文件
#        if [ $temp_machine_files_len > $i && "${temp_machine_files[$i]}" = "$log_filename" ]; then
#            temp_filepath="${temp_machine_files[$i]}/$log_filename"
#            echo "检查 $temp_filepath 日志文件"
            # 检查日志是否有异常
#            check_log_file
#        fi
#        i = $i+1
#    done
#}
# --------------


# ----------------
# 修改循环遍历规则
# 参数：change_type(0 修改后循环将按照换行规则， 其他 按照空格规则) 
change_ifs(){
    change_type=$1
    if [ $change_type -eq 0 ]; then
        # 修改 IFS 使得 for 循环以行的方式遍历
        # 将原 IFS 值保存，以便用完后恢复
        IFS_old=$IFS      
        # 更改 IFS 值为$'\n'，注意，以回车做为分隔符，IFS 必须为：$'\n'
        IFS=$'\n'    
    else
        # 恢复原IFS值 
        IFS=$IFS_old     
    fi
}
# --------------
# 该方法会检查指定路径 temp_filepath 下的日志文件，
# 并且将其扫描日志并将统计信息和异常日志信息打印出来.
# 输入：temp_filepath(日志文件的绝对路径)  check_line_num(扫描文件前 check_line_num 条)  verbose(0 为启动详细模式)
check_log_file(){

    temp_filepath=$1
    check_line_num=$2
    verbose=$3
    info_num = 0
    not_info_num = 0
    txt_line_num = 0
    
    # 修改 IFS 为遍历换行，而非空格换行
    change_ifs 0

    # 读取日志文件的每一行内容
    for line in `tail -$check_line_num $temp_filepath`
    do

        # 是否打印所有日志
        if [ ${verbose} -eq 0 ]; then
            echo "$line"
        fi
        # 统计 INFO 日志条数
        ((txt_line_num++));

    # 如果是 INFO 日志则统计数量，如果不是 INFO 日志，则统计并打印出来
    if [[ ${line} =~ "INFO" ]]; then
            ((info_num++));
        else
            echo "---------------------"
            ((not_info_num++));
            echo "$line 位于：$temp_filepath"
            echo "---------------------"
        fi
    done

    # 恢复 IFS
    change_ifs 1
 
    echo "INFO 日志：$info_num，非 INFO 日志：$not_info_num, 遍历日志条数：$txt_line_num"

    # 清空变量，否则会累计记录导致统计数量错误
    unset info_num
    unset not_info_num
    unset txt_line_num
    unset temp_filepath
}
# --------- end

# Run the main function 
main