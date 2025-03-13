#!/bin/bash

# Run upgrade script
/opt/status-page/upgrade.sh

# Activate venv 
. /opt/status-page/venv/bin/activate

# Create superuser (if it doesn't already exist)
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists() or User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')" | python3 /opt/status-page/statuspage/manage.py shell

# Copy Gunicorn.py
cp /opt/status-page/contrib/gunicorn.py /opt/status-page/gunicorn.py

# Run Django development server for testing
#echo "Starting Django development server for testing..."
#exec python3 /opt/status-page/statuspage/manage.py runserver 0.0.0.0:8000 --insecure

# Start Gunicorn
echo "Starting Gunicorn..."
export PYTHONPATH=/opt/status-page/statuspage
exec gunicorn -c /opt/status-page/gunicorn.py statuspage.wsgi:application --chdir /opt/status-page/statuspage


