#!/bin/bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d testwebsite.com -d www.testwebsite.com
systemctl stop apache2
certbot certonly --standalone --preferred-challenges http -d testwebsite.com,www.testwebsite.com
systemctl start apache2
