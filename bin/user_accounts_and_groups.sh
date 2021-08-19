#!/bin/bash

CheckGroups()
{
	echo "Checking added groups:"
	gid=1600
	for i in hobbits elves dwarves wizards
	do
		if ! grep "^$i:x:$gid" /etc/group > /dev/null
		then
			((Error++));echo "	The $i group is not created."
		fi
		gid=$((gid + 100))
	done
	echo "You made $((4 - Error)) out of the 4 groups successfully."
	if ! grep "^wizards:x:1900:.*cis191.*" /etc/group > /dev/null
	then
		((Error++));echo "	cis191 is not in the wizards group."
	fi
	echo
	Score=$((Score - Error)); Error=0
}

CheckUsers()
{
	echo "Checking added users:"
	if ! grep "^frodo:x:1601:.*Baggins.*bash$" /etc/passwd > /dev/null
	then
		((Error++));echo "	User frodo is not created correctly."
	fi
	if ! grep "^[lg].*:x:1701:1700:.*zsh$" /etc/passwd > /dev/null
	then
		((Error++));echo "	User legolas was not created correctly."
	fi
	if ! grep "^gimli:x*:180[01]:1800:.*loin.*bash$" /etc/passwd > /dev/null
	then
		((Error++));echo "	User gimli was not created correctly."
	fi
	if [  -f /var/preserve/[Gg]ollum.t* ]
	then	:	# gollum has been deleted and archived.
	elif ! grep "^gollum:x:1602:1600:.*:/home/smeagol:" /etc/passwd >/dev/null
	then
		((Error++));echo "	User gollum was not created correctly."
	fi
	echo "You created $((4 - Error)) out of the 4 accounts successfully."
	if [ $Error -eq 0 ]	# Check for additional conditions
	then
		if ! grep "^gimli::" /etc/passwd > /dev/null ||
		     grep "^gimli:x:" /etc/passwd > /dev/null &&
		   ! grep "^gimli::" /etc/shadow > /dev/null
		then
			((Error++));echo "	User gimli has a password."
		fi
		
	fi
	echo
	Score=$((Score - Error)); Error=0
}

CheckPasswd()
{
	echo "Checking forced password:"
	VAR=$(grep "^frodo" /etc/shadow)
	if [ "$VAR" ] && echo "$VAR"|grep "frodo:.*:0:0:99999:7:::$" >/dev/null
	then
		echo -e "You have reset frodo's password and forced a change on the next login.\n"
		return
	fi
	((Score--))
	if [ "$VAR" = "" ]
	then echo "	frodo does not appear to have an account."
	else echo "	frodo's account has not been forced to change password."
	fi
	echo
}

CheckMod()
{
	echo "Checking user modifications:"
	if ! grep "^frodo:x:1601:100" /etc/passwd > /dev/null
	then
		((Error++));echo "	frodo's GID is not 100 (users)"
	elif ! grep "^hobbits:x:1600:.*frodo.*" /etc/group > /dev/null
	then
		((Error++));echo "	frodo is no longer in the hobbits group"
	fi
	if ! grep "^glorfindel:x:1701:1700" /etc/passwd > /dev/null
	then
		((Error++));echo "	legolas's login wasn't changed to glorfindel."
	fi
	if ! grep "^gimli:x*:1800:" /etc/passwd > /dev/null
	then
		((Error++));echo "	gimli's UID wasn't changed to 1800."
	else
		NLINES=$(find /home/gimli -user 1800 2> /dev/null| wc -l)
		if [ "$NLINES" -lt 2 ]
		then
			((Error++));echo "	gimli's home directory was not updated to reflect the UID change."
		fi
	fi
	if [ $Error -eq 0 ]
	then
		echo "Congratulations, all user modifications are correct!"
	fi
	Score=$((Score - Error)); Error=0
	echo
}

CheckLock()
{
	echo "Checking locked account:"
	
	if ! grep "^glorfindel:!.*" /etc/shadow > /dev/null
	then
		((Error++));echo "	glorfindel's account is not locked."
	else
		echo "Congratulations, you have locked glorfindel's account."
	fi
	Score=$((Score - Error)); Error=0
	echo
}

CheckConfig()
{
	echo "Checking user customization:"
	if ! grep "Middle Earth Linux" /etc/issue > /dev/null
	then
		((Error++));echo "	the /etc/issue file hasn't been editted"
	fi
	if [ $(cat /etc/motd | wc -c) -lt 20 ] 
	then
		((Error++));echo "	the /etc/motd file hasn't been editted."
	fi
	if [ ! -r /home/gimli/.hushlogin ] || [ -O /home/gimli/.hushlogin ]
	then
		((Error++));echo "	gimli's login is not properly hushed."
	fi
	#if ! grep "^PS1=.*:" /home/gimli/{.bashrc,.bash_profile} >/dev/null 2>&1
	#then
	#	((Error++));echo "	gimli's prompt is not a colon (:)."
	#fi
	#if grep "^PATH=.*HOME/bin$" /home/gimli/.bash_profile >/dev/null 2>&1
	#then
	#	((Error++));echo "	gimli's \$HOME/bin is in his PATH."
	#fi
	if [ $Error -eq 0 ]
	then
		echo "Congratulations, all login customizations are correct!"
	fi
	Score=$((Score - Error)); Error=0
	echo
}

CheckDel()
{
	echo "Checking deleted user:"
	if grep "^gollum:" /etc/passwd 2> /dev/null
	then ((Error++));echo "	You have not deleted gollum's account."
	elif [ -d /home/smeagol -o -d /home/gollum ]
	then ((Error++));echo "	gollum's home directory is still here."
	elif [ ! -e /var/preserve/gollum.t* ]
	then ((Error++));echo "	gollum's home directory is not archived".
	else
		echo "Congratulations, you have removed gollum's account and saved his home directory."
		if [ -r /var/spool/mail/gollum ]
		then
			echo "(BTW: what should be done with gollum's system mailbox?)"
		fi
	fi
	Score=$((Score - Error)); Error=0
}

# -------------------------- Start of Program ---------------------------#
if [ $EUID -ne 0 ]
then
	echo "You must be super-user to run this program."
	exit 1
fi
#------------------------------ Good to Go ------------------------------#
clear
echo "		Lab 6: Users and groups"
echo
if [ $# -gt 0 ]
then
	COUNT=$1
else
	COUNT=8
fi
Error=0
if [ $((COUNT--)) -gt 0 ]
then
	Score=4;Total=4
	CheckGroups
fi
if [ $((COUNT--)) -gt 0 ]
then
	((Score+=4));((Total+=4))
	CheckUsers
fi
if [ $((COUNT--)) -gt 0 ]
then
	((Score++));((Total++))
	CheckPasswd
fi
if [ $((COUNT--)) -gt 0 ]
then
	((Score+=4));((Total+=4))
	CheckMod
fi
if [ $((COUNT--)) -gt 0 ]
then
	((Score++));((Total++))
	CheckLock
fi
if [ $((COUNT--)) -gt 0 ]
then
	((Score+=4));((Total+=4))
	CheckConfig
fi
if [ $((COUNT--)) -gt 0 ]
then
	((Score+=2));((Total+=2))
	CheckDel
fi
echo Your score is $Score out of $Total.
exit 0
