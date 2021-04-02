# Proxy Reverso Nginx

## The settings for some apps are in the conf folder

> You will configure only this file below:

File example: proxynginxpr.yaml
```
portnginx: 80
nginx:
  hosts:
    - name: 'grafana'
      address:
        - hostip: 192.168.15.7 #<IP-YOUR-GRAFANA>
          port: 3000 #PORT GRAFANA
      pathnginx: "grafana" #stay /grafana does not include / OK !? just the name
      prefixapp: "/"

    - name: 'portainer'
      address:
        - hostip: 192.168.15.3 
          port: 9000 
      pathnginx: "portainer" 
      prefixapp: "/"

    - name: 'kibana'
      address:
        - hostip: 192.168.15.3 
          port: 5601
      pathnginx: "kibana" 
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