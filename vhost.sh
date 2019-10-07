#!/bin/bash
### Set Language
TEXTDOMAIN=vhost

### Set default parameters
domain=$1
owner=$(who am i | awk '{print $1}')
email='nat@nathanaelmartel.net'
sitesEnable='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
userDir='/home/sshweb/www/'
sitesAvailabledomain=$sitesAvailable$domain.conf


### don't modify from here unless you know what you are doing ####

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please provide domain. e.g.dev,staging"
	read domain
done

if [ "$rootDir" == "" ]; then
	rootDir=${domain//./}
fi

rootDir=$userDir$domain

### check if domain already exists
if [ -e $sitesAvailabledomain ]; then
	echo -e $"This domain already exists.\nPlease Try Another one"
	exit;
fi

### check if directory exists or not
if ! [ -d $rootDir ]; then
	### create the directory
	mkdir $rootDir
	### give permission to root dir
	chmod 755 $rootDir
	### write test file in the new domain dir
	if ! echo "<?php echo phpinfo(); ?>" > $rootDir/phpinfo.php
	then
		echo $"ERROR: Not able to write in file $userDir/$rootDir/phpinfo.php. Please check permissions"
		exit;
	else
		echo $"Added content to $rootDir/phpinfo.php"
	fi
fi

### create virtual host rules file
if ! echo "
<VirtualHost *:80>
	ServerName www.$domain
	ServerAlias $domain

	ServerAdmin $email

#  Redirect permanent / https://www.$domain/

	DocumentRoot $rootDir
  <Directory />
          Options FollowSymLinks
          AllowOverride All
  </Directory>
  <Directory $rootDir >
          Options FollowSymLinks MultiViews
          AllowOverride All
          Order allow,deny
          allow from all
  </Directory>


	ErrorLog /home/sshweb/log/$domain.error.log
	CustomLog /home/sshweb/log/$domain.access.log combined

</VirtualHost>




#<VirtualHost *:443>
#  ServerName www.$domain
#  ServerAlias $domain

#  ServerAdmin nat@nathanaelmartel.net

#  DocumentRoot $rootDir
#  <Directory />
#    Options FollowSymLinks
#    AllowOverride All
#  </Directory>
#  <Directory $rootDir >
#    Options FollowSymLinks MultiViews
#    AllowOverride All
#    Order allow,deny
#    allow from all
#  </Directory>

#  SSLEngine on
#  SSLCertificateFile /etc/letsencrypt/live/$domain/cert.pem
#  SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem
#  SSLCertificateChainFile  /etc/letsencrypt/live/$domain/chain.pem
#  SSLVerifyClient none

#  ErrorLog /home/sshweb/log/$domain.error.log
#  CustomLog /home/sshweb/log/$domain.access.log combined

#</VirtualHost>" > $sitesAvailabledomain
then
	echo -e $"There is an ERROR creating $domain file"
	exit;
else
	echo -e $"\nNew Virtual Host Created\n"
fi


chown -R www-data:www-data $rootDir
chmod -R 755 $rootDir


### enable website
a2ensite $domain

### restart Apache
/etc/init.d/apache2 restart

### show the finished message
echo -e $"Complete! \nYou now have a new Virtual Host \nYour new host is: http://$domain \nAnd its located at $rootDir"
exit;
	