# nginx
FROM nginx:latest

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy Nginx configuration
 COPY statuspage/status-page/contrib/nginx.conf /etc/nginx/conf.d/status-page.conf

# Copy SSL certificates directly into the image
# COPY certs/status-page.crt /etc/nginx/certs/status-page.crt
# COPY certs/status-page.key /etc/nginx/certs/status-page.key

EXPOSE 80 

CMD ["nginx", "-g", "daemon off;"]
