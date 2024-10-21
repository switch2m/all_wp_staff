#BACKUP AND RESTORE STEPS

#BACKUP PROCESS
- Identify the wordpress DB name mostly it would be "wordpress"
- Navigate to your WordPress directory

Run the following command:
sudo mysqldump -u root -p wordpress > flavorfull_db_backup.sql
sudo tar -cvzf flavorfull_website_backup.tar.gz /var/www/html


#RESTORE PROCESS 
- Extract files from the backup to the /var/www/html (make sure to cleanup before if you have a website there already)
- Set correct permissions
- DROP the existing DB and create new wordpress DB
- Import the database sql backup
- Update wp-config.php with new database details DB_NAME, DB_USER, DB_PASSWORD, and DB_HOST if necessary
- Update site URL in the database
- Restart Apache2 server

Execute the following command:
sudo tar -xzvf flavorfull_website_backup.tar.gz #and make sure to MOVE the WEBSITE FILES to /var/www/html
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo mysql -u root -p >>>then DROP DATABASE IF EXISTS wordpress; and create new CREATE DATABASE wordpess; and GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost'; then finaly FLUSH PRIVILEGES;
sudo mysql wordpress < flavorfull_db_backup.sql
sudo mysql >>>then USE wordpress; UPDATE wp_options SET option_value = 'http://your-new-domain-or-ip' WHERE option_name IN ('home', 'siteurl'); EXIT;

