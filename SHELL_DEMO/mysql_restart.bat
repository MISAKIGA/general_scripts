@echo off

::设置服务名称
SET service_name=mysql
::设置服务端口（用于强制关闭服务）
SET service_port=3306
::设置重启服务次数
SET failedCount=3
::设置倒数时间
SET countDown=6

::
SET /a varCountDown=countDown

echo %service_name% service restart...  
SC QUERY %service_name% | FINDSTR "1 STOPPED" >NUL && ECHO service has started GOTO SERVICESTART || echo serive restart... GOTO SERVICESTOP

:SERVICESTOP
NET STOP %service_name% && GOTO SERVICESTART || GOTO STOPFAILED 


:STOPFAILED
GOTO KILLPROCESS               

:SERVICESTART
if %failedCount% LEQ 1 && GOTO END || echo 

:STARTUPFAILED
SET /a failedCount = %failedCount% - 1 & set /a varCountDown=countDown
GOTO TIMER


:KILLPROCESS 
cls
ECHO The service has started and the service is being forced to close. 
NETSTAT -ano | FINDSTR %service_port% >NUL && GOTO  HASPORT || GOTO NOTHASPORT

:HASPORT 
CHCP 65001
FOR /F "tokens=1-5" %%i IN (

'NETSTAT -ano^|FINDSTR ":%service_port%"'

) DO (

ECHO kill the process %%m who use the port %service_port%
ECHO closing,please wait %%m...

TASKKILL /f /pid %%m

)
GOTO NOTHASPORT

:NOTHASPORT
GOTO SERVICESTART

:TIMER
set /a varCountDown=varCountDown-1
ping -n 2 -w 500 127.1>NUL
cls
echo Restart the %service_name% service after: %varCountDown% seconds...
echo Remaining restarts: %failedCount%
IF  %varCountDown% LEQ 1 (GOTO SERVICESTART) ELSE (GOTO TIMER)


:SERVICERUN
GOTO END

:END
SC QUERY %service_name%
pause
::exit