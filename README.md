# proxy-reverso-nginx

## The settings for some assp are in the conf folder

### You will configure only this file below:

File: proxynginxpr.yaml
```
portnginx: 80
nginx:
  hosts:
    - name: 'nginx' 
      address: 
        - hostip: 127.0.0.1
          port: 80
        - hostip: 127.0.0.1
          port: 80
      pathnginx: "nginx" #stay /nginx does not include / OK !? just the name
      prefixapp: "/"

    - name: 'grafana'
      address:
        - hostip: <IP-YOUR-GRAFANA>
          port: 3000
      pathnginx: "grafana" #stay /grafana does not include / OK !? just the name
      prefixapp: "/"
```
