#!/usr/bin/env bash


function show_usage {
   echo " Invalid number of argument "
   echo " Usage: $(basename $0) <Host> <AutomatonID> <User> respectively "
   exit 1
}

#  Test for user input validation.

function _argument_check {

SSH_USER=" "
SSH_HOST=" "
AUTOMATON_ID=" "

   if [[ "$1" =~ [a-zA-Z0-9.-]* ]] # need test for different string input ie: ...localhost, --localhost etc..
        then
            SSH_HOST="$1"
        else
            echo " Invalid argument passed for remote host "
            exit 1
   fi

   if [[ "$2" =~ ^[0-9]+$ ]] # regex validates for only positive integer
        then
            AUTOMATON_ID="$2"
        else
            echo " Invalid Argument passed for AutomatonID "
            exit 1
   fi

   if [[ "$3" == ${USER} ]]
        then
            SSH_USER="$3"
        else
            echo " Invalid Argument passed for current user "
            exit 1
   fi

 }

# Main Program Starts Here

if [[ $# -le 2 ]] # if user enter less than 3 arguments exit with below echo message.
  then
    show_usage
elif [[ $# -ge 4 ]] # if user enter more than 3/required argument exit with usage.
  then
    show_usage
else
    _argument_check "$1" "$2" "$3"

    ssh ${SSH_USER}@${SSH_HOST} 'nc -z localhost 2222 &> /dev/null' ||
    { echo " No running Shell on specified host!! Exiting.. " && exit 1; } &&

    echo " Existing running Shell found!! Proceeding.. "
    sleep 3
    # Getting Automaton and capturing shell output into below txt file
    ssh -p 2222 ${SSH_USER}@${SSH_HOST} 'exportAutomatonByID("'${AUTOMATON_ID}'");' > IpAdminShell.log
    # Transferring Automaton into User home dir.
    echo " Retrieving Automaton..One Moment! "
    sleep 3

    rsync -v ${SSH_USER}@${SSH_HOST}:/home/ipcenter/.ipcenter_shell/${SSH_USER}/${AUTOMATON_ID}* ~ > rsync.log`date +%F`
    cat rsync.log*
fi
