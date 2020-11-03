@ECHO off
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
REM Raspberry pi prerequisites. RaspberryPiOS should have all you need already built in, including. ntfs support via cifs. copy ssh file to the boot partition.
REM To be secure anyway, do a  $ sudo update before any changes.
REM Windows prerequisites. Windows 10 as OCT 2020 has SSH command and similar linux commands built in to the CMD terminal, no need for WSL.
REM I broke the link moving the lan cable on on epi and it recovered without error or intervantion.
REM [X] DONE. WIP, Need to find a better way of detecting if you are copying to the local pi or the remote Windows machine. No win login, then your probably stil on the pi.
REM NOTE: RaspberryPiOS is new, it replaces what was previously known as Raspbian
REM Prerequisites. None needed as of October 2020 . Windows 10, SSH is now built in. RaspberryPiOS, ntfs /cifs now builtin.
REM Sort ssh timeout. May be ping or something? NSlookup is good but it doesnt show if its live or dead.

:BEGIN

REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
REM [[[[[[[[[[[[[ CHANGE SET VALUES TO MATCH YOUR DEVICES ]]]]]]]]]]]
REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]

REM Replace windows shared folder name below to match yours. Manually remove any leftside characters before //. eg. SET win_shared=//machine/shared_folder
SET win_shared=//WINDOWSMACHINE/Raspberry_pi_SHARED_FOLDER
SET win_user=USERNAME_WINDOWS

SET pi_winshare=~/winshare

SET pi1_user=pi
SET pi1_ip=192.168.1.100

SET pi2_user=pi
SET pi2_ip=192.168.1.102

SET pi3_user=pi
SET pi3_ip=192.168.1.104

REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
REM [[[[[[[[[[[[ DONT MAKE ANY CHANGES BEYOND THIS POINT ]]]]]]]]]]]]
REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]




SET pi1_ssh=%pi1_user%@%pi1_ip%
SET pi1_nicename=--UNKNOWN--
FOR /f "tokens=2" %%i IN ('nslookup %%pi1_ip%% ^| findstr /C:"Name"') DO SET pi1_nicename=%%i

SET pi2_ssh=%pi2_user%@%pi2_ip%
SET pi2_nicename=--UNKNOWN--
FOR /f "tokens=2" %%p IN ('nslookup %%pi2_ip%% ^| findstr /C:"Name"') DO SET pi2_nicename=%%p

SET pi3_ssh=%pi3_user%@%pi3_ip%
SET pi3_nicename=--UNKNOWN--
FOR /f "tokens=2" %%k IN ('nslookup %%pi3_ip%% ^| findstr /C:"Name"') DO SET pi3_nicename=%%k

CLS 

ECHO -------------------- WIN to PI to WIN . DISK to IMAGE BACKUP  ------------------------
ECHO/


ECHO/
ECHO INSTRUCTIONS
ECHO *. You must enable Windows sharing for the Destination Folder. 
ECHO *. Edit this BAT file. Change SET values to match your devices.
ECHO *. Select A device to backup
ECHO *. Check Source and Destination. If there are errors check this BAT file.
ECHO *. Enter the passwords for the Source and Destination.
ECHO *. Wait for the automated script to connect to the source. It then creates a disk image on the destination.

IF NOT EXIST %win_shared% ECHO *** STOP BROKEN PATH*** : SET win_shared=%win_shared% 

ECHO/
ECHO No.  User @ IP address    NS Lookup Name
ECHO [1]  %pi1_user%@%pi1_ip%	%pi1_nicename%
ECHO [2]  %pi2_user%@%pi2_ip%	%pi2_nicename%
ECHO [3]  %pi3_user%@%pi3_ip%	%pi3_nicename%
ECHO/

CHOICE /N /C:123 /M "Choose device to backup No.[?] "%1
ECHO/

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
ECHO =============== Backup Remote DISK to Local IMAGE file =================
ECHO | SET /p dummy = Local Machine\User = 
whoami
ECHO DISK SOURCE:       %pi_ssh%  
ECHO IMG DESTINATION:  %win_shared%/%nicefilename% 

ECHO/
REM  The following linux commands inside the Double quotes can be put into a shell script and run locally on the pi.
REM *******S the Process still running on the pi when I log off on Windows? Do I need to KILL a process? it does
REM SEE fuser command to stop bust resources.NEED CODE FOR PROCESS START AND KILL 

SET piMountBkupScript=" [ ! -d  %pi_winshare% ] && mkdir %pi_winshare% ; sudo mount.cifs %win_shared% %pi_winshare% -o user=%win_user% ; ls -l %pi_winshare% ; echo ; echo START of backup file: %nicefilename%, please wait ; sudo -S dd bs=4M if=/dev/mmcblk0 status=progress of=%pi_winshare%/%nicefilename% ; echo COMPLETED transfer ; sudo umount %pi_winshare% ;  cd ~ ; bash "

ssh -t  %pi_ssh% %piMountBkupScript%
GOTO END

:END
ECHO  Finished Backup upload.
cmd /k