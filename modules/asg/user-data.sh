#!/bin/bash
set -e

apt-get update -y
apt-get install -y unzip nginx awscli curl

# Descargar web desde S3
mkdir -p /tmp/catalogo
aws s3 cp s3://${ASG_S3_BUCKET}/catalogo.zip /tmp/catalogo/catalogo.zip

unzip -o /tmp/catalogo/catalogo.zip -d /tmp/catalogo

rm -rf /var/www/html/*
cp -r /tmp/catalogo/catalogo/* /var/www/html/

# 🔥 INFO DINÁMICA (ESTO ES LO NUEVO)
HOSTNAME=$(hostname)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "<hr>" >> /var/www/html/index.html
echo "<p><strong>Served by:</strong> $HOSTNAME</p>" >> /var/www/html/index.html
echo "<p><strong>Instance ID:</strong> $INSTANCE_ID</p>" >> /var/www/html/index.html

chown -R www-data:www-data /var/www/html
systemctl restart nginx
