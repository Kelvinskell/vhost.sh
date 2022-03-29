#!/bin/bash
set -e
#This is a script that automates the creation of Apache2 virtual hosts.
#This script is specially adapted for Linux users and may not work on other operating systems.
#This script can be expanded/modified to include other configuration options as needed. 
#The configurable speaking cow, cowsay, is optionally required for this program.
echo "Enter the name of your domain"
read domain
sudo mkdir -p /var/www/$domain/html
sudo chown -R $USER:$USER /var/www/$domain/html
sudo chmod -R 755 /var/www/$domain
echo "Directory created for $domain"
function F1()
{
echo "Create your own index page or use a custom index page?\nPress yes to create yours and no to use a custom file."
read -p "yes or no? " ans
if [ $ans == yes | $ans == y ]
then
	vim /var/www/$domain/html/index.html
elif
	[ $ans == no | $ans == n]
then
echo "Input texts for your index page. (Seperate each sentence with a comma)"
read index
IFS=","
read -a indexarr <<< "$index"
echo -e "<html>\n<head>\n<title>${indexarr[0]}</title>\n</head>\n<body>\n<h1>${indexarr[1]}</h1>\n</body>\n</html>" > /var/www/$domain/html/index.html
else
	echo "Incorrect input"
	F1
fi
}
F1
echo "Index page created for $domain"
echo "Creating a virtual host file for $domain"
echo "Please enter values for the following: ServerAdmin,ServerName,ServerAlias"
read -p "Seperate each entry with a comma" values
IFS=","
read valuesstr <<< "$values"

sudo echo -e "<VirtualHost *:80\nServerAdmin ${valuesstr[0]}\nServerName ${valuesstr[1]}\nServerAlias ${valuesstr[2]}\nDocumentRoot /var/www/$domain/html\nErrorLog ${APACHE_LOG_DIR}/error.log\nCustomLog ${APACHE_LOG_DIR}/access.log\n</VirtualHost>" > /etc/apache2/sites-available/$domain.conf 

echo "Virtual host file created."
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
#Written by kelvin C Onuchukwu
#https://www.linkedin.com/in/kelvin-onuchukwu-3460871a1
#Please report any bugs to kelvinskelll@gmail.com
