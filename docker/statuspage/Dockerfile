# Use official Python 3.11 image as base
FROM python:3.11

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

# Make scripts executable
RUN chmod +x /opt/status-page/upgrade.sh && \
    chmod +x /opt/status-page/entrypoint.sh

# Expose ports
EXPOSE 8001
EXPOSE 8000

# Command to run Gunicorn (will be overridden in docker-compose if needed)
CMD ["/opt/status-page/entrypoint.sh"]
