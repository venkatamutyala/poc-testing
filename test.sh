#!/bin/bash


set -e

apt update && apt install awscli -y
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
cd /var/www
wp plugin install all-in-one-wp-migration --version=7.79 --activate --allow-root --path=/var/www/html
aws s3 cp ${S3_OBJECT_KEY} all-in-one-wp-migration-unlimited-extension.zip
wp plugin install all-in-one-wp-migration-unlimited-extension.zip --force --activate --allow-root --path=/var/www/html
rm all-in-one-wp-migration-unlimited-extension.zip
chown -R www-data:www-data /var/www/html
