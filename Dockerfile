FROM nginx
LABEL maintainer="Didevlab - Nginx - Proxy Reverse"


ENV VERSION_YQ='v4.6.3'
ENV BINARY='yq_linux_amd64'
RUN apt-get update -y && apt-get install wget curl ngrep tar -y && \
    rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/mikefarah/yq/releases/download/${VERSION_YQ}/${BINARY}.tar.gz -O - |\
  tar xz && mv ${BINARY} /usr/bin/yq


RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

ADD proxynginxpr.yaml /proxynginxpr.yaml
RUN mkdir -p /etc/nginx/conf.d/location.d/ && chmod -R 777 /etc/nginx/conf.d/location.d/

RUN rm -rf docker-entrypoint.sh
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]