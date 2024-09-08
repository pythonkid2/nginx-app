#!/bin/bash
sudo cp /home/ubuntu/nginx-app/index.html /var/www/html/index.html
sudo systemctl restart nginx

