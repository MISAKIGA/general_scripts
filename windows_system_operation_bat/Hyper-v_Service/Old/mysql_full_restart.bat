@echo off

rem service name
SET service_name=mysql
rem port
SET service_port=3306


rem countDown
SET varCountDown=5

SC QUERY %service_name% | FINDSTR /i "RUNNING" >NUL && GOTO SERVICERUNNING || echo 正在启动" %service_name% "服务。。。

:SERVICESTARTNET
NET START %service_name% && GOTO END || GOTO STARTUPFAILED

:SERVICESTART
SC START %service_name% && GOTO END || GOTO STARTUPFAILED

:STARTUPFAILED
cls
SC QUERY %service_name% | FINDSTR "START_PENDING" > NUL && ECHO 启动请求已挂起,服务启动中,请稍等(可以退出该命令行)。。。& SET "varCountDown=5" & GOTO TIMER
SC QUERY %service_name% | FINDSTR "STOPPED" > NUL &&  GOTO SERVICESTART 
GOTO END 

:SERVICERUNNING
ECHO 正在重新启动" %service_name% "服务。。。 
NET STOP %service_name% && GOTO SERVICESTARTNET
NETSTAT -ano | FINDSTR %service_port% >NUL && ECHO 关闭 %service_port% 端口占用进程。。。 & GOTO  KILLPROCESS  || ECHO 没有找到占用 %service_name% 服务的端口：%service_port% 。可能该进程已经被关闭，请重新启动该bat & GOTO END

:KILLPROCESS 
CHCP 65001
FOR /F "tokens=1-5" %%i IN (

'NETSTAT -ano^|FINDSTR ":%service_port%"'

) DO (

ECHO kill the process %%m who use the port %service_port%
ECHO closing,please wait %%m...

TASKKILL /f /pid %%m
)
NETSTAT -ano | FINDSTR %service_port% >NUL && GOTO  KILLPROCESS || GOTO SERVICESTARTNET

:TIMER
set /a varCountDown=varCountDown-1
ping -n 2 -w 500 127.1>NUL
cls
SC QUERY %service_name%
SC QUERY %service_name% | FINDSTR "RUNNING" > NUL && (cls & ECHO %service_name% 服务已启动 ! & GOTO END)
IF  %varCountDown% LEQ 1 (GOTO STARTUPFAILED) ELSE (GOTO TIMER)

:END
ECHO -----------------------------服务状态----------------------------------------
SC QUERY  %service_name%
PAUSE