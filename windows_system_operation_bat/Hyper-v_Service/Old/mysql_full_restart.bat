@echo off

rem service name
SET service_name=mysql
rem port
SET service_port=3306


rem countDown
SET varCountDown=5

SC QUERY %service_name% | FINDSTR /i "RUNNING" >NUL && GOTO SERVICERUNNING || echo ��������" %service_name% "���񡣡���

:SERVICESTARTNET
NET START %service_name% && GOTO END || GOTO STARTUPFAILED

:SERVICESTART
SC START %service_name% && GOTO END || GOTO STARTUPFAILED

:STARTUPFAILED
cls
SC QUERY %service_name% | FINDSTR "START_PENDING" > NUL && ECHO ���������ѹ���,����������,���Ե�(�����˳���������)������& SET "varCountDown=5" & GOTO TIMER
SC QUERY %service_name% | FINDSTR "STOPPED" > NUL &&  GOTO SERVICESTART 
GOTO END 

:SERVICERUNNING
ECHO ������������" %service_name% "���񡣡��� 
NET STOP %service_name% && GOTO SERVICESTARTNET
NETSTAT -ano | FINDSTR %service_port% >NUL && ECHO �ر� %service_port% �˿�ռ�ý��̡����� & GOTO  KILLPROCESS  || ECHO û���ҵ�ռ�� %service_name% ����Ķ˿ڣ�%service_port% �����ܸý����Ѿ����رգ�������������bat & GOTO END

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
SC QUERY %service_name% | FINDSTR "RUNNING" > NUL && (cls & ECHO %service_name% ���������� ! & GOTO END)
IF  %varCountDown% LEQ 1 (GOTO STARTUPFAILED) ELSE (GOTO TIMER)

:END
ECHO -----------------------------����״̬----------------------------------------
SC QUERY  %service_name%
PAUSE