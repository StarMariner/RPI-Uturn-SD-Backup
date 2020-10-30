# RPI-Uturn-SD-Backup
Local Windows BAT. SSH to RPI , Back up to Remote Windows Shared Folder. Hence U turn or yoyo if you like.

From Windows Copy a RaspberryPi disk ,creates the output image file on the same Windows Machine.
From windows, sends and executes a script on a remote Raspberry PI via SSH to perform a disk copy, the output is an image file created on a Windows shared folder . 

For disk recovery, you should be able to etch the image file to an SD , use the Pi Imager or similar.

You will only need to make changes to some SET variables before using this BAT file. I would suggest notepad++ , but I developed it in Notepad.
Right click the bat file "open with" > notepad. 

REMarks at the begining of the BAT file may look mis-leading, it's just babble for now. A way of me jotting down thoughts, references to external sources etc..

If you want to strip my code apart, great. I suggest you start with the code after the :BKUP_SCRIPT label. Observe the variables between the % , pi_winshare  is the name of the directory /mount point on the Raspberry pi. the Win_shared is the \\machine\sharedfolder on Window. Win_user is the Windows login name. You can change nicename, to whatever you want to call your backup. 

There isn't much logical conditioning , mostly I set it then have it change. It was just became less human readble. The idea was to make it usable by anyone. Regular expressions just arent for us mortal coders.

As with most Raspberry pi things, it takes time to work anything out, hopefully this will help...   THHHRRRR , thats a raspberry.
