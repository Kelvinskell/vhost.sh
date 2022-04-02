#!/bin/bash

# Set strict mode
set -eo pipefail

# Define colours
Red='\033[1;31m'
Green='\033[1;32m'
Blue='\033[1;34m'
Cyan='\033[1;36m'
Purple='\033[1;35m'
NC='\033[0;m'

# Check if domain name is valid
echo -e "${Blue}Enter the name of your domain${NC}"
read domain
if $(echo $domain | egrep -q '.com|.org|.edu')
then	
	if [ -f /etc/apache2/sites-available/$domain.conf ] || [ -f /etc/httpd/sites-available/$domain.conf ] || [ -f /etc/httpd/conf.d/$domain.conf ]
	then
		echo -e "${Cyan}Domain name already exists. ${NC} \nOverwrite?"
		read -p "yes or no " reply
		if [ $reply == yes ] || [ $reply == y ]
		then
			:
		else
			echo -e "${Purple}Exiting program...${NC}"
			sleep 1
			exit 0
		fi
	else
		:
	fi
else
	echo -e "${Red}Domain Name Not Valid${NC}"
	exit
fi
# Create a directory structure with suitable permissions
sudo mkdir -p /var/www/$domain/html/
sudo chown -R $USER:$USER /var/www/$domain/html
sudo chmod -R 755 /var/www/$domain
sleep 1
echo -e "${Green}Created directory  for $domain"

function F1()
{
	# Create Index page for html directory
echo -e "${Purple}Open an editor to create your index page?\tChoose no to input texts and automatically convert to html.${NC}"
read -p "yes or no? " ans
if [ $ans == yes ] || [ $ans == y ]
then
	vim /var/www/$domain/html/index.html
elif
	[ $ans == no ] || [ $ans == n ]
then
echo -e "${Cyan}Input title:${NC} " 
read title
echo -e "${Cyan}Input body:${NC} "
read body
echo -e "<html>\n<head>\n<title>$title</title>\n</head>\n<body>\n<h1>$body</h1>\n</body>\n</html>" > /var/www/$domain/html/index.html
else
	echo -e "${Red}Incorrect input"
	F1
fi
sleep 1
}
F1
echo -e "${Green}Index page created for $domain"

# Create a new virtual host file
echo -e "${Blue}Creating a virtual host file for $domain"
echo -e "${Cyan}Please enter values for the following: ServerAdmin,ServerName,ServerAlias${NC}"
read -p "Seperate each entry with a comma: " values
IFS=","
read -a valuesstr <<< "$values"

# Place the virtual host file into sites-available directory
# Conditional check to dtermine correct directory to place the virtual host file
if [ -d /etc/apache2 ]
then
	printf "%s\n"  "<VirtualHost *:80>" "ServerAdmin ${valuesstr[0]}" "ServerName ${valuesstr[1]}" "ServerAlias ${valuesstr[2]}" "DocumentRoot /var/www/$domain/html" "ErrorLog \${APACHE_LOG_DIR}/$domain""_error.log" "CustomLog \${APACHE_LOG_DIR}/$domain""_access.log combined" "</VirtualHost>" > $domain.conf
	sleep  1
	sudo mv $domain.conf /etc/apache2/sites-available/$domain.conf 
elif [ -d /etc/httpd ]
then
	if [ -d /etc/httpd/sites-available ] && [ -d /etc/httpd/sites-enabled ]
	then
		:
	else
		sudo mkdir /etc/httpd/sites-available 2>/dev/null
		sudo mkdir /etc/httpd/sites-enabled 2>/dev/null
	fi
	sudo printf "%s\n"  "<VirtualHost *:80>" "ServerAdmin ${valuesstr[0]}" "ServerName ${valuesstr[1]}" "ServerAlias ${valuesstr[2]}" "DocumentRoot /var/www/$domain/html" "ErrorLog /var/log/httpd/$domain""-error.log" "CustomLog /var/log/httpd/$domain""-access.log combined" "DirectoryIndex index.html" "</VirtualHost>" > $domain.conf
	sudo cp  $domain.conf /etc/httpd/sites-available/$domain.conf
	sudo touch /etc/httpd/conf.d/$domain.conf && sudo cp  $domain.conf /etc/httpd/conf.d/$domain.conf
else
	echo "${Red}Error: Could not determine the appropriate directory to place virtual host file"
	echo "${Red} Exiting abruptly.${NC}"
	exit 1
fi
echo -e "${Green}Virtual host file created for $domain."

function F2()
{
echo -e "${Cyan}Activate virtual host configuration file?${NC}"
read -p "Yes or no? " answer
if [ $answer == yes ] || [ $answer == y ] 
then
	if [ -d /etc/apache2 ]
	then
		sudo a2ensite $domain.conf
		echo -e "${Green}Active"
		# Disable default configuration file
		sudo a2dissite 000-default.conf
	elif [ -d /etc/httpd ]
	then
		sudo ln -s /etc/httpd/sites-available/$domain /etc/httpd/sites-enabled/$domain.conf 2>/dev/null
	fi
elif
	[ $answer == no ] || [ $answer == n ] && [ -d /etc/apache2 ] || [ -d /etc/httpd ]
then
	:
else
	echo -e "${Red}Incorrect answeri${NC}"
	F2
fi
sleep 1
}
F2


# Restart Webserver
if [ -d /etc/apache2 ]
then
	sudo systemctl restart apache2
else
	sudo systemctl restart httpd
fi
sleep 2

if [ -d /usr/share/cowsay ]
then
	cowsay -y "Task Complete!"
else
echo -e "${Green}Task Complete!${NC}"
fi
exit
