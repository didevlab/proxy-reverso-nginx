# Proxy Reverso Nginx

## The settings for some apps are in the conf folder

> You will configure only this file below:

File: proxynginxpr.yaml
```
portnginx: 80
nginx:
  hosts:
    - name: 'grafana'
      address:
        - hostip: 192.168.15.7 #<IP-YOUR-GRAFANA>
          port: 3000 #PORT PORTAINER
      pathnginx: "grafana" #stay /grafana does not include / OK !? just the name
      prefixapp: "/"

    - name: 'portainer'
      address:
        - hostip: 192.168.15.3 #<IP-YOUR-PORTAINER> 
          port: 9000 #PORT PORTAINER
      pathnginx: "portainer" #fica /portainer não inclua o / OK!? só o nome mesmo
      prefixapp: "/"
```


> Below is docker-compose.yaml mapping the proxynginxpr.yaml configuration file.

```
version: '2'
services:
  nginx:
    image: didevlab/proxy-reverse-nginx:1.0
    container_name: nginx-proxy-reverso
    restart: always
    ports:
      - '80:80'
    volumes:
      - ./proxynginxpr.yaml:/proxynginxpr.yaml
    environment:
      TZ: America/Sao_Paulo
```

```
docker-compose up -d
```
- You will access: http://YOUR-IP-PROXY-REVERSE/grafana