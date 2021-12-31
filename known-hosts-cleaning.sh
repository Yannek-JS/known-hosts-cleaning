#! /bin/bash

###################################################
# This script lets you do some cleaning within
# the entries in your SSH known_host file
#
# The script works in your Linux user context
###################################################


scriptPath=$(dirname $(realpath $0))    # full path to the directory where the script is located
backupDone=false   # controls whether known_hosts file has been backed up
knownHostsFile=$(dirname ~/.ssh/known_hosts)'/known_hosts'  # full path of user's SSH known_hosts file


###################################################
# This script uses Yannek-JS Bash library; 
# it checks whether this library (bash-scripts-lib.sh) is present; 
# if not, the script is quitted.
# You can download this library from https://github.com/Yannek-JS/bash-scripts-lib
###################################################
if [ -f $scriptPath/bash-scripts-lib.sh ]
then
    source $scriptPath/bash-scripts-lib.sh
else
    echo -e "\n Critical !!! 'bash-script-lib.sh' is missing. Download it from 'https://github.com/Yannek-JS/bash-scripts-lib' into directory where this script is located.\n"
    exit
fi
###################################################


function make_backup() {
# makes copy of user's known_hosts file using a time stamp in backup filename
    backupFile=$knownHostsFile'_'$(date +%F_%T | sed 's/:/-/g')
    cp $knownHostsFile $backupFile    # makes known_hosts backup file
    if [ $? -eq 0 ] && [ -f $backupFile ]
    then
        echo -e ${BLUE}'\nBackup of known_host file has been done into '${LGREEN}$backupFile${SC}' file.\n'
        backupDone=true
    else
        echo -e ${LRED}'\nBackup of '$knownHostsFile' could not be done. Check the reason of that. Quitting the script now...'${SC}
        exit
    fi
}


function remove_containing() {
# Removes the entries containing the string specified by user.
# This string must be found in the first segment (block, column) of the entry;
# then, the string is related to the host or domain name;
# If the function is called with IP argument, then the function removes the entries starting with IP address.
    # checks Bash version whether it is at last 4.2 that is needed to use 'shopt -s lastpipe' command
    if [ $(echo $BASH_VERSION | gawk --field-separator '.' '{print $1}') -ge 4 ] && [ $(echo $BASH_VERSION | gawk --field-separator '.' '{print $2}') -ge 2 ]
    then bashVerOK=true
    else bashVerOK=false
    fi
    isIn=false
    strToFind=''
    entriesFound=0
    while [ "$(echo $strToFind | sed 's/ //g')" != '' ] || ! $isIn
    do
        isIn=true
        if [ "$1" == 'IP' ]
        # if the funciton is called with IP argument, then regular expression matching IP addresses is set up; otherwise, user enters a pattern 
        then 
            strToFind='^[1-9][0-9]{0,2}(\.[0-9]{1,3}){3}'
        else 
            read  -i "$strToFind" -p 'Enter string or regular expression to match entry in known_hosts file. Press Enter to get back to main menu: ' strToFind 
        fi
        if [ "$strToFind" == ',' ]
        then
            echo -e ${LRED}'\n A single comma sign is not allowed.\n'${SC}
        elif [ "$strToFind" != '' ]
        then
            if [ "$1" == 'IP' ]
            then
                echo -e ${BLUE}'\nRemoving the entries starting with IP address ...'${SC}
            else
                echo -e ${BLUE}'\nRemoving the entries matching following pattern: '${ORANGE}$strToFind${BLUE}' ...'${SC}
            fi
            if $bashVerOK; then shopt -s lastpipe; fi   # checks whether Bash ver. >= 4.2 to run shopt -s lastpipe (to get $entriesFound evaluated in pipeline) 
            cat $knownHostsFile | while read line
                                        do
                                            # checks whether seeking string is included whithin the first segment
                                            # echo 'str to find: '$strToFind    # debugging
                                            # echo 'grep result: '$(echo $line | gawk '{print $1}' | grep --regexp "$strToFind")    # debugging
                                            if $(echo $line | gawk '{print $1}' | grep --quiet --extended-regexp "$strToFind" 2>/dev/null)
                                            # errors are redirected to /dev/null to avoid grep errors in case of wrong regular expression
                                            then
                                                # checks whether there are more than one host related info in the entry
                                                # a comma indicates that they are there
                                                if $(echo $line | gawk '{print $1}' | grep --quiet --regexp ',')
                                                then
                                                    entry=$(echo $line | gawk --field-separator ',' '{print $1}')
                                                else
                                                    entry=$(echo $line | gawk '{print $1}')
                                                fi
                                                if ! $backupDone; then make_backup; fi
                                                ssh-keygen -R $entry -f $knownHostsFile
                                                # echo 'entry = '$entry    # debugging
                                                (( entriesFound++ ))
                                                echo
                                                # echo 'entries found: '$entriesFound   # debugging
                                            fi
                                        done
            strToFind=''
            if $bashVerOK   # if Bash ver. is >= 4.2 then the value of $entriesFound can be retrieved correctly thank to shopt -s lastpipe command
            then
                if [ $entriesFound -gt 0 ] 
                then echo -e ${BLUE}'Number of entries matched the pattern: '${ORANGE}$entriesFound${SC}
                else echo -e ${ORANGE}'\nThere was no entry that matched the pattern.'${SC}
                fi
            fi
            press_any_key
        fi
    done
}


while [ -f $knownHostsFile ]
do
    backupDone=false
    clear
    echo -e ${BLUE}'\n\n Choose the action related to your '${ORANGE}$knownHostsFile${BLUE}' file.\n'${SC}
    select action in 'Display your known_hosts file' 'Remove all entries being just IP address' 'Remove all entries containing string or RegExp provided' 'Exit the script'
    do
        case $REPLY in
            1 ) echo -e ${BLUE}'\n Here is your '${ORANGE}$knownHostsFile${BLUE}' content: \n'${SC}; cat $knownHostsFile; press_any_key; break;;
            2 ) remove_containing IP; break;;
            3 ) remove_containing; break;;
            4 ) quit_now;;
            * ) clear; echo -e ${ORANGE}'\n\n Choose a correct option (number), pls.'${SC}; sleep 2; break;;
        esac
    done
done

echo -e '\n\n'${ORANGE}$knownHostsFile${LRED}' file does not exist. Quitting the script...\n'${SC} 

