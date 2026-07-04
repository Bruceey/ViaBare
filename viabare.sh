#!/bin/bash
set -e

[ -z "$1" ] && echo "用法: $0 <域名>" && exit 1

if [ "$EUID" -ne 0 ]; then     # 如果（if）当前运行脚本的用户不是 root（EUID不等于0）
  exec sudo "$0" "$@"          # 那么：立刻用 sudo 重新执行我自己，并把刚才输入的参数原封不动传过去
fi                             # 结束判断


export LANG=en_US.UTF-8
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;36m'
bblue='\033[0;34m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
readp(){ read -p "$(yellow "$1")" $2;}

project_dir=/tmp/ViaBare
mkdir -p $project_dir
curl -fsSL https://github.com/Bruceey/ViaBare/archive/refs/heads/main.tar.gz | tar -xz --strip-components=1 -C $project_dir
cd $project_dir

export USER_DOMAIN=$1
export UUID=$(uuidgen | tr 'A-F' 'a-f')
export PROXY_PATH=$(LC_ALL=C tr -dc 'A-Za-z0-9_-' < /dev/urandom | head -c 16)
# openresty配置
export URL_TOKEN=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)

. setup.sh

cd /
rm -rf $project_dir

green "=========================================="
echo "安卓端sing-box订阅链接：https://${USER_DOMAIN}/subscribe?token=${URL_TOKEN}&os=android" | tee -a $HOME/subscribe.txt
echo "pc端sing-box订阅链接：https://${USER_DOMAIN}/subscribe?token=${URL_TOKEN}&os=pc" | tee -a $HOME/subscribe.txt
echo "后续可在路径$HOME/subscribe.txt中找到订阅链接"
green "=========================================="