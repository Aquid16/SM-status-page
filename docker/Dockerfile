# nginx
FROM nginx:latest

# Install openssl for certificate handling
RUN apt-get update && apt-get install -y \
    openssl \
    && apt-get clean

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy Nginx configuration
COPY statuspage/status-page/contrib/nginx.conf /etc/nginx/conf.d/status-page.conf

# Copy SSL certificates directly into the image
COPY certs/status-page.crt /etc/nginx/certs/status-page.crt
COPY certs/status-page.key /etc/nginx/certs/status-page.key

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
