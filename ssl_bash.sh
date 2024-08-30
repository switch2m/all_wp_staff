#!/bin/bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d flavorfullrecipes.com -d www.flavorfullrecipes.com
sudo systemctl stop apache2
certbot certonly --standalone --preferred-challenges http -d flavorfullrecipes.com,www.flavorfullrecipes.com
sudo systemctl start apache2
sudo systemctl status apache2
  
