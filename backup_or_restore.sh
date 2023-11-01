#!/bin/bash
set -e

docker-entrypoint.sh apache2-foreground &
apt update && apt install awscli -y
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
cd /var/www
wp plugin install all-in-one-wp-migration --version=7.79 --activate --allow-root --path=/var/www/html
aws s3 cp s3://${S3_BUCKET_NAME}/${S3_OBJECT_KEY} all-in-one-wp-migration-unlimited-extension.zip
wp plugin install all-in-one-wp-migration-unlimited-extension.zip --force --activate --allow-root --path=/var/www/html
rm all-in-one-wp-migration-unlimited-extension.zip
chown -R www-data:www-data /var/www/html

if [ -n "$BACKUP_TO_RESTORE" ]; then
    echo "RESTORING BACKUP NOW: ${BACKUP_TO_RESTORE}"
    wp maintenance-mode activate --activate --allow-root --path=/var/www/html
    sleep 30;
    # download backup and restore
    aws s3 cp s3://${S3_BUCKET_NAME}/${BACKUP_TO_RESTORE} /var/www/html/wp-content/ai1wm-backups/restore.wpress
    wp ai1wm restore restore.wpress --yes --allow-root --path=/var/www/html
    rm /var/www/html/wp-content/ai1wm-backups/restore.wpress
    wp maintenance-mode deactivate --activate --allow-root --path=/var/www/html
else
    wp maintenance-mode activate --activate --allow-root --path=/var/www/html
    sleep 30;
    wp ai1wm backup --allow-root --path=/var/www/html --exclude-spam-comments --exclude-post-revisions --exclude-themes --exclude-inactive-themes --exclude-muplugins --exclude-inactive-plugins --exclude-cache --exclude-email-replace 
    LATEST_BACKUP=$(ls -t /var/www/html/wp-content/ai1wm-backups | head -n1)
    aws s3 cp /var/www/html/wp-content/ai1wm-backups/${LATEST_BACKUP} s3://${S3_BUCKET_NAME}/${LATEST_BACKUP}
    rm /var/www/html/wp-content/ai1wm-backups/${LATEST_BACKUP}
    wp maintenance-mode deactivate --activate --allow-root --path=/var/www/html
fi
