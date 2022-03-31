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
	:
else
	echo -e "${Red}Domain Name Not Valid"
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
echo -e "${Purple}Open an editor to create your index page?\tChoose no to input texts and automatically convert to html."
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
echo -e "${Cyan}Please enter values for the following: ServerAdmin,ServerName,ServerAlias"
read -p "Seperate each entry with a comma: " values
IFS=","
read -a valuesstr <<< "$values"
printf "%s\n"  "<VirtualHost *:80>" "ServerAdmin ${valuesstr[0]}" "ServerName ${valuesstr[1]}" "ServerAlias ${valuesstr[2]}" "DocumentRoot /var/www/$domain/html" "ErrorLog \${APACHE_LOG_DIR}/$domain""_error.log" "CustomLog \${APACHE_LOG_DIR}/$domain""_access.log combined" "</VirtualHost>" > $domain.conf
sleep  1
# Place the virtual host file into sites-available directory
sudo mv $domain.conf /etc/apache2/sites-available/$domain.conf 
echo -e "${Green}Virtual host file created for $domain."

function F2()
{
echo -e "${Cyan}Activate virtual host configuration file?"
read -p "Yes or no? " answer
if [ $answer == yes ] || [ $answer == y ]
then
	sudo a2ensite $domain.conf
	echo -e "${Green}Active"
elif
	[ $answer == no |$answer == n ]
then
	continue
else
	echo -e "${Red}Incorrect answer"
	F2
fi
sleep 1
}
F2

# Disable default configuration file
sudo a2dissite 000-default.conf

# Restart Webserver
sudo systemctl restart apache2
sleep 2

if [ -d /usr/share/cowsay ]
then
	cowsay -y "Task Complete!"
else
echo -e "${Green}Task Complete!"
fi
exit
