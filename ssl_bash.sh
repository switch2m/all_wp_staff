#!/bin/bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d mayssam.shop -d www.mayssam.shop
sudo systemctl stop apache2
certbot certonly --standalone --preferred-challenges http -d mayssam.shop,www.mayssam.shop
sudo systemctl start apache2
sudo systemctl status apache2
  
