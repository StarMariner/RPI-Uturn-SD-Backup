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
setlocal enabledelayedexpansion 



REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
REM [[[[[[[[[[[[[ CHANGE SET VALUES TO MATCH YOUR DEVICES ]]]]]]]]]]]
REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]

REM Replace windows shared folder name below to match yours. Manually remove any leftside characters before //. eg. SET win_shared=//machine/shared_folder
SET win_shared=//ExampleMachineName/Shared_Folder
SET win_user=ExampleUser
REM mountpoint on pi 
SET pi_winshare=~/winshare

REM Add as many Pis as you like , but make sure LastPi=x value is the last UserPI[x] and last ipPI[x]
SET UserPI[1]=pi
SET ipPI[1]=192.168.1.24

SET UserPI[2]=pi
SET ipPI[2]=192.168.1.110

SET UserPI[3]=pi
SET ipPI[3]=192.168.1.112

SET LastPI=3

REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
REM [[[[[[[[[[[[ DONT MAKE ANY CHANGES BEYOND THIS POINT ]]]]]]]]]]]]
REM [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]




CLS 

ECHO -------------------- WIN to PI to WIN . DISK to IMAGE BACKUP  ------------------------
ECHO/
ECHO INSTRUCTIONS
ECHO *. You must enable Windows sharing for the Destination Folder. 
ECHO *. Edit this BAT file. Change SET values to match your devices.
ECHO *. Select a device [x] to backup
ECHO *. Check Source and Destination. If there are errors check this BAT file.
ECHO *. Enter the passwords for the Source and Destination.
ECHO *. Wait for the automated script to connect to the source. It then creates a disk image on the destination.
ECHO    To quit Type Ctrl+C or Ctrl+break  
IF NOT EXIST %win_shared% ECHO *** STOP. =FIX THIS BROKEN PATH  *** SET win_shared=%win_shared% 

ECHO/
ECHO No.  User @ IP address    NS Lookup Name
for /l %%n in (1,1,%LastPi%) do ( 
			SET sshPI[%%n]=!UserPI[%%n]!@!ipPI[%%n]!
			SET NiceNamePI[%%n]=Not_Available
			FOR /f "tokens=2" %%i IN ('nslookup !ipPI[%%n]! 2^>nul ^| findstr /C:"Name"') DO SET NiceNamePI[%%n]=%%i
			ECHO [%%n]  !sshPI[%%n]!    !NiceNamePI[%%n]!
			)
ECHO/


:PickPi
SET /P GetInput= Choose a device number [?] to backup.  
IF %GetInput% LEQ 0 GOTO BEGIN
IF %GetInput% LEQ %LastPi% GOTO BKUP_SCRIPT
IF %GetInput% GTR %LastPi% GOTO BEGIN
GOTO END


:BKUP_SCRIPT
IF !NiceNamePI[%getInput%]!==Not_Available ( ECHO That Device is NOT AVAILABLE choose another.
  				          GOTO PickPi )											  
SET sshPI[%getInput%]=!UserPI[%getInput%]!@!ipPI[%getInput%]!
SET nicefilename=!NiceNamePI[%GetInput%]!.img

ECHO/
ECHO =============== Backup Remote DISK to Local IMAGE file =================
ECHO | SET /p dummy = Local Machine\User = 
whoami
ECHO DISK SOURCE:      !sshPI[%getInput%]!  
ECHO IMG DESTINATION:  %win_shared%/%nicefilename% 

ECHO/
REM  The following linux commands inside the Double quotes can be put into a shell script and run locally on the pi.
REM *******S the Process still running on the pi when I log off on Windows? Do I need to KILL a process? it does
REM SEE fuser command to stop bust resources.NEED CODE FOR PROCESS START AND KILL 

SET piMountBkupScript=" [ ! -d  %pi_winshare% ] && mkdir %pi_winshare% ; sudo mount.cifs %win_shared% %pi_winshare% -o user=%win_user% ; ls -l %pi_winshare% ; echo ; echo START of backup file: %nicefilename%, please wait ; sudo -S dd bs=4M if=/dev/mmcblk0 status=progress of=%pi_winshare%/%nicefilename% ; echo COMPLETED transfer ; sudo umount %pi_winshare% ;  cd ~ ; bash "

ssh -t !sshPI[%getInput%]!  %piMountBkupScript%


GOTO BEGIN

:END
ECHO  Finished .
cmd /k