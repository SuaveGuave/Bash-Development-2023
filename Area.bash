#!/bin/bash

#This program takes user input for the length and width of a rectangle, 
#either in cm or inches, and then outputs the area of said rectangle in either cm2 or inch2, depending on the users choice

function is_valid() {
    [[ -z $1 || $1 =~ [^0-9.] || $(echo "$1 > 40000" | bc) -eq 1 ]]
}
#data validation making sure that the user cannot input characters that aren't numbers, and cannot input values above 40000, for the sake of preventing crashes.

function areacalc() {

if (whiptail --title "Enter your measurements" --yes-button "cm" --no-button "inches" --yesno "Would you like to enter your measurements in cm or inches?" 10 60) 
then
    CMLENGTH=""
    while is_valid $CMLENGTH; do
        CMLENGTH=$(whiptail  --nocancel --title "cm length input" --inputbox "Input your length in cm (max 40000):" 10 60 "$CMLENGTH" 3>&1 1>&2 2>&3)
    done
    
    CMWIDTH=""
    while is_valid $CMWIDTH; do
        CMWIDTH=$(whiptail --nocancel --title "cm width input" --inputbox "Input your width in cm (max 40000):" 10 60 "$CMWIDTH" 3>&1 1>&2 2>&3)
    done

    if (whiptail --title "cm2 or inch2" --yes-button "cm2" --no-button "inches2" --yesno "Would you like your area in cm2 or inches2?" 10 60)
    then
        AREA=$(echo "scale=10; $CMLENGTH * $CMWIDTH" | bc)
        whiptail --title "Area" --msgbox "Your area is: $AREA cm squared" 10 60
    else
        CMTOINCHLENGTH=$(echo "scale=10; $CMLENGTH / 2.54" | bc)
        CMTOINCHWIDTH=$(echo "scale=10; $CMWIDTH / 2.54" | bc)
        AREA=$(echo "scale=10; $CMTOINCHLENGTH * $CMTOINCHWIDTH" | bc)
        whiptail --title "Area" --msgbox "Your area is: $AREA inches squared" 10 60
    fi
    #whiptail initially asks the user if they would like to input in cm or inches, if cm, they input their values, it asks them if they want the area in cm2 or inches2,
    #and then enters another if statement depending on the users choice to either just times the two numbers together if they are using the same units, or convert them,
    #so that it can be displayed in the alternate units. The second half of the wider if statement functions the same, but in reverse for if they chose inches first.
else
    INLENGTH=""
    while is_valid $INLENGTH; do
        INLENGTH=$(whiptail --nocancel --title "inch length input" --inputbox "Input your length in inches (max 40000):" 10 60 "$INLENGTH" 3>&1 1>&2 2>&3)
    done

    INWIDTH=""
    while is_valid $INWIDTH; do
        INWIDTH=$(whiptail --nocancel --title "inch wdith input" --inputbox "Input your wdith in inches (max 40000):" 10 60 "$INWIDTH" 3>&1 1>&2 2>&3)
    done
    
    if (whiptail --title "cm2 or inch2" --yes-button "cm2" --no-button "inches2" --yesno "Would you like your area in cm2 or inches2?" 10 60)
    then
        INCHTOCMLENGTH=$(echo "scale=10; $INLENGTH * 2.54" | bc)
        INCHTOCMWIDTH=$(echo "scale=10; $INWIDTH * 2.54" | bc)
        AREA=$(echo "scale=10; $INCHTOCMLENGTH * $INCHTOCMWIDTH" | bc)
        whiptail --title "Area" --msgbox "Your area is: $AREA cm squared" 10 60
    else
        AREA=$(echo "scale=10; $INLENGTH * $INWIDTH" | bc)
        whiptail --title "Area" --msgbox "Your area is: $AREA inches squared" 10 60
    fi
fi

}

keeprunning=1
while [ $keeprunning != 0 ] ; do
    areacalc

    whiptail --yesno "Go Again?" 10 60
    exitcmd=$?
    if [ $exitcmd = 1 ]; then
        keeprunning=0
    fi
done
#upon the script starting, it sets keeprunning to 1, upon the script reaching its end, the user is prompted for if they would like to go again, if the user selects yes,
#then the program will loop, if they select no, it sets the keeprunning value to 0 so that it wont loop again, and the program exits.
