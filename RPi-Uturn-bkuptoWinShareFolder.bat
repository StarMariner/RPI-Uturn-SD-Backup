ECHO off

REM Backup remote Raspberry PI devices to a Windows Shared Folder.


REM Quick note, I am not responsible for any problems including loss of data. Its up to you to check and modify to your wishes.
REM It's by no means finished . you can cut out the code add code, thats up to you.

REM pi_nicename could be a hostname of the Raspberry Pi, that needs more programming to achieve.
REM I have not put much fail logic in this script. 
REM WORKS for /f "tokens=2" %%i in ('nslookup 192.168.1.110 ^| findstr /C:"Name"') DO SET pi1_nicename=%%i
REM below is a cheat to find the hostname of the remote pi using NSlookup command. 
REM the for loop is tricked using /f to read from a file, the std output is scanned for the "Name" which is part of the usual output.
REM the tokens  is like a column look up. effectivly the output is looked at line by line in string 2 if it fines the string Name.
REM Best REF: https://devblogs.microsoft.com/oldnewthing/20120731-00/?p=7003
REM get pi1_nicename from NSlookup it might not be the hostname, its what the name server has .
REM NOTE: A blank result is OFFLINE, no raspberry pi connected.

:BEGIN
REM ------------- CHANGE VALUES TO MATCH YOUR  DEVICES----------------

SET pi_winshare=~/winshare

SET win_shared=//Windows-Boss/Raspberry_pi
SET win_user=Paul A

SET pi1_user=pi
SET pi1_ip=192.168.1.100

SET pi2_user=pi
SET pi2_ip=192.168.1.101

SET pi3_user=pi
SET pi3_ip=192.168.1.102


REM ------------- DONT MAKE ANY CHANGES BEYOND THIS POINT ----------------

SET pi1_ssh=%pi1_user%@%pi1_ip%
SET pi1_nicename= **** OFFLINE ****
FOR /f "tokens=2" %%i IN ('nslookup %%pi1_ip%% ^| findstr /C:"Name"') DO SET pi1_nicename=%%i

SET pi2_ssh=%pi2_user%@%pi2_ip%
SET pi2_nicename=**** OFFLINE ****
FOR /f "tokens=2" %%l IN ('nslookup %%pi2_ip%% ^| findstr /C:"Name"') DO SET pi2_nicename=%%l

SET pi3_ssh=%pi3_user%@%pi3_ip%
SET pi3_nicename=**** OFFLINE ****
FOR /f "tokens=2" %%k IN ('nslookup %%pi3_ip%% ^| findstr /C:"Name"') DO SET pi3_nicename=%%k


CLS 

ECHO -------------------- RASPBERRY PI DISK BACKUP TO REMOTE COMPUTER ------------------------
REM  **Next two lines allow command 'whoami' output text to be appened to the end of an ECHO statement **
ECHO/
ECHO | SET /p dummy = Local Windows user = 
whoami
ECHO You must enable Windows sharing for the backup directory %win_shared% . You'll see the file upload there.
ECHO Also, on the pi this script makes and mounts a directory called ~/winshare/
ECHO/
ECHO Choose a remote device that needs Full Backup
ECHO/
ECHO    User @ IP address    NS Lookup Name
ECHO [1] %pi1_user%@%pi1_ip%	%pi1_nicename%
ECHO [2] %pi2_user%@%pi2_ip%	%pi2_nicename%
ECHO [3] %pi3_user%@%pi3_ip%	%pi3_nicename%
ECHO/

CHOICE /N /C:123 /M "From what Raspberry_Pi do you want a FULL backup? (1, 2, or 3)"%1

IF ERRORLEVEL ==3 GOTO THREE
IF ERRORLEVEL ==2 GOTO TWO
IF ERRORLEVEL ==1 GOTO ONE
GOTO END


:THREE
SET nicefilename=%pi3_nicename%.img
SET pi_ssh=%pi3_user%@%pi3_ip%
GOTO BKUP_SCRIPT

:TWO
SET nicefilename=%pi2_nicename%.img
SET pi_ssh=%pi2_user%@%pi2_ip%
GOTO BKUP_SCRIPT

:ONE
SET nicefilename=%pi1_nicename%.img
SET pi_ssh=%pi1_user%@%pi1_ip%
GOTO BKUP_SCRIPT


:BKUP_SCRIPT
ECHO =============== Backup %pi_nicename% disk to image file %win_shared%  ============
REM  The following linux commands inside the DOuble quotes can be put into a shell script and run locally on the pi.
REM WIP, Need to find a better way of detecting if you are copying to the local pi or the remote Windows machine. No win login, then your probably stil on the pi.

SET piMountBkupScript=" [ ! -d %pi_winshare% ] && mkdir %pi_winshare% ; [ -d %win_shared% ] ;  sudo mount.cifs %win_shared% %pi_winshare% -o user=%win_user% ; cd %pi_winshare% ; ls -l ; echo START of backup, please wait ; sudo -S dd bs=4M if=/dev/mmcblk0 status=progress of=%pi_winshare%/%nicenfileame%.img ; echo COMPLETED backup ; bash "

ssh -t  %pi_ssh% %piMountBkupScript%
GOTO END


:END
ECHO  Finished Backup upload.
cmd /k
