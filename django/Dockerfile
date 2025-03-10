# Use the official Python runtime image
FROM python:3.12.3
 
# Create the app directory
RUN mkdir -p /opt/status-page/
 
# Set the working directory inside the container
WORKDIR /opt/status-page/
 
# Set environment variables 
# Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE=1
#Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1 

# Install system dependencies
RUN apt-get update && apt install -y libpq-dev gcc

# Create a system user and group
RUN adduser --system --group status-page

# Set ownership of the app directory
RUN chown -R status-page:status-page /opt/status-page/
 
# Upgrade pip
RUN pip install --upgrade pip  
 
# Copy the Django project to the container
ADD status-page /opt/status-page/

# Grant execute permissions to upgrade.sh
RUN chmod +x /opt/status-page/upgrade.sh

# Install Python dependencies
RUN python -m venv /opt/status-page/venv \
    && /opt/status-page/venv/bin/pip install --no-cache-dir -r requirements.txt

# Upgrade and initialize application
RUN /opt/status-page/upgrade.sh 
RUN /opt/status-page/venv/bin/python /opt/status-page/statuspage/manage.py migrate 
RUN /opt/status-page/venv/bin/python /opt/status-page/statuspage/manage.py createsuperuser --noinput

# Copy Gunicorn and systemd service files
RUN cp /opt/status-page/contrib/gunicorn.py /opt/status-page/gunicorn.py \
    && cp -v /opt/status-page/contrib/*.service /etc/systemd/system/ \
    && systemctl daemon-reload

# Expose the Django port
EXPOSE 8000
 
# Start Gunicorn
CMD ["/opt/status-page/venv/bin/gunicorn", "-c", "/opt/status-page/gunicorn.py", "statuspage.wsgi:application"]

