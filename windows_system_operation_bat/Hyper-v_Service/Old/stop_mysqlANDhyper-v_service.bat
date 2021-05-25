@echo off


SET mysql_service_port=3306

ECHO 正在关闭服务，请稍等。。。

NET STOP mysql >NUL 2>NUL && ECHO MYSQL STOP OK || GOTO MYSQLSTOPFAILED

:STOPVMMS
NET STOP vmms >NUL 2>NUL && ECHO HYPER-V STOP OK & EXIT || GOTO END

:MYSQLSTOPFAILED
SC QUERY mysql | FINDSTR "STOPPED" > NUL && ECHO mysql服务没有启动 &  GOTO STOPVMMS
CHCP 65001
FOR /F "tokens=1-5" %%i IN (

'NETSTAT -ano^|FINDSTR ":%mysql_service_port%"'

) DO (

ECHO kill the process %%m who use the port %mysql_service_port%
ECHO closing,please wait %%m...

TASKKILL /f /pid %%m
)
SC QUERY %service_name% | FINDSTR "STOPPED" > NUL &&  ECHO MYSQL STOP OK & GOTO STOPVMMS

:END 
pause