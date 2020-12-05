#!/bin/bash
# Fetch the current truenas release for the iocage jails and Upgrade your jails to the current truenas release
# git clone https://github.com/NasKar2/truenas-upgrade-jails

print_msg () {
  echo -e "\e[1;32m"$1"\e[0m"
  echo
}

print_err () {
  echo -e "\e[1;31m"$1"\e[0m"
  echo
}

# Initialize Variables
#
SKIP_JAILS="duplicati urbackup"

# Check if upgrade-config exists and read the file
if [ -e "upgrade-config" ]; then 
  SCRIPT=$(readlink -f "$0")
  SCRIPTPATH=$(dirname "$SCRIPT")
  . $SCRIPTPATH/upgrade-config
  print_msg "upgrade-config exists will read it"
else
  print_msg "upgrade-config does not exist will use defaults"
fi

RELEASE=$(freebsd-version | cut -d - -f -1)"-RELEASE"

#
# Check if upgrade-config created correctly
#

if [ -z $POOL_PATH ]; then
  POOL_PATH="/mnt/$(iocage get -p)"
  print_msg "POOL_PATH is defaulting to ${POOL_PATH}"                                                                
fi

#
# Fetch
#
CURRENT_RELEASE=$(ls -Art /mnt/v1/iocage/releases | tail -n 1)
print_msg $CURRENT_RELEASE
if [[ $# = 0 ]]; then
   if ! [ $CURRENT_RELEASE = $RELEASE ]; then
     iocage fetch -r $RELEASE
     print_msg "fetch release"
   else
     print_msg "do not fetch release"
   fi
elif ! [[ $# = 0 ]] && ! [ $1 = "test" ]; then
   print_err "argument passed only test is a valid argument"
   exit 1
else
   print_msg "Run in test mode"
fi

#
# Upgrade all jails
#
echo
delete=(${SKIP_JAILS})
cd ${POOL_PATH}/iocage/jails
shopt -s dotglob
shopt -s nullglob
#array=($(ls -d ${POOL_PATH}/iocage/jails/* | cut -d '/' -f 6))
array=($(ls -A ${POOL_PATH}/iocage/jails))
#for jail in "${array[@]}"; do
#print_msg "$jail"
#done
for target in "${delete[@]}"; do
  for i in "${!array[@]}"; do
    if [[ ${array[i]} = $target ]]; then
      unset 'array[i]'
    fi
  done
done
echo "*******************"
for jail in "${array[@]}"; do
CURRENT_RELEASE=$(iocage get release ${jail} | cut -d - -f -1)"-RELEASE"
 if [  "$CURRENT_RELEASE" = "$RELEASE" ]; then
   print_err "The ${jail} is already upgraded to the current release ${RELEASE}" 
 else
  if [ $(iocage get -s ${jail} ) = "down" ]; then                   
     print_err "The jail named ${jail} is down please start it if you want to upgrade it"
  elif [ $(iocage get -s ${jail} ) = "up" ]; then  
     print_msg "Will upgrade ${jail} from ${CURRENT_RELEASE} to ${RELEASE}"
        if ! [ $1 = "test" ]; then
          iocage upgrade -r $RELEASE $jail
          iocage exec $jail "pkg-static upgrade -f -y"
          iocage restart $jail
        fi 
  fi
 fi
done
exit

