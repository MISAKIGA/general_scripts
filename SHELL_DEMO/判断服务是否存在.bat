@echo off

echo please input you service name!
SET /p service_name=

SC QUERY %service_name% > NUL
IF ERRORLEVEL 1060 GOTO NOTEXIST
GOTO EXIST

:NOTEXIST
ECHO not exist %service_name% service
GOTO END

:EXIST
ECHO exist %service_name% service
GOTO END

:END
pause