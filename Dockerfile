FROM nginx:alpine
LABEL description="my custom nginx web server"
COPY site/ /usr/share/nginx/html/
