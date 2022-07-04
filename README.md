# jenkins-https
https configured Jenkins container with Let's Encrypt SSL certificate.


## Usage
On Amazon Linux, run the following command:
```
curl https://raw.githubusercontent.com/3baaady07/nginx-proxy-setup/main/nginx-proxy-setup.sh > nginx-proxy-setup.sh
chmod 0755 nginx-proxy-setup.sh
```

Then, run the following command replacing values as needed:
```
./nginx-proxy-setup.sh "example@email.tld"
```