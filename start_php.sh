#!/usr/bin/env bash
cd /opt/app/${PROJECT_NAME}

if [ -f /opt/app/${PROJECT_FILE}/composer.lock ]; then
    composer install

    php-fpm
else
    echo "Composer.lock file is not loaded."
fi
