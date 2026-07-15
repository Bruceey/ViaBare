#!/bin/bash
set -e

[ -z "$USER_DOMAIN" ] && echo "用法: $0 <域名>" && exit 1

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


apt update && apt -y upgrade
apt-get -y install --no-install-recommends wget gnupg ca-certificates lsb-release curl git

# 1. 定义你的 CF 优选 IP 数组（全局变量）
ips=("172.64.53.134" "172.64.52.107" "172.64.52.188" "172.64.42.208")

# 2. 定义 shuffle 赋值函数
export_shuffled_cf_ips() {
    # 获取参数 1，如果为空则默认值为 3
    local max_assign="${1:-3}"
    local len=${#ips[@]}
    
    # 健壮性检查：如果数组为空，直接返回
    if [ $len -eq 0 ]; then
        echo "Error: ips 数组为空！" >&2
        return 1
    fi

    # 生成打乱后的索引数组
    local shuffled_indices=($(seq 0 $((len - 1)) | shuf))

    # 循环赋值并 export
    for ((i=0; i<max_assign && i<len; i++)); do
        local rand_idx=${shuffled_indices[$i]}
        local ip_val="${ips[$rand_idx]}"
        local var_name="CF_IP$((i+1))"
        
        # 导出变量
        export "$var_name=$ip_val"
    done
}

# 3. 生成 3个 cfip
# export CF_IP1=xxx
# export CF_IP2=xxx
# export CF_IP3=xxx
export_shuffled_cf_ips

project_dir=ViaBare
rm -rf $project_dir /data/www $HOME/subscribe.txt 
git clone --depth 1 https://github.com/Bruceey/ViaBare.git
cd $project_dir

# mkdir -p $project_dir
# curl -fsSL https://github.com/Bruceey/ViaBare/archive/refs/heads/main.tar.gz | tar -xz --strip-components=1 -C $project_dir
# cd $project_dir

# export USER_DOMAIN
export UUID=$(uuidgen | tr 'A-F' 'a-f')
export PROXY_PATH=$(LC_ALL=C tr -dc 'A-Za-z0-9_-' < /dev/urandom | head -c 16)
# openresty配置
export URL_TOKEN=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)

. setup.sh

# cd /
# rm -rf $project_dir

green "=========================================="
echo "通用订阅链接：https://${USER_DOMAIN}/subscribe?token=${URL_TOKEN}" | tee -a $HOME/subscribe.txt
echo "安卓端sing-box订阅链接：https://${USER_DOMAIN}/subscribe?token=${URL_TOKEN}&os=android" | tee -a $HOME/subscribe.txt
echo "pc端sing-box订阅链接：https://${USER_DOMAIN}/subscribe?token=${URL_TOKEN}&os=pc" | tee -a $HOME/subscribe.txt
blue "后续可在路径 $HOME/subscribe.txt 中找到订阅链接"
green "=========================================="