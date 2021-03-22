# obs-zoom
Start Zoom Session Recording with GUI Interface 

This plugin is meant to do only one task which is start recording online sport sessions provided by a specific sport club site. but might be extended to other online sport sites if needed. 
the sportclup are providing online training through zoom, therefore they have an updated page for everyday the provides information about zoom sessions with title and time when it starts. 
i use curl to get the page from their website, and bash tools to grep and extract zoom url, and session title which i use to start zoom from command line, then i start obs-studio with specific scene which configured to record window application of zoom. 
when it is done i kill all processes and rename the recorded file to the name of the session mentioned on the website. 
that was all running from terminal,
then i upgraded the script to use zenity to give it a GUI interface where my wife can start it and select the session without having to enter the terminal. 

Tools Recuired for this

0. before all i used bash4 here as some commands are not available on shell like readarray
1. Zoom Meeting installed 
2. obs-studio installed 
3. curl installed
4. zenity for GUI Interface with bash
5. scene configuration for application windows on obs to fit zoom screen. 
6. last but not least linux system. i used Zorin OS, here but you can use your own fav flavour. 

Process
1. call script from command or simply use install.sh to install the scrip as app, and call it from the menue 
2. select session from the list "by ok or double click"
3. choose if you want to watch only or watch and record
4. Enter number of minutes to record. 
5. if you want to interrupt the recording before minutes are finished click cancel on the Time window. 


