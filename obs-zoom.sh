#!/bin/bash


export DISPLAY=:0

SESSIONID="$1"


      curl -s -H 'Accept-Language: de' https://www.scpoppenbuettel.de/de/online-Sportprogramm/| grep 'https://zoom' > scp-zoomsessions
      
unset sessions

readarray sessions < scp-zoomsessions

sessionsNUM="${#sessions[@]}"	# number of sessions for the day

check_pkg(){

	if dpkg-query -s "zenity" 1>/dev/null 2>&1; then
    	return 0   # package is installed
		
  	else
		echo "Package zenity is not installed"
    	exit 1;
  	fi
}

sessions_list(){
	unset arr_list
	arr_list=()
	n=0
	while [[ $n -lt ${sessionsNUM} ]]
	do
	line=""${sessions[${n}]}""
	first=${line#*headline[1-3]\"\>}
	second=${first%\</h*}
	TITLE="$second"
	URL="$(echo $line |grep -o 'https://zoom[^"]*')"
	TIME="$(echo $TITLE |grep -o '[0-9][0-9]:[0-9][0-9]')"
	FILENAME="$(echo ${TITLE} |tr ' ' '_')"
	
	#echo -e "Session ${n}: ${TITLE}"
	arr_list+=("${n}: ${TITLE}")
	((n++))
	
	if [[ $n -eq ${sessionsNUM} ]]
	then
		CHOICE="$(zenity \
		--list \
		--width=950 \
		--height=700 \
		--title="select session:" --text="Online sessions for $(date +'%A %d.%m.%Y'): " \
		--column="Session" \
		"${arr_list[@]}" \
		)"
		if [ $? != 0 ]
		then 
		zenity --warning --width=400 --height=100 --text "Recording was Canceled!"
			exit $?
		fi
		
		#printf  '%s\n' "${arr_list[@]}"
		printf  "${CHOICE}"
		break
	fi	
	done   
}

start_zoom(){
	/usr/bin/zoom --url="${URL}&pwd=Sport" &>/dev/null &
}

start_record_zoom(){

	/snap/bin/obs-studio --startrecording --profile "zoom" --portable --minimize-to-tray &>/dev/null &
}

stop_zoom(){
		/usr/bin/killall -9 obs &>/dev/null
		/usr/bin/killall -9 obs &>/dev/null
		/usr/bin/killall -9 zoom &>/dev/null
}

record_cleanup(){
	rm -f scp-zoomsessions
	cd ~/Videos/recording
	mv "$(ls -1t |head -1)" "${FILENAME}_${MINUTES}min_$(date +'%Y%m%d').mkv"
}

session_record(){
	SESSIONID=$(sessions_list)
	ID=$(echo "${SESSIONID}" |awk -F: '{print $1}')
	sessionsNUM="${#sessions[@]}"
	line=""${sessions[${ID}]}""
	first=${line#*headline[1-3]\"\>}
	second=${first%\</h*}
	TITLE="$second"
	URL="$(echo $line |grep -o 'https://zoom[^"]*')"
	TIME="$(echo $TITLE |grep -o '[0-9][0-9]:[0-9][0-9]')"
	FILENAME="$(echo ${TITLE} |tr ' ' '_')"
	ICON="scp.png"

	# start asking if want to record or just watch the session
	zenity --question --title="" --text "Do you want to record or just Watch" --ok-label="Record" --cancel-label="Watch" 
	if [ $? = 1 ]
	then 
		start_zoom
	else
	
														
	DURATION=$(zenity --title "Record Timer" --window-icon $ICON --text "No decimals"\
    --entry-text "Enter time in Minutes" --entry)           	# Input dialogue for number of minutes to record.
	if [ $? = 1 ]; then exit $?; fi   
	sleep 1
	start_zoom													# start zoom
	sleep 6
	start_record_zoom										 	# start recording
		
    MINUTES=$DURATION
    COUNT=$((DURATION*=60))										# get time in seconds
	START=$COUNT                                           	   	# Set a start point.

	until [ "$COUNT" -eq "0" ]; do                           	# Countdown loop.
		((COUNT-=1))                                         	# Decrement seconds.
		PERCENT=$((100-100*COUNT/START))                      	# Calc percentage.
		echo "#Time remaining$(echo "obase=60;$COUNT" | bc)" 	# Convert to H:M:S.
		echo $PERCENT                                         	# Outut for progbar.
		sleep 1
		
	done | zenity --title "Record Timer" --progress --percentage=0 --text=""\
		--window-icon=$ICON --auto-close                      	# Progbar/time left.

	if [ $? = 1 ]
		then 
		echo "Record Time Finished"
		stop_zoom											  	# calling stop_zoom function to kill zoom
		sleep 2
		record_cleanup										  	# clean up the mess and rename the file
		exit $?
	fi
	
		echo "Record Canceld"
		stop_zoom												# Stop Zoom
		sleep 2
		record_cleanup											# clean up the mess and rename the file
		
	#	notify-send -i $ICON "Record Timer > ## TIMES UP ##"  	# Attention finish!
		
		zenity --notification --window-icon="$ICON"\
		--text "Record Timer > ## TIMES UP ##"               	# Indicate finished!

	fi															# finish check if record or watch
	
}

#sessions_list "${sessions}"



session_record #"${sessions}"