#!/bin/bash


export DISPLAY=:0

SESSIONID="$1"


      curl -s -H 'Accept-Language: de' https://www.scpoppenbuettel.de/de/online-Sportprogramm/| grep 'https://zoom' > scp-zoomsessions
      
unset sessions

readarray sessions < scp-zoomsessions

sessionsNUM="${#sessions[@]}"	# number of sessions for the day

session_details(){
	line="$1"
	first=${line#*headline[1-3]\"\>}
	second=${first%\</h*}
	TITLE="$second"
	URL="$(echo $line |grep -o 'https://zoom[^"]*')"
	TIME="$(echo $TITLE |grep -o '[0-9][0-9]:[0-9][0-9]')"
	FILENAME="$(echo ${TITLE} |tr ' ' '_')"
	
	echo "Start Time: ${TIME}"
	echo "Session Name ${TITLE}"
    echo "Session Link ${URL}"
   
    #echo ${FILENAME}
}

#session_details "${sessions[${SESSIONID}]}"

	
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


session_record(){
	SESSIONID=$(sessions_list)
	#echo -e "  "
	#read -p "Enter Session ID to record: " ID
	ID=$(echo "${SESSIONID}" |awk -F: '{print $1}')
	sessionsNUM="${#sessions[@]}"
	line=""${sessions[${ID}]}""
	first=${line#*headline[1-3]\"\>}
	second=${first%\</h*}
	TITLE="$second"
	URL="$(echo $line |grep -o 'https://zoom[^"]*')"
	TIME="$(echo $TITLE |grep -o '[0-9][0-9]:[0-9][0-9]')"
	FILENAME="$(echo ${TITLE} |tr ' ' '_')"
	
	#DURATION=$(zenity --entry --title "Recording Time" --text "How many minutes do you want to record:")
	
    #echo -e "Start Recording ${TITLE} "
    #echo -e "${SESSIONID}"
    #echo -e "${URL}"
    #echo -e "$FILENAME"
	DURATION=$(zenity --title "Record Timer" --window-icon $ICON --text "No decimals"\
    --entry-text "Enter time in Minutes" --entry)           # Input dialogue.
	if [ $? = 1 ]; then exit $?; fi   


	/usr/bin/zoom --url="${URL}&pwd=Sport" &>/dev/null &
	sleep 6
	/snap/bin/obs-studio --startrecording --profile "zoom" --portable --minimize-to-tray &>/dev/null &
	#sleep ${DURATION}m
		
    MINUTES=$DURATION
    COUNT=$((DURATION*=60))									  # get time in seconds
	START=$COUNT                                              # Set a start point.

	until [ "$COUNT" -eq "0" ]; do                            # Countdown loop.
		((COUNT-=1))                                          # Decrement seconds.
		PERCENT=$((100-100*COUNT/START))                      # Calc percentage.
		echo "#Time remaining$(echo "obase=60;$COUNT" | bc)"  # Convert to H:M:S.
		echo $PERCENT                                         # Outut for progbar.
		sleep 1
		
	done | zenity --title "Record Timer" --progress --percentage=0 --text=""\
		--window-icon=$ICON --auto-close                      # Progbar/time left.

	if [ $? = 1 ]
		then 
		echo "Record Time Finished"
		/usr/bin/killall -9 obs &>/dev/null
		/usr/bin/killall -9 obs &>/dev/null
		/usr/bin/killall -9 zoom &>/dev/null
		sleep 2
		rm -f scp-zoomsessions
		cd ~/Videos/recording
		mv "$(ls -1t |head -1)" "${FILENAME}_$(date +'%Y%m%d').mkv"
		
		exit $?
	fi
	
		echo "Record Canceld"
		/usr/bin/killall -9 obs &>/dev/null
		/usr/bin/killall -9 obs &>/dev/null
		/usr/bin/killall -9 zoom &>/dev/null
		sleep 2
		rm -f scp-zoomsessions
		cd ~/Videos/recording
		mv "$(ls -1t |head -1)" "${FILENAME}_${MINUTES}min_$(date +'%Y%m%d').mkv"
		
	#	notify-send -i $ICON "Record Timer > ## TIMES UP ##"      # Attention finish!
		
		zenity --notification --window-icon="$ICON"\
		--text "Record Timer > ## TIMES UP ##"                   # Indicate finished!


	
}

#sessions_list "${sessions}"
obs
session_record #"${sessions}"
