@echo off

SET sIP=192.168.66.88
SET subnet=255.255.240.0
SET gateway=192.168.79.254  
SET  sDNS=192.168.1.253

netsh interface ip set address name ="wlan" static %sIP% %subnet% %gateway%  
netsh interface ip set dns name ="wlan" static %sDNS%  

