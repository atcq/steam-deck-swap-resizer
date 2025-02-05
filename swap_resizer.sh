#!/bin/bash
# Author: CryoByte33
# I am in no way responsible to damage done to any device this
# is executed on, all liability lies with the runner.

hasPass=$(passwd -S "$USER" | awk -F " " '{print $2}')
if [[ ! $hasPass == "P" ]]; then
    zenity --error --title="Password Error" --text="Password is not set, please set one in the terminal with the <b>passwd</b> command, then run this again." --width=400
else
    PASSWD="$(zenity --password --title="Enter Password" --text="Enter Deck User Password (not Steam account!)" 2>/dev/null)"
    echo "$PASSWD" | sudo -v -S
    ans=$?
    if [[ $ans == 1 ]]; then
        zenity --error --title="Password Error" --text="Incorrect password provided, please run this command again and provide the correct password." --width=400
    else
        if zenity --question --title="Disclaimer" --text="This script was made by CryoByte33 to resize the swapfile on a Steam Deck.\n\n<b>Disclaimer: I am in no way responsible to damage done to any device this is executed on, all liability lies with the runner.</b>\n\nDo you accept these terms?" --width=600; then
            AVAILABLE=$(df --output="avail" -hl --sync /home | grep -v "Avail" | sed -e 's/^[ \t]*//')
            SIZE=$(zenity --list --radiolist --text "You have $AVAILABLE space available, what size would you like the swap file (in GB)?" --hide-header --column "Selected" --column "Size" TRUE "1" FALSE "2" FALSE "4" FALSE "8" FALSE "12" FALSE "16" FALSE "32")

            if [ "$SIZE" -lt $(echo $AVAILABLE | sed -e 's/[BKMGT]//') ]; then
                (
                    echo 0
                    echo "# Disabling swap..."
                    sudo swapoff -a
                    echo 20
                    echo "# Removing old swapfile..."
                    sudo rm -f /home/swapfile
                    echo 40
                    echo "# Creating new $SIZE GB swapfile..."
                    sudo dd if=/dev/zero of=/home/swapfile bs=1G count=$SIZE status=none
                    echo 60
                    echo "# Setting permissions on swapfile..."
                    sudo chmod 0600 /home/swapfile
                    echo 80
                    echo "# Initializing new swapfile..."
                    sudo mkswap /home/swapfile 
                    sudo swapon /home/swapfile
                    echo 100
                    echo "# Process completed! You can verify the file is resized by doing 'ls /home' or using 'swapon -s'."
                ) | zenity --title "Resizing Swap File" --progress --no-cancel --width=800
            else
                zenity --error --title="Invalid Size" --text="You selected a size greater than the space you have available, cannot proceed." --width=500
            fi
        else
            zenity --error --title="Terms Denied" --text="Terms were denied, cannot proceed." --width=300
        fi
    fi
fi
