#! /bin/sh

######################################################################
##                                                                  ##
##   检查日志脚本， 运维                                              ##
##   MSGA Create by 2021/7/2                                        ##
##   version: 1.0.0                                                 ##
######################################################################

# version 1.0.0
# 该版本存在问题：
# 1. 过滤规则适用于所有文件夹下的所有文件，
# 这意味着，如果spark的logs下需要过滤的文件与kafka的同名，则会将其都过滤掉。但是现在没有这个需求，先放着
# 2. 日志只能过滤 INFO 和 非 INFO 信息, 可能会有一些 java 报错给完全显示出来。（宁杀错不放过）
# 3. 日志显示不够友好，应该在最后才显示统计异常数量


load_var(){

    # 默认配置
    # 0 为启动，1 为关闭
    verbose=0
    # 检查日志行数(打印日志前 check_line_num 行)
    check_line_num=100
    # 需要匹配或者过滤的日志文件名，可以简称不填后缀名，自动匹配，按空格分隔
    filter_log_file=""
    # 匹配模式：0 为 只匹配存在与 filter_log_file 内的日志文件
    # 其他为 过滤 filter_log_file 内的日志文件 
    matched_pattern=0
    # 如果有多个文件夹需要遍历，在此设置，并且会遍历其子文件夹，空格分隔。
    # 注意：不要重复输入同一个文件夹，或者子文件夹
    log_dirs=""

    # 加载配置
    source $1
}

# 主程序入口
main(){
    conf_path=[lindex $argv 0]

    if [ -n $conf_path ];then
        conf_path="./check_logs.conf"
    fi
    echo "加载配置"
    load_var $conf_path
    echo "运行中..."

    # 检查指定的多个目录下的所有日志，每个目录都会遍历其子目录的日志
    echo "check_dirs: $log_dirs"
    
    for filepath in $log_dirs
    do
        check_dir_all_logs $filepath 
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
        if [ $matched_pattern -eq 1 ];then
            if [[ "$filter_log_file" != *$filename* ]];then
                temp_logs_files[${#temp_logs_files[@]}]=$file
            fi
        else
            if [[ "$filter_log_file" == *$filename* ]];then
                temp_logs_files[${#temp_logs_files[@]}]=$file
            fi
        fi
    
    fi 
}

# -----------------------------
# 递归遍历文件夹，并且获取文件路径
# 参数：filepath
traverse_dir()
{
    for file in `ls -a $1`
    do
        if [ -d $1/$file ]
        then
            if [[ $file != '.' && $file != '..' ]]
            then
                # 如果是文件夹则进行递归遍历
                traverse_dir $1"/"$file
            fi
        else
            # 查找指定后缀文件
            check_filename $1 $file
        fi
    done
}

#-----------------------

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
    info_num=0
    not_info_num=0
    txt_line_num=0
    
    # 修改 IFS 为遍历换行，而非空格换行
    change_ifs 0

    # 读取日志文件的每一行内容
    for line in `tail -$check_line_num $temp_filepath`
    do

        # 是否打印所有日志
        if [ $verbose -eq 0 ]; then
            echo "$line"
        fi
        # 统计 INFO 日志条数
        ((txt_line_num++));

    # 如果是 INFO 日志则统计数量，如果不是 INFO 日志，则统计并打印出来
    if [[ ${line} =~ "INFO" ]]; then
            ((info_num++));
        else
            ((not_info_num++));
            echo "$line 位于：$temp_filepath"
        fi
    done

    # 恢复 IFS
    change_ifs 1
 
    control_logs[${#control_logs[@]}]="---------------------"
    control_logs[${#control_logs[@]}]="扫描日志文件：$temp_filepath"
    control_logs[${#control_logs[@]}]="INFO日志：$info_num，非INFO日志：$not_info_num，遍历日志条数：$txt_line_num"

    unset temp_filepath
}
# --------- end

print_control_logs(){
    for log in ${control_logs[@]}
    do
        echo $log
    done
}

# -------
# 主程序，输入一个路径，遍历其路径下所有日志文件
# 参数：filter_log_file matched_pattern filepath
check_dir_all_logs(){
    
    # 递归遍历指定目录 
    traverse_dir $1

    # 如果有获取到日志文件
    if [ ${#temp_logs_files[@]} -gt 0 ];then

        for log_file in ${temp_logs_files[@]}
        do
            check_log_file $log_file $check_line_num $verbose
        done
        
        print_control_logs
        echo "---------------------"
        echo "本次扫描了 ${#temp_logs_files[@]} 个日志文件。"
    else
        echo "没有扫描到对应 log 文件。请检查目录！"
    fi
    echo "----------- 程序结束 ----------"
}

# clear
# Run the main function 
main