FROM nginx:latest

# Copy the custom NGINX configuration to the correct location
COPY nginx.conf /etc/nginx/conf.d/status-page.conf

# SSL certificates
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/status-page.key \
-out /etc/ssl/certs/status-page.crt \
-subj "/C=US/ST=State/L=City/O=Organization/CN=status-page"

# Remove default config and enable the new one
RUN rm -f /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80 443

# Start NGINX in foreground mode
CMD ["nginx", "-g", "daemon off;"]
