#!/bin/bash
# configure-nginx.sh
if [ "$MY_NAMESPACE" = "production" ]; then
    cp /nginx-config/nginx-prod.conf /etc/nginx/conf.d/status-page.conf
elif [ "$MY_NAMESPACE" = "development" ]; then
    cp /nginx-config/nginx-test.conf /etc/nginx/conf.d/status-page.conf
else
    echo "Unknown namespace: $MY_NAMESPACE, defaulting to production"
    cp /nginx-config/nginx-prod.conf /etc/nginx/conf.d/status-page.conf
fi
