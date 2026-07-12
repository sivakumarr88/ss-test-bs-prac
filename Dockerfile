# Simple sample app - adjust to your language
FROM nginx:alpine
COPY ./app /usr/share/nginx/html
EXPOSE 80