# nginx
FROM nginx:latest

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 80 

# Copy nginx.conf files to a separate directory (not conf.d)
COPY statuspage/status-page/contrib/nginx-prod.conf /nginx-config/nginx-prod.conf
COPY statuspage/status-page/contrib/nginx-test.conf /nginx-config/nginx-test.conf

COPY configure-nginx.sh /docker-entrypoint.d/configure-nginx.sh
RUN chmod +x /docker-entrypoint.d/configure-nginx.sh

