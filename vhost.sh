#!/bin/bash

# Set strict mode
set -eo pipefail

# Check if domain name is valid
echo "Enter the name of your domain"
read domain
if $(echo $domain | egrep -q '.com|.org|.edu')
then
	:
else
	echo "Domain Name Not Valid"
	exit
fi
# Create a directory structure with suitable permissions
sudo mkdir -p /var/www/$domain/html/
sudo chown -R $USER:$USER /var/www/$domain/html
sudo chmod -R 755 /var/www/$domain
sleep 1
echo "Created directory  for $domain"

function F1()
{
	# Create Index page for html directory
echo -e "Open an editor to create your index page?\tChoose no to input texts and automatically convert to html."
read -p "yes or no? " ans
if [ $ans == yes ] || [ $ans == y ]
then
	vim /var/www/$domain/html/index.html
elif
	[ $ans == no ] || [ $ans == n ]
then
echo "Input title: " 
read title
echo "Input body: "
read body
echo -e "<html>\n<head>\n<title>$title</title>\n</head>\n<body>\n<h1>$body</h1>\n</body>\n</html>" > /var/www/$domain/html/index.html
else
	echo "Incorrect input"
	F1
fi
sleep 1
}
F1
echo "Index page created for $domain"

# Create a new virtual host file
echo "Creating a virtual host file for $domain"
echo "Please enter values for the following: ServerAdmin,ServerName,ServerAlias"
read -p "Seperate each entry with a comma " values
IFS=","
read -a valuesstr <<< "$values"
printf "%s\n"  "<VirtualHost *:80>" "ServerAdmin ${valuesstr[0]}" "ServerName ${valuesstr[1]}" "ServerAlias ${valuesstr[2]}" "DocumentRoot /var/www/$domain/html" "ErrorLog \${APACHE_LOG_DIR}/$domain""_error.log" "CustomLog \${APACHE_LOG_DIR}/$domain""_access.log combined" "</VirtualHost>" > $domain.conf
sleep  1
# Place the virtual host file into sites-available directory
sudo mv $domain.conf /etc/apache2/sites-available/$domain.conf 
echo "Virtual host file created for $domain."

function F2()
{
echo "Activate virtual host configuration file?"
read -p "Yes or no? " answer
if [ $answer == yes ] || [ $answer == y ]
then
	sudo a2ensite $domain.conf
	echo "Active"
elif
	[ $answer == no |$answer == n ]
then
	continue
else
	echo "Incorrect answer"
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
echo "Task Complete!"
fi
exit
