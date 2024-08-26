#!/bin/bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d unleashedrecipes.com -d www.unleashedrecipes.com
systemctl stop apache2
certbot certonly --standalone --preferred-challenges http -d unleashedrecipes.com,www.unleashedrecipes.com
systemctl start apache2
systemctl status apache2
