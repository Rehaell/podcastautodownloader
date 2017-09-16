#!/bin/bash
#user variables
#PODCAST DOWNLOAD FOLDER - NO SLASH
DOWNLOAD_FOLDER=changme
#PODCAST OUTPUT FOLDER - NO SLASH
OUTPUT_FOLDER=changeme
#TIME SPLIT MM.S
SPLIT=30.0
#PUSHOVER INFO
TOKEN_KEY=changeme
USER_KEY=changeme


if [ `gpo update | sed -En 's/^([[:digit:]+]) new episodes?$/\1/p'` -eq 0 ]
then
  echo "No new podcasts, exiting..."
  curl -s --form-string "token=$TOKEN_KEY" --form-string "user=$USER_KEY" --form-string "message=No new podcasts found" https://api.pushover.net/1/messages.json
  exit 0

  else
    message=`gpo pending | sed -En '/^[[:space:]].*/p'`
    curl -s --form-string "token=$TOKEN_KEY" --form-string "user=$USER_KEY" --form-string "message=New podcasts going to be grabbed: $message" https://api.pushover.net/1/messages.json

    gpo download

    #formatting whitespace directories to use in FOR - DON'T REMOVE
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    for i in $DOWNLOAD_FOLDER/* ; do
     for j in $i/*.mp3; do
       mp3splt -t $SPLIT -d $OUTPUT_FOLDER/$(basename "$i")/ -m $(basename "$i").m3u $j
       echo `rm "$j"`
     done
    done

   IFS=$SAVEIFS
fi
