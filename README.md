# Proxy Reverso Nginx

## The settings for some apps are in the conf folder

> You will configure only this file below:

## Proxy by path prefix URL
File example: proxynginxpr.yaml
```
nginxprefix:
  portnginxprefix: 80
  hosts:
    - name: 'grafana'
      address:
        - hostip: 192.168.15.7 #<IP-YOUR-APP>
          port: 3000 #PORT APP
      pathnginx: "grafana" #stay /app does not include / OK !? just the name
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
- You will access: http://YOUR-IP-PROXY-REVERSE/grafana

## Proxy by server port nginx
File example: proxynginxpr.yaml
```
hostprn:
  hosts:
    - name: 'minio' #Enter the name of the app
      portprn: 81 #Enter the port of the nginx server
      address:
        - hostip: 192.168.15.3 #Enter the port of the ip app
          port: 9000 #Enter the port of the port app
      prefixapp: "/" #Enter the port of the path

    - name: 'jenkins'
      portprn: 82
      address:
        - hostip: 192.168.15.3 
          port: 8080
      prefixapp: "/"
```
- You will access: http://YOUR-IP-PROXY-REVERSE:80/
- You will access: http://YOUR-IP-PROXY-REVERSE:81/
- You will access: http://YOUR-IP-PROXY-REVERSE:82/

> Below is docker-compose.yaml mapping the proxynginxpr.yaml configuration file.

```
version: '2'
services:
  nginx:
    image: didevlab/proxy-reverse-nginx:1.0
    container_name: nginx-proxy-reverso
    restart: always
    network_mode: host
    volumes:
      - ./proxynginxpr.yaml:/proxynginxpr.yaml
    environment:
      TZ: America/Sao_Paulo
```

## Proxy by Stream server port nginx
File example: proxynginxpr.yaml
```
# #CUSTON SERVER BY PORT NGINX STREAM
hostprnstream:
  hosts:
    - name: 'mongodb'
      portprn: 27017
      address:
        - hostip: 192.168.15.3
          port: 27017

    - name: 'redis'
      portprn: 6379
      address:
        - hostip: 192.168.15.3
          port: 6379
    
    - name: 'mysql'
      portprn: 3306
      address:
        - hostip: 192.168.15.3
          port: 3306
```


```
docker-compose up -d
```
- You will access: http://YOUR-IP-PROXY-REVERSE/grafana