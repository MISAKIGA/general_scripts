@echo off

:STARTRUN
SC QUERY vmms | FINDSTR "STOPPED" > NUL && ECHO vmms����û������ & GOTO STARTSERVICE || GOTO RUNVIRTMGMT

:STARTSERVICE
NET START vmms >NUL && EXIT || ECHO HTPER-V_vmms START ERROR����ȷ���Ѿ�"�Թ���ԱȨ������"��bat & PAUSE & EXIT
GOTO STARTRUN

:RUNVIRTMGMT
%windir%\System32\virtmgmt.msc