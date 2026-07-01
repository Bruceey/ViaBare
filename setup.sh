#!/bin/bash

apt update && apt -y upgrade
apt-get -y install --no-install-recommends wget gnupg ca-certificates lsb-release curl

# 1. 相关软件安装
# sing-box密钥仓库
mkdir -p /etc/apt/keyrings &&
   curl -fsSL https://sing-box.app/gpg.key -o /etc/apt/keyrings/sagernet.asc &&
   chmod a+r /etc/apt/keyrings/sagernet.asc &&
   echo '
Types: deb
URIs: https://deb.sagernet.org/
Suites: *
Components: *
Enabled: yes
Signed-By: /etc/apt/keyrings/sagernet.asc
' | tee /etc/apt/sources.list.d/sagernet.sources

# openresty密钥仓库，自动适配 amd64 和 arm64
wget -O - https://openresty.org/package/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/openresty.gpg
_arch=$(dpkg --print-architecture)
echo "deb [arch=$_arch signed-by=/usr/share/keyrings/openresty.gpg] https://openresty.org/package/$([ "$_arch" = "arm64" ] && echo "arm64/")ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list > /dev/null

# warp-svc密钥仓库
# Add cloudflare gpg key
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

apt-get update
apt-get -y install openresty sing-box cloudflare-warp

warp-cli registration new
warp-cli mode proxy
warp-cli connect

# 2. 生成必要的文件
# 此时默认用户是sing-box:sing-box
mkdir -p /var/log
touch /var/log/sing-box.log
chown sing-box:sing-box /var/log/sing-box.log

sub_dir=/data/www/subscribe
mkdir /data
cp -r ./www /data/
mkdir $sub_dir

# 3. 生成服务配置文件
export UUID=$(uuidgen | tr 'A-F' 'a-f')
export PROXY_PATH=$(LC_ALL=C tr -dc 'A-Za-z0-9_-' < /dev/urandom | head -c 16)
# openresty配置
export URL_TOKEN=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)


# 生成自签证书
ssl_dir=/etc/ssl/${USER_DOMAIN}
mkdir -p $ssl_dir
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout $ssl_dir/private.key \
  -out $ssl_dir/cert.pem \
  -subj "/CN=${USER_DOMAIN}" \
  -addext "subjectAltName=DNS:${USER_DOMAIN},DNS:*.${USER_DOMAIN}"


export CERT_PATH=$ssl_dir/cert.pem
export KEY_PATH=$ssl_dir/private.key

envsubst '$UUID $PROXY_PATH' < config/sing-box/server/warp-svc.json > /etc/sing-box/config.json
envsubst '$USER_DOMAIN $PROXY_PATH $URL_TOKEN $CERT_PATH $KEY_PATH' < ./config/openresty/nginx.conf > /usr/local/openresty/nginx/conf/nginx.conf

envsubst '$USER_DOMAIN $PROXY_PATH $UUID' < ./config/sing-box/client/android.json > $sub_dir/android.json
envsubst '$USER_DOMAIN $PROXY_PATH $UUID' < ./config/sing-box/client/pc.json > $sub_dir/pc.json
envsubst '$USER_DOMAIN $PROXY_PATH $UUID' < ./config/sing-box/client/universal.txt > $sub_dir/universal.txt




chown -R nobody:nogroup /data
chmod -R 755 /data/www
find /data/www -type f -exec chmod 644 {} +


systemctl restart sing-box.service
systemctl reload openresty.service


