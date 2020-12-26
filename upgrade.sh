#!/bin/bash
# Fetch the current truenas release for the iocage jails and Upgrade your jails to the current truenas release or Update && Upgrade your jails
# git clone https://github.com/NasKar2/truenas-upgrade-jails
  
print_msg () {
  echo -e "\e[1;32m"$1"\e[0m"
  echo
}

print_err () {
  echo -e "\e[1;31m"$1"\e[0m"
  echo
}

print_y () {
  echo -e "\e[1;33m"$1"\e[0m"
  echo
}

print_c () {
  echo -e "\e[1;36m"$1"\e[0m"
  echo
}

# Initialize Variables
#
SKIP_JAILS="duplicati urbackup"

# Check if upgrade-config exists and read the file
  SCRIPT=$(readlink -f "$0")
  SCRIPTPATH=$(dirname "$SCRIPT")
if [ -e "${SCRIPTPATH}/upgrade-config" ]; then
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

# Create array for jails

echo
delete=(${SKIP_JAILS})
cd ${POOL_PATH}/iocage/jails
shopt -s dotglob
shopt -s nullglob
array=($(ls -A ${POOL_PATH}/iocage/jails))
for target in "${delete[@]}"; do
  for i in "${!array[@]}"; do
    if [[ ${array[i]} = $target ]]; then
      unset 'array[i]'
    fi
  done
done                                                                                 
echo "*******************"


# Bash Menu

PS3='Please enter your choice: '
options=("Upgrade Jail Release" "Update && Upgrade" "Test Release Upgrade" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Upgrade Jail Release")
            echo "you chose choice $REPLY which is $opt"
            break
          # echo "you chose choice 1"
            ;;
        "Update && Upgrade")
            echo "you chose choice $REPLY which is $opt"
            break
          # echo "you chose choice 2"
            ;;
        "Test Release Upgrade")
            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
#print_msg "$opt"
if [ "$opt" = "Upgrade Jail Release" ];then
   print_msg "Upgrade Jail Release"
   # Fetch
   #
   CURRENT_RELEASE=$(ls -Ar /mnt/v1/iocage/releases | head -n 1)
   print_y "The most recent release available is ${CURRENT_RELEASE}"
      if ! [ $CURRENT_RELEASE = $RELEASE ]; then
        print_msg "Fetching release ${RELEASE}"
        iocage fetch -r $RELEASE

      else
        print_y "Release ${CURRENT_RELEASE} already exists"
      fi
  for jail in "${array[@]}"; do
      #echo "execute $opt"
      CURRENT_RELEASE=$(iocage get release ${jail} | cut -d - -f -1)"-RELEASE"
    if [  "$CURRENT_RELEASE" = "$RELEASE" ]; then
      print_y "The ${jail} is already upgraded to the current release ${RELEASE}"
    else
      if [ $(iocage get -s ${jail} ) = "down" ]; then
        print_err "The jail named ${jail} is down please start it if you want to upgrade it"
      elif [ $(iocage get -s ${jail} ) = "up" ]; then
        print_msg "Will upgrade ${jail} from ${CURRENT_RELEASE} to ${RELEASE}"
        iocage upgrade -r $RELEASE $jail
        iocage restart $jail
        iocage exec $jail "pkg-static install -f -y pkg" # fix shared object 'libarchive.so.6' not found, required by 'pkg'
        iocage exec $jail "pkg-static upgrade -f -y"
        iocage restart $jail
      fi
    fi
  done

elif [ "$opt" = "Update && Upgrade" ];then
      print_msg "Update && Upgrade"
  for jail in "${array[@]}"; do
      print_y "execute $opt for $jail"
      iocage exec $jail "pkg update && pkg upgrade -y"
  done
elif [ "$opt" = "Test Release Upgrade" ];then
      print_c "Test Release Upgrade"
      # Fetch
      #
      CURRENT_RELEASE=$(ls -Ar /mnt/v1/iocage/releases | head -n 1)
      print_c "The most recent release available is ${CURRENT_RELEASE}"
      if ! [ $CURRENT_RELEASE = $RELEASE ]; then
        print_c "Fetching release ${RELEASE}"
        echo "iocage fetch -r $RELEASE"

      else
        print_c "Release ${CURRENT_RELEASE} already exists"
      fi
   for jail in "${array[@]}"; do
      CURRENT_RELEASE=$(iocage get release ${jail} | cut -d - -f -1)"-RELEASE"
      if [  "$CURRENT_RELEASE" = "$RELEASE" ]; then
        print_c "The ${jail} is already upgraded to the current release ${RELEASE}" 
      else
        if [ $(iocage get -s ${jail} ) = "down" ]; then                   
           print_err "The jail named ${jail} is down please start it if you want to upgrade it"
        elif [ $(iocage get -s ${jail} ) = "up" ]; then  
           print_c "Will upgrade ${jail} from ${CURRENT_RELEASE} to ${RELEASE}"
          echo "iocage upgrade -r $RELEASE $jail"
          echo "iocage restart $jail"
          echo "iocage exec $jail "pkg-static install -f -y pkg" # fix shared object 'libarchive.so.6' not found, required by 'pkg'"
          echo "iocage exec $jail "pkg-static upgrade -f -y""
          echo "iocage restart $jail"
        fi
      fi
  done
elif [ "$opt" = "Quit" ];then
   print_msg "Quit"
fi

