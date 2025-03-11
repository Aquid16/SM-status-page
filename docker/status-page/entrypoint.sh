#!/bin/bash

# Run upgrade script
/opt/status-page/upgrade.sh

# Collect static files
python3 /opt/status-page/statuspage/manage.py collectstatic --noinput

# Run migrations
python3 /opt/status-page/statuspage/manage.py migrate --noinput

# Create superuser (if it doesn't already exist)
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists() or User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')" | python3 /opt/status-page/statuspage/manage.py shell

# Start Gunicorn
cp /opt/status-page/contrib/gunicorn.py /opt/status-page/gunicorn.py

