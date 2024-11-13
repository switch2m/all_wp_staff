#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Apache web server
echo "Installing Apache..."
sudo apt install apache2 -y

# Install MySQL server and client
echo "Installing MySQL..."
sudo apt install mysql-server mysql-client -y

# Install PHP and required modules
echo "Installing PHP and modules..."
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Configure MySQL security
echo "Configuring MySQL..."
sudo mysql_secure_installation <<EOF

y
1
n
y
y
y
y
EOF

# Create MySQL database and user for WordPress
echo "Creating WordPress database and user..."
sudo mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'your_password_here';"
sudo mysql -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download and configure WordPress
echo "Downloading and configuring WordPress..."
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo cp -R wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Configure Apache virtual host
echo "Configuring Apache virtual host..."
sudo tee /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ServerName your_domain.com

    <Directory /var/www/html/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable Apache modules and configuration
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo systemctl restart apache2

# Create wp-config.php
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wordpressuser/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/your_password_here/" /var/www/html/wp-config.php

# Generate and set security keys
SECURITY_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/define( 'AUTH_KEY'/,/define( 'NONCE_SALT'/c\\$SECURITY_KEYS" /var/www/html/wp-config.php

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 750 {} \;
sudo find /var/www/html/ -type f -exec chmod 640 {} \;

echo "WordPress installation completed!"
echo "Please visit http://your_domain.com to complete the setup"
