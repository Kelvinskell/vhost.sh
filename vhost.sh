#!/bin/bash
# Set strict mode
set -eo pipefail

# Create a directory structure with suitable permissions
echo "Enter the name of your domain"
read domain
sudo mkdir -p /var/www/$domain/html/
sudo chown -R $USER:$USER /var/www/$domain/html
sudo chmod -R 755 /var/www/$domain
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
}
F1
echo "Index page created for $domain"

# Create a new virtual host file
echo "Creating a virtual host file for $domain"
echo "Please enter values for the following: ServerAdmin,ServerName,ServerAlias"
read -p "Seperate each entry with a comma " values
IFS=","
read -a valuesstr <<< "$values"
sudo echo -e "<VirtualHost *:80>\nServerAdmin ${valuesstr[0]}\nServerName ${valuesstr[1]}\nServerAlias ${valuesstr[2]}\nDocumentRoot /var/www/$domain/html\nErrorLog \${APACHE_LOG_DIR}/error.log\nCustomLog \${APACHE_LOG_DIR}/access.log\n</VirtualHost>" > $domain.conf 

# Place the virtual host file into sites-available directory
sudo mv $domain.conf /etc/apache2/sites-available/$domain.conf 
echo "Virtual host file created for $domain."

function F2()
{
echo "Activate virtual host configuration file?"
read -p "Yes or no? " answer
if [ $answer == yes |$answer == y ]
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
}
F2
sudo a2dissite 000-default.conf
sudo systemctl restart apache 2
sudo echo "ServerName $domain" > /etc/apache2/conf-available/servername.conf
sudo apache2ctl configtest
sleep 2
if [ -d /usr/share/cowsay ]
then
	cowsay -y "Mission Complete!"
else
echo "Mission Complete!"
fi
exit
