sed -i -r 's/(listen .*443)/\1;#/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g' /etc/nginx/sites-available/yitsao.com.conf  \
sudo nginx -t sudo nginx \
certbot certonly --webroot -d yitsao.com -d www.yitsao.com --email 2805566898@qq.com -w /var/www/_letsencrypt -n --agree-tos --force-renewal    \
sed -i -r 's/#?;#//g' /etc/nginx/sites-available/yitsao.com.conf         \
sudo nginx -t sudo nginx -s reload \
echo -e '#!/bin/bash\nnginx -t systemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh   \
sudo chmod a+x /etc/letsencrypt/renewal-hooks/post/nginx-reload.sh \
sudo nginx -t sudo nginx -s reload \