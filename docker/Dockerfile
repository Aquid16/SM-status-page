# Use official Python 3.11 image as base
FROM python:3.13

# Set working directory
WORKDIR /opt/status-page/

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libssl-dev \
    && apt-get clean

# Create system user and group
RUN groupadd --system status-page && \
    adduser --system --ingroup status-page status-page

# Set ownership of the app directory
RUN chown -R status-page:status-page /opt/status-page/

# Upgrade pip and install dependencies
RUN pip install --upgrade pip
COPY status-page/requirements.txt /opt/status-page/
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
ADD status-page /opt/status-page/

# Copy Gunicorn configuration
COPY status-page/contrib/gunicorn.py /opt/status-page/gunicorn.py

# Make scripts executable
RUN chmod +x /opt/status-page/upgrade.sh && \
    chmod +x /opt/status-page/entrypoint.sh

# Set environment variables directly in the image
ENV DATABASE_NAME=status-page \
    DATABASE_USER=status-page \
    DATABASE_PASSWORD=abcdefgh123456 \
    DATABASE_HOST=db \
    DATABASE_PORT=5432 \
    REDIS_HOST=redis_host \
    REDIS_PORT=6379 \
    REDIS_PASSWORD="" \
    REDIS_TASKS_DB=0 \
    REDIS_CACHING_DB=1 \
    ALLOWED_HOSTS="*" \
    SECRET_KEY=Pv)hkWbYxkpaD_dh$ULGa6MF#ADn6&=MU&#v5cjRyViuTbPHuG \
    DJANGO_SUPERUSER_USERNAME=admin \
    DJANGO_SUPERUSER_PASSWORD=admin123 \
    DJANGO_SUPERUSER_EMAIL=admin@example.com

# Expose port for Gunicorn
EXPOSE 8001

# Command to run Gunicorn (will be overridden in docker-compose if needed)
CMD ["/opt/status-page/entrypoint.sh"]
