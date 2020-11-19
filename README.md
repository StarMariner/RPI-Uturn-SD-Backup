# RPI-Uturn-SD-Backup
Please read carefully, this is not 100% fully working, there are some manually required interventions.

Local Windows BAT. SSH to RPI , Back up to Remote Windows Shared Folder. Hence U turn or yoyo if you like.

From Windows, Copy a RaspberryPi disk ,creates the output image file on the same Windows Machine or another computer.

From windows, sends and executes a BASH script on a remote Raspberry PI via SSH to perform a disk copy.
The script makes a directory on the raspberrypi then mounts it , pointing to the remote Windows shared folder. 
** WARNING ** 
If the Windows machine credentials for the shared folder are not correct, you will backup to raspberry pi disk, thats not what we want.
You should be prompted for the windows user password then a list of whats in the Windows Shared folder, that way you know your backing up to Windows.

The output is an image file created on a Windows shared folder.Make sure you have enough space for the full size of raspberry pi disk. 
Don't close the Windows Terminal Window during backup or you'll loose the connection.

For disk recovery, you should be able to etch the image file to an SD , use the Pi Imager or similar.

You will only need to make changes to some SET variables before using this BAT file. I would suggest notepad++ , but I developed it in Notepad.
Right click the bat file "open with" > notepad. 

REMarks at the begining of the BAT file may look mis-leading, it's just babble for now. A way of me jotting down thoughts, references to external sources etc..

If you want to strip my code apart, great. I suggest you start with the code after the :BKUP_SCRIPT label. Observe the variables between the % , pi_winshare  is the name of the directory /mount point on the Raspberry pi. the Win_shared is the \\machine\sharedfolder on Window. Win_user is the Windows login name. You can change nicename, to whatever you want to call your backup. You can use this part of code in a BASH script if you wanted.

There isn't much logical conditioning , mostly I set it then have it change. It started to become less human readble. The idea was to make it usable by anyone. Regular expressions just arent for us mortal coders, but some tricks are in the code that don't look obvious at first glance.

As with most Raspberry pi things, it takes time to work anything out, hopefully this will help...   THHHRRRR , thats a raspberry.
