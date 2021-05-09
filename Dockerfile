# use nginx:alpine as base image
FROM nginx:alpine
LABEL MAINTAINER="Gabriel"

# copy static website index.html into nginx default html folder
COPY index.html /usr/share/nginx/html

# export port 80
EXPOSE 80

# run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
