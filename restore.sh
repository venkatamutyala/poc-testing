#!/bin/bash
set -e

# download backup and restore
aws s3 cp s3://${S3_BUCKET_NAME}/${BACKUP_TO_RESTORE} /var/www/html/wp-content/ai1wm-backups/restore.wpress
wp ai1wm restore restore.wpress --yes --allow-root --path=/var/www/html

rm /var/www/html/wp-content/ai1wm-backups/restore.wpress
