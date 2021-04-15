#!/bin/bash
# vim:sw=4:ts=4:et


#CHECK EXIST nginxprefix##
EXISTNGINXPREFIX=$(yq eval '.nginxprefix' proxynginxpr.yaml)
if [ ! -z "$EXISTNGINXPREFIX" ] && [ "$EXISTNGINXPREFIX" != "null" ]; then

    touch /etc/nginx/conf.d/nginxpr.conf;
    > /etc/nginx/conf.d/nginxpr.conf;

    ##****CONFIG UPSTREAM****##
    QTDEHOST=$(yq eval '.nginxprefix.hosts|length' proxynginxpr.yaml)
    for i in `seq 1 $QTDEHOST`
    do
        # echo "$i"
        echo "" >> /etc/nginx/conf.d/nginxpr.conf
        NameLocationUpstream=$(yq eval '.nginxprefix.hosts['$(($i-1))'].name' proxynginxpr.yaml)
        echo "upstream $NameLocationUpstream {" >> /etc/nginx/conf.d/nginxpr.conf

        QtdAddress=$(yq eval '.nginxprefix.hosts['$(($i-1))'].address|length' proxynginxpr.yaml)
        for e in `seq 1 $QtdAddress`
        do
            hostip=$(yq eval '.nginxprefix.hosts['$(($i-1))'].address['$(($e-1))'].hostip' proxynginxpr.yaml)
            port=$(yq eval '.nginxprefix.hosts['$(($i-1))'].address['$(($e-1))'].port' proxynginxpr.yaml)
            echo "  server $hostip:$port;" >> /etc/nginx/conf.d/nginxpr.conf
        done

        echo "}" >> /etc/nginx/conf.d/nginxpr.conf
        echo "" >> /etc/nginx/conf.d/nginxpr.conf

    done
    ##****CONFIG UPSTREAM****##

    ##****CONFIG SERVER LISTEN NGINX****##
    NginxPort=$(yq eval '.nginxprefix.portnginxprefix' proxynginxpr.yaml)
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
    # yq eval '.portnginxprefix' proxynginxpr.yaml
    for f in `seq 1 $QTDEHOST`
    do
        # echo "$f"
        NameLocationUpstream=$(yq eval '.nginxprefix.hosts['$(($f-1))'].name' proxynginxpr.yaml)
        touch /etc/nginx/conf.d/location.d/$NameLocationUpstream.location #create new location
        echo "" >  /etc/nginx/conf.d/location.d/$NameLocationUpstream.location

        PathNginx=$(yq eval '.nginxprefix.hosts['$(($f-1))'].pathnginx' proxynginxpr.yaml)
        PrefixApp=$(yq eval '.nginxprefix.hosts['$(($f-1))'].prefixapp' proxynginxpr.yaml)

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
fi
#CHECK EXIST nginxprefix##



##CHECK EXIST hostprn##
EXISTNGINXCUSTOM=$(yq eval '.hostprn' proxynginxpr.yaml)
if [ ! -z "$EXISTNGINXCUSTOM" ] && [ "$EXISTNGINXCUSTOM" != "null" ]; then

    ##****CONFIG SERVER CUSTOM LISTEN NGINX****##
    QTDEHOSTCUSTON=$(yq eval '.hostprn.hosts|length' proxynginxpr.yaml)
    for g in `seq 1 $QTDEHOSTCUSTON`
    do
        NameCustomNginx=$(yq eval '.hostprn.hosts['$(($g-1))'].name' proxynginxpr.yaml)
        PortCustomNginx=$(yq eval '.hostprn.hosts['$(($g-1))'].portprn' proxynginxpr.yaml)
        PrefixAppCustom=$(yq eval '.hostprn.hosts['$(($g-1))'].prefixapp' proxynginxpr.yaml)
        touch /etc/nginx/conf.d/$NameCustomNginx.conf 
        echo "" >  /etc/nginx/conf.d/$NameCustomNginx.conf 


        ##UPSTREAM
        echo "upstream $NameCustomNginx {" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        QtdAddressCustom=$(yq eval '.hostprn.hosts['$(($g-1))'].address|length' proxynginxpr.yaml)
        for h in `seq 1 $QtdAddressCustom`
        do
            hostipcustom=$(yq eval '.hostprn.hosts['$(($g-1))'].address['$(($h-1))'].hostip' proxynginxpr.yaml)
            portcustom=$(yq eval '.hostprn.hosts['$(($g-1))'].address['$(($h-1))'].port' proxynginxpr.yaml)
            echo "  server $hostipcustom:$portcustom;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        done
        echo "}" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        

        ##CONFIG SERVER
        echo "" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "#Config the server custom $NameCustomNginx" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "server {" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  #################################################################" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  listen $PortCustomNginx;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  server_name prn.$NameCustomNginx.com;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  # error logging" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo '  error_log /var/log/nginx/prn_'$NameCustomNginx'_error.log debug;' >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  # access logging" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo '  access_log /var/log/nginx/prn_'$NameCustomNginx'_access.log;' >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  #################################################################" >> /etc/nginx/conf.d/$NameCustomNginx.conf    
        echo "" >> /etc/nginx/conf.d/$NameCustomNginx.conf


        ##CONFIG LOCATION SERVER
        # echo "  location ~ ^/(/?)(.*)$ {" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  location / {" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "    proxy_http_version 1.1;" >> /etc/nginx/conf.d/$NameCustomNginx.conf   
        echo "    proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/$NameCustomNginx.conf 
        echo "    proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "    proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "    proxy_set_header X-Forwarded-Proto \$scheme;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "    proxy_read_timeout                 900;" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo '    proxy_set_header Connection "upgrade";' >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "    proxy_buffers 32 4k;" >> /etc/nginx/conf.d/$NameCustomNginx.conf

        echo '    set $upstream_endpoint http://'$NameCustomNginx';' >> /etc/nginx/conf.d/$NameCustomNginx.conf
        # echo '    set $upstream_endpoint http://'$NameCustomNginx$PrefixAppCustom'$2$is_args$args;' >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo '    proxy_pass $upstream_endpoint;' >> /etc/nginx/conf.d/$NameCustomNginx.conf
        echo "  }" >> /etc/nginx/conf.d/$NameCustomNginx.conf


        echo "}" >> /etc/nginx/conf.d/$NameCustomNginx.conf
        cat /etc/nginx/conf.d/$NameCustomNginx.conf
    done
