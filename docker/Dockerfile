# nginx
FROM nginx:latest

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy Nginx configuration
COPY statuspage/status-page/contrib/nginx.conf /etc/nginx/conf.d/status-page.conf

EXPOSE 80 

CMD ["nginx", "-g", "daemon off;"]

