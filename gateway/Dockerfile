FROM nginx:1.25-alpine
RUN rm -f /etc/nginx/conf.d/default.conf
COPY gateway/default.conf /etc/nginx/conf.d/default.conf
COPY ui/ /usr/share/nginx/html/
EXPOSE 80
