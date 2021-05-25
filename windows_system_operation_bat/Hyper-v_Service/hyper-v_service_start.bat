@echo off

NET START vmms >NUL && EXIT || ECHO HTPER-V_vmms START ERROR：请确认已经"以管理员权限运行"该bat & PAUSE