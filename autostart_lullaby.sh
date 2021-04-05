#!/bin/bash
## This script starts the mplayer to play my lullaby songs. Every 
## evening the player should stop after 3 to 5 songs, save the last played song, then stop the raspi. 
## Per default this script starts the next song after the previous saved checkpoint. Include the script to the crontab file, to start on boot.

#env for usage from command line
export XDG_RUNTIME_DIR="/run/user/1000"
export DISPLAY=:0.0

# directories for logfiles, storage medium and media folder to play (DIR and MEDIA is separate here, but is added together to form the full path below)
export LOGDIR="/home/pi/Documents/logs" 
export DIR="/media/pi/MYUSB"
export MEDIA="/songs/lullaby_songs/"

#get input media to play (default is lullaby_songs)
# usage in shell session: ./autostart_lullaby.sh "/songs/my favorite band"
#export MEDIA="$@"
export DIR="${DIR}${MEDIA}"

export CHECKPOINT_OLD=""
export COUNTER=0
export STOP_COUNTER=""
export START_COUNTER=""

# if the folder names have spaces, exchange them for "_" in logfile name
export MEDIA_SED=$(echo $MEDIA | sed "s/\//\_/g" | sed "s/\ //g")
export LOGFILE="autostart$MEDIA_SED.log"

echo "################# $(date): Start autostart_lullaby.sh ############" >> ${LOGDIR}/${LOGFILE}

export CONTENT=$(ls -1 "${DIR}")

if [ ! -f ${LOGDIR}/CHECKPOINT_OLD_${MEDIA_SED} ]; then 
        
        echo "$CONTENT" | head -1 > ${LOGDIR}/CHECKPOINT_OLD_${MEDIA_SED}	
        echo "First Checkpoint set to first item in folder" > ${LOGDIR}/${LOGFILE}	

fi

CHECKPOINT_OLD="$(cat ${LOGDIR}/CHECKPOINT_OLD_${MEDIA_SED})"
echo "old checkpoint read with: $CHECKPOINT_OLD" >> ${LOGDIR}/${LOGFILE}

while read -r FILE; do

      COUNTER=$(($COUNTER + 1))
      
      # if the loop reaches the old checkpoint, calculate the new start and stop
      if [[ "${FILE}" == "${CHECKPOINT_OLD}" ]]; then
			
     
              export START_COUNTER=$COUNTER
	      # the number of played songs should be between 3 and 5
	      export RAND=$(( $RANDOM %2 + 3))
	      export STOP_COUNTER=$(($COUNTER + $RAND))

	      # test if the stop counter episode exists, if so save in CHECKPOINT_OLD
        
	      CHECKPOINT_NEW=$(echo "${CONTENT}" | head -$STOP_COUNTER | tail -n 1)
	      PLAYLIST=$(echo "$CONTENT" | head -$STOP_COUNTER | tail -n $RAND| while read line; do echo ${DIR}${line}; done) 
	      echo "$PLAYLIST" > ${LOGDIR}/playlist.txt
	    
	      if [[ ${CHECKPOINT_NEW} == $(echo "${CONTENT}" | tail -n 1) ]]; then
	    
	            echo "no following episode found, begin again from top" >> ${LOGDIR}/${LOGFILE}
                    echo "${CONTENT}" | head -1 > $LOGDIR/CHECKPOINT_OLD_${MEDIA_SED}
              else
             
                    echo "following episode found, save in CHECKPOINT_OLD" >> ${LOGDIR}/${LOGFILE}
	            echo "${CHECKPOINT_NEW}" > $LOGDIR/CHECKPOINT_OLD_${MEDIA_SED}
	      fi
      
      break

      fi
      
done <<< "${CONTENT}"

#echo -e "the playlist for tonight is:\n$PLAYLIST"

mplayer -ao alsa -playlist ${LOGDIR}/playlist.txt > /dev/null 2>&1

#empty the playlist for the next run
> ${LOGDIR}/playlist.txt

# if the playlist does not contain any songs (e.g. wrong dir selected) the pi will not shut down instantly, but after 2 minutes so I can comment the crontab setting to run this script if neccessary.
sleep 120

/sbin/shutdown -h now


