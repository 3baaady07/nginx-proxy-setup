#!/bin/bash


echo "Checking Docker installation!"

docker -v
dockerInstalled=1

if [ $? -ne 0 ]; then
    echo "This setup requires a docker installation!"
    dockerInstalled=0
else
    echo "Docker is ready."
fi

if [ $dockerInstalled == 1 ]; then
    # 1 is for true and 0 for false
    argChk=1;

    if [ -z "$1" ]; then 
        echo "ERROR: An email must be specified."
        argChk=0;
    fi

    if [ $argChk == 1 ]; then 
        echo "Email: $1"
        
        curl https://raw.githubusercontent.com/nginx-proxy/nginx-proxy/main/nginx.tmpl > nginx.tmpl

        docker run --detach \
            --name nginx-proxy \
            --publish 80:80 \
            --publish 443:443 \
            -v conf:/etc/nginx/conf.d  \
            -v vhost:/etc/nginx/vhost.d \
            -v html:/usr/share/nginx/html \
            -v certs:/etc/nginx/certs \
            nginx

        docker run --detach \
            --name nginx-proxy-gen \
            --volumes-from nginx-proxy \
            -v $(pwd)/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
            -v /var/run/docker.sock:/tmp/docker.sock:ro \
            nginxproxy/docker-gen \
            -notify-sighup nginx-proxy -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf


        docker run --detach \
            --name nginx-proxy-acme \
            --volumes-from nginx-proxy \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -v acme:/etc/acme.sh \
            --env NGINX_DOCKER_GEN_CONTAINER=nginx-proxy-gen \
            --env DEFAULT_EMAIL=$1 \
            nginxproxy/acme-companion
    fi
fi