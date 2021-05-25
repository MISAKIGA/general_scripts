@ECHO OFF


REM WLAN_SSID
REM WLAN_PASSWORD

::WIFI账号
SET WLAN_SSID=MSGA
::WIFI密码
SET WLAN_PASSWORD=22223333

:INIT
ECHO 1:CLOSE WLAN. OTHER KEY: CONTINUE.
SET /P INUPT=your input:
IF  %INUPT% LEQ 1 (GOTO CLOSEWLAN)
NETSH WLAN SHOW HOSTEDNETWORK | FINDSTR "已启用" > NUL && GOTO WLANISOPEN 
SC QUERY esurfingsvr > NUL  && ECHO init OK & GOTO OPENWLAN || ECHO Yong Net SERVICE NOT START!  Please restart yong net  & GOTO END 

:WLANISOPEN 
ECHO Restart wlan net
NETSH WLAN STOP HOSTEDNETWORK
GOTO INIT

:OPENWLAN
NET STOP esurfingsvr 
TASKKILL /IM "ESurfingClient.exe"
NETSH WLAN SET HOSTEDNETWORK MODE=allow SSID=%WLAN_SSID% KEY=%WLAN_PASSWORD%
NETSH WLAN START HOSTEDNETWORK
NETSH WLAN SHOW HOSTEDNETWORK | FINDSTR "已启用" > NUL & ECHO WIFI IS OPEN！
GOTO END

:CLOSEWLAN
NETSH WLAN STOP HOSTEDNETWORK

:END
NETSH WLAN SHOW HOSTEDNETWORK 
PAUSE