##****CONFIG SERVER CUSTOM LISTEN NGINX****##
fi
##CHECK EXIST hostprn##




##CHECK EXIST hostprnstream##
EXISTNGINXCUSTOMSTREAM=$(yq eval '.hostprnstream' proxynginxpr.yaml)
if [ ! -z "$EXISTNGINXCUSTOMSTREAM" ] && [ "$EXISTNGINXCUSTOMSTREAM" != "null" ]; then
    mkdir -p /etc/nginx/upstream.d/

    ##****CONFIG SERVER CUSTOM STREAM LISTEN NGINX****##
    QTDEHOSTCUSTOMSTREAM=$(yq eval '.hostprnstream.hosts|length' proxynginxpr.yaml)
    for i in `seq 1 $QTDEHOSTCUSTOMSTREAM`
    do
        NameCustomNginxStream=$(yq eval '.hostprnstream.hosts['$(($i-1))'].name' proxynginxpr.yaml)
        PortCustomNginxStream=$(yq eval '.hostprnstream.hosts['$(($i-1))'].portprn' proxynginxpr.yaml)
        touch /etc/nginx/upstream.d/$NameCustomNginxStream.conf 
        echo "" >  /etc/nginx/upstream.d/$NameCustomNginxStream.conf 

        ##UPSTREAM
        echo "upstream $NameCustomNginxStream {" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf 
        QtdAddressCustomStream=$(yq eval '.hostprnstream.hosts['$(($i-1))'].address|length' proxynginxpr.yaml)
        for j in `seq 1 $QtdAddressCustomStream`
        do
            hostipcustomstream=$(yq eval '.hostprnstream.hosts['$(($i-1))'].address['$(($j-1))'].hostip' proxynginxpr.yaml)
            portcustomstream=$(yq eval '.hostprnstream.hosts['$(($i-1))'].address['$(($j-1))'].port' proxynginxpr.yaml)
            echo "  server $hostipcustomstream:$portcustomstream;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf 
        done
        echo "}" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        ##UPSTREAM


        ##CONFIG SERVER TCP
        echo "" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "#Config the server custom TCP $NameCustomNginxStream" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "server {" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  #################################################################" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  listen $PortCustomNginxStream;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  # error logging" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo '  error_log /var/log/nginx/prn_stream_'$NameCustomNginxStream'_error.log;' >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  # access logging" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf

        echo "  proxy_buffer_size 64k;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  proxy_pass $NameCustomNginxStream;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  #################################################################" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "}" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        ##CONFIG SERVER TCP

        ##CONFIG SERVER UDP
        echo "" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "#Config the server custom UDP $NameCustomNginxStream" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "server {" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  #################################################################" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  listen $PortCustomNginxStream udp;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  # error logging" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo '  error_log /var/log/nginx/prn_stream_'$NameCustomNginxStream'_error.log;' >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  # access logging" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf

        echo "  proxy_buffer_size 64k;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  proxy_pass $NameCustomNginxStream;" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "  #################################################################" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "}" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        echo "" >> /etc/nginx/upstream.d/$NameCustomNginxStream.conf
        ##CONFIG SERVER UDP



        cat /etc/nginx/upstream.d/$NameCustomNginxStream.conf


    done
    ##****CONFIG SERVER CUSTOM STREAM LISTEN NGINX****##

fi
##CHECK EXIST hostprnstream##



ls /etc/nginx/conf.d/
ls /etc/nginx/upstream.d/
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