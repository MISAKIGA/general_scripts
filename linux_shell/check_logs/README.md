# 单机器日志检查 shell 脚本

[回到主页](/README.md)

脚本运行结构

```sh
check_logs
---------- check_logs.conf
---------- check_logs.sh
```

`check_logs.conf` 配置文件说明：

| 变量名          | 说明                                                         | 例子                                                         |
| --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| verbose         | 啰嗦模式。0 为启动，其他 为关闭                              | 1                                                            |
| check_line_num  | 检查日志行数(打印日志前 check_line_num 行)                   | 100                                                          |
| filter_log_file | 需要匹配或者过滤的日志文件名，按空格分隔                     | "state-change.log zookeeper_audit.log"                       |
| matched_pattern | 配合 filter_log_file 使用。匹配模式：0 为 只匹配存在与 filter_log_file 内的日志文件(交集)。其他为 过滤 filter_log_file 内的日志文件(差集) | 0                                                            |
| log_dirs        | 如果有多个文件夹需要遍历，在此设置，并且会遍历其子文件夹，空格分隔。注意：不要重复输入同一个文件夹，或者子文件夹 | "/export/servers/spark/logs /export/servers/kafka_2.12-2.8.0/logs /export/servers/zookeeper-3.7.0/logs /export/servers/hbase-2.4.2/logs" |

使用脚本

1. 将 `check_logs ` 文件夹下的配置文件和脚本下载下来。 https://github.com/MISAKIGA/general_scripts/tree/master/linux_shell/check_logs 

2. 将文件拷贝到服务器任意目录

   ```sh
   mv check_logs ${your_path}
   ```

3. 根据自己需求修改配置文件

   ```sh
   vi ./check_logs/check_logs.conf
   ```

4. 运行脚本

   ```sh
   ./check_logs.sh
   # OR
   . check_logs.sh
   # OR
   source check_logs.sh
   
   # 此外，您还可以将配置文件放置到其他位置，输入命令时将配置路径指定即可
   ./check_logs.sh ${your_conf_path}
   ```

   

