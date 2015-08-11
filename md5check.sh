#!/bin/bash

#############################################
#           MD5 File Checker v2.0           #
#                                           #
# Authors: Nathan R. Wray (m4dh4tt3r)       #
#          Justin M. Wray (SynisterSyntax)  #
#                                           #
#             Date: 03.03.2014              #
#############################################

# Check if .md5sum.db exists
if [ ! -f "./.md5sum.db" ]
then
  touch ./.md5sum.db
fi

# Check if md5check.files exists
if [ ! -f "./md5check.files" ]
then
  touch ./md5check.files
  echo "/etc/passwd" >> ./md5check.files
fi

# Path to File where the hashes will be stored 
fileDb=${2:-"./.md5sum.db"}

# List files to be watched here (e.g. - /etc/passwd)
IFS=$'\n' fileArray=($(find $(cat ./md5check.files) -not -path "/dev/*" -not -path "/proc/*" -not -path "/run/*"))
IFS=$'\n' fileDbArray=($(cat $fileDb | awk {' print $2 '}))

# Gets the length of the array for us
filesLength=${#fileArray[@]}
fileDbLength=${#fileDbArray[@]}

generate() {
    fileOut=$1

    if [[ -f "${fileOut}" ]]
    then 
      chattr -i "${fileOut}"
    fi

    echo -n > $fileOut

    # Check if the Hash File exists, if not create it
    # Then make the file immutable
    for (( i=0; i<${filesLength}; i++));
    do
       getMD5=$(md5sum ${fileArray[$i]} >> $fileOut 2>/dev/null)
    done

    chattr +i $fileOut
}

check() { 
    # Compares the values in the Hash File to the current values
    # If the values match, then everything is correct.
    # If the values do not match, then throw an alert.
    all=$1
    verbose=$2

    echo "Calculating Changes...Please Wait..." 1>&2
    generate "/tmp/md5check.tmp"

    if [[ $verbose == true ]]
    then
      diff -y --speed-large-files --left-column $fileDb /tmp/md5check.tmp | awk {' if ($3 == "|") print $2 " has been modified (Old: " $1 " | New: " $4 ")"; if ($3 == "(") print $2 " has not been modified (Current: " $1 ")" '}
    else
      if [[ $all = true ]]
      then
        diff -y --speed-large-files --left-column $fileDb /tmp/md5check.tmp | awk {' if ($3 == "|") print $2 " has been modified"; if ($3 == "(") print $2 " has not been modified" '}			
      else
        diff -y --suppress-common-lines --speed-large-files $fileDb /tmp/md5check.tmp | awk {' print $2 " has been modified" '}
      fi
    fi

    chattr -i "/tmp/md5check.tmp"
    rm "/tmp/md5check.tmp"
}

case $1 in 
    generate)
	generate $fileDb
    ;;
    show-changed)
	check false false
    ;;
    show-all)
	check true false
    ;;
    show-verbose)
	check true true
    ;;
    *)
	echo "Usage: $0 {generate | show-changed | show-all | show-verbose }"
    ;;
esac
