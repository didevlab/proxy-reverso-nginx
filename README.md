# proxy-reverso-nginx

## The settings for some assp are in the conf folder

### You will configure only this file below:

File: proxynginxpr.yaml
```
portnginx: 80
nginx:
  hosts:
    - name: 'grafana'
      address:
        - hostip: 192.168.15.7 #<IP-YOUR-GRAFANA>
          port: 3000
      pathnginx: "grafana" #stay /grafana does not include / OK !? just the name
      prefixapp: "/"
```
You will access: http://YOUR-IP-PROXY-REVERSE/grafana