#!/bin/bash
# vim:sw=4:ts=4:et


touch /etc/nginx/conf.d/nginxpr.conf;
> /etc/nginx/conf.d/nginxpr.conf;

##****CONFIG UPSTREAM****##
QTDEHOST=$(yq eval '.nginx.hosts|length' proxynginxpr.yaml)
for i in `seq 1 $QTDEHOST`
do
    # echo "$i"
    echo "" >> /etc/nginx/conf.d/nginxpr.conf
    NameLocationUpstream=$(yq eval '.nginx.hosts['$(($i-1))'].name' proxynginxpr.yaml)
    echo "upstream $NameLocationUpstream {" >> /etc/nginx/conf.d/nginxpr.conf

    QtdAddress=$(yq eval '.nginx.hosts['$(($i-1))'].address|length' proxynginxpr.yaml)
    SERVERS=''
    for e in `seq 1 $QtdAddress`
    do
        hostip=$(yq eval '.nginx.hosts['$(($i-1))'].address['$(($e-1))'].hostip' proxynginxpr.yaml)
        port=$(yq eval '.nginx.hosts['$(($i-1))'].address['$(($e-1))'].port' proxynginxpr.yaml)
        echo "  server $hostip:$port;" >> /etc/nginx/conf.d/nginxpr.conf
    done

    echo "}" >> /etc/nginx/conf.d/nginxpr.conf
    echo "" >> /etc/nginx/conf.d/nginxpr.conf

done
##****CONFIG UPSTREAM****##

##****CONFIG SERVER LISTEN NGINX****##
NginxPort=$(yq eval '.portnginx' proxynginxpr.yaml)
echo "" >> /etc/nginx/conf.d/nginxpr.conf
echo "#Config the server" >> /etc/nginx/conf.d/nginxpr.conf
echo "server {" >> /etc/nginx/conf.d/nginxpr.conf
echo "  #######################################" >> /etc/nginx/conf.d/nginxpr.conf
echo "  listen $NginxPort;" >> /etc/nginx/conf.d/nginxpr.conf
echo "  server_name prn.nginxpr.com;" >> /etc/nginx/conf.d/nginxpr.conf
echo "  # error logging" >> /etc/nginx/conf.d/nginxpr.conf
echo "  error_log /var/log/nginx/prn_error.log debug;" >> /etc/nginx/conf.d/nginxpr.conf
echo "  access_log /var/log/nginx/prn_access.log;" >> /etc/nginx/conf.d/nginxpr.conf
echo "  include /etc/nginx/conf.d/location.d/*.location;" >> /etc/nginx/conf.d/nginxpr.conf
echo "  #######################################" >> /etc/nginx/conf.d/nginxpr.conf
echo "}" >> /etc/nginx/conf.d/nginxpr.conf
cat /etc/nginx/conf.d/nginxpr.conf
##****CONFIG SERVER LISTEN NGINX****##


##****CONFIG LOCATIONS****##
# yq eval '.portnginx' proxynginxpr.yaml
for f in `seq 1 $QTDEHOST`
do
    # echo "$f"
    NameLocationUpstream=$(yq eval '.nginx.hosts['$(($f-1))'].name' proxynginxpr.yaml)
    touch /etc/nginx/conf.d/location.d/$NameLocationUpstream.location #create new location
    echo "" >  /etc/nginx/conf.d/location.d/$NameLocationUpstream.location

    PathNginx=$(yq eval '.nginx.hosts['$(($f-1))'].pathnginx' proxynginxpr.yaml)
    PrefixApp=$(yq eval '.nginx.hosts['$(($f-1))'].prefixapp' proxynginxpr.yaml)

    echo "#$NameLocationUpstream" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    echo "location ~ ^/$PathNginx(/?)(.*)$ {" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    echo "  proxy_http_version 1.1;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location    
    echo "  proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location    
    echo "  proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location    
    echo "  proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    echo "  proxy_set_header X-Forwarded-Proto \$scheme;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    echo "  proxy_read_timeout                 900;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    echo '  proxy_set_header Connection "upgrade";' >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    echo "  proxy_buffers 32 4k;" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location    
    echo '  set $upstream_endpoint http://'$NameLocationUpstream$PrefixApp'$2$is_args$args;' >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location 
    echo '  proxy_pass $upstream_endpoint;' >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location 
    echo "}" >> /etc/nginx/conf.d/location.d/$NameLocationUpstream.location 

    cat /etc/nginx/conf.d/location.d/$NameLocationUpstream.location
    
done
##****CONFIG LOCATIONS****##
ls /etc/nginx/conf.d/
ls /etc/nginx/conf.d/location.d/
# cat /etc/nginx/conf.d/jenkins.location




set -e

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [ "$1" = "nginx" -o "$1" = "nginx-debug" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

        echo >&3 "$0: Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) echo >&3 "$0: Ignoring $f";;
            esac
        done

        echo >&3 "$0: Configuration complete; ready for start up"
    else
        echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
    fi
fi

exec "$@"