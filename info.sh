#!/bin/bash

apt-get update
apt-get upgrade -y
apt-get install nginx -y
systemctl start nginx.service
systemctl enable nginx.service
echo "Hello World from $(hostname -f)" > /var/www/html/index.html