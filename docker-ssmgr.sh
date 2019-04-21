#! /bin/bash
# Copyright (c) 2019 zhuxindong

kernel_ubuntu_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.2/linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb"
kernel_ubuntu_file="linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'



install_ss() {
    echo -e "安装ss"

    echo -e "安装pip3"
    apt-get -y update 
    apt-get -y install python3-pip

    echo -e "安装shadowsocks"
    pip3 install shadowsocks

    echo -e "[${green}提示${plain}] shadowsocks安装成功"
    install_ssmgr
}

install_ssmgr(){
    ssserver -c /etc/shadowsocks.json -d stop
    ssserver -m aes-256-cfb -p 12345 -k abcedf --manager-address 127.0.0.1:6000 -d stop
    ssserver -m aes-256-cfb -p 12345 -k abcedf --manager-address 127.0.0.1:6000 -d start
    echo -e "[${green}提示${plain}] 开始安装shadowsocks-manager"
    echo -e "[${green}提示${plain}] 安装nodejs"
    apt-get install -y curl
    curl -sL https://deb.nodesource.com/setup_10.x | bash -
    apt-get install -y nodejs
    echo -e "[${green}提示${plain}] nodejs安装成功"

    echo -e "[${green}提示${plain}] 开始安装shadowsocks-manager"
    npm i -g shadowsocks-manager --unsafe-perm
    echo -e "[${green}提示${plain}] shadowsocks-manager安装成功"

    rm -rf ~/.ssmgr
    mkdir ~/.ssmgr
    cp ss.yml ~/.ssmgr/ss.yml
    cp webgui.yml ~/.ssmgr/webgui.yml
    echo -e "[${green}提示${plain}] 配置文件拷贝成功"

    apt-get -y install redis-server
    echo -e "[${green}提示${plain}] redis安装成功"

    screen -dmS ssmgr ssmgr -c ~/.ssmgr/ss.yml
    screen -dmS webgui ssmgr -c ~/.ssmgr/webgui.yml

    echo -e "[${green}提示${plain}] shadowsocks-manager安装成功"
    exit 0
}



# 开启bbr加速end

install_ss