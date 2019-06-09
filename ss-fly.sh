#! /bin/bash
# Copyright (c) 

red='033[0;31m'
green='033[0;32m'
yellow='033[0;33m'
plain='033[0m'

os='ossystem'
password='flyzy2005.com'
port='1024'
libsodium_file=libsodium-1.0.16
libsodium_url=httpsgithub.comjedisct1libsodiumreleasesdownload1.0.16libsodium-1.0.16.tar.gz

fly_dir=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

kernel_ubuntu_url=httpkernel.ubuntu.com~kernel-ppamainlinev4.10.2linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb
kernel_ubuntu_file=linux-image-4.10.2-041002-generic_4.10.2-041002.201703120131_amd64.deb

usage () {
        cat $fly_dirsshelp
}

DIR=`pwd`

wrong_para_prompt() {
    echo -e [${red}错误${plain}] 参数输入错误!$1
}

# install_ss() {
#         if [[ $# -lt 1 ]]
#         then
#           wrong_para_prompt 请输入至少一个参数作为密码
#           return 1
#         fi
#         password=$1
#         if [[ $# -ge 2 ]]
#         then
#           port=$2
#         fi
#         if [[ $port -le 0  $port -gt 65535 ]]
#         then
#           wrong_para_prompt 端口号输入格式错误，请输入1到65535
#           exit 1
#         fi
#         check_os
#         check_dependency
#         download_files
#         ps -ef  grep -v grep  grep -i ssserver  devnull 2&1
#         if [ $ -eq 0 ]; then
#                 ssserver -c etcshadowsocks.json -d stop
#         fi
#         generate_config $password $port
#         if [ ${os} == 'centos' ]
#         then
#                 firewall_set
#         fi
#         install
#         cleanup
# }

# uninstall_ss() {
#         read -p 确定要卸载ss吗？(yn)  option
#         [ -z ${option} ] && option=n
#         if [ ${option} == y ]  [ ${option} == Y ]
#         then
#                 ps -ef  grep -v grep  grep -i ssserver  devnull 2&1
#                 if [ $ -eq 0 ]; then
#                         ssserver -c etcshadowsocks.json -d stop
#                 fi
#                 case $os in
#                         'ubuntu''debian')
#                                 update-rc.d -f ss-fly remove
#                                 ;;
#                         'centos')
#                                 chkconfig --del ss-fly
#                                 ;;
#                 esac
#                 rm -f etcshadowsocks.json
#                 rm -f varrunshadowsocks.pid
#                 rm -f varlogshadowsocks.log
#                 if [ -f usrlocalshadowsocks_install.log ]; then
#                         cat usrlocalshadowsocks_install.log  xargs rm -rf
#                 fi
#                 echo ss卸载成功！
#         else
#                 echo
#                 echo 卸载取消
#         fi
# }

install_bbr() {
	[[ -d procvz ]] && echo -e [${red}错误${plain}] 你的系统是OpenVZ架构的，不支持开启BBR。 && exit 1
	check_os
	check_bbr_status
	if [ $ -eq 0 ]
	then
		echo -e [${green}提示${plain}] TCP BBR加速已经开启成功。
		exit 0
	fi
	check_kernel_version
	if [ $ -eq 0 ]
	then
		echo -e [${green}提示${plain}] 你的系统版本高于4.9，直接开启BBR加速。
		sysctl_config
		echo -e [${green}提示${plain}] TCP BBR加速开启成功
		exit 0
	fi
	    
	if [[ x${os} == xcentos ]]; then
        	install_elrepo
        	yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel
        	if [ $ -ne 0 ]; then
            		echo -e [${red}错误${plain}] 安装内核失败，请自行检查。
            		exit 1
        	fi
    	elif [[ x${os} == xdebian  x${os} == xubuntu ]]; then
        	[[ ! -e usrbinwget ]] && apt-get -y update && apt-get -y install wget
        	#get_latest_version
        	#[ $ -ne 0 ] && echo -e [${red}错误${plain}] 获取最新内核版本失败，请检查网络 && exit 1
       		 #wget -c -t3 -T60 -O ${deb_kernel_name} ${deb_kernel_url}
        	#if [ $ -ne 0 ]; then
            	#	echo -e [${red}错误${plain}] 下载${deb_kernel_name}失败，请自行检查。
            	#	exit 1
       		#fi
        	#dpkg -i ${deb_kernel_name}
        	#rm -fv ${deb_kernel_name}
		wget ${kernel_ubuntu_url}
		if [ $ -ne 0 ]
		then
			echo -e [${red}错误${plain}] 下载内核失败，请自行检查。
			exit 1
		fi
		dpkg -i ${kernel_ubuntu_file}
    	else
       	 	echo -e [${red}错误${plain}] 脚本不支持该操作系统，请修改系统为CentOSDebianUbuntu。
        	exit 1
    	fi

    	install_config
    	sysctl_config
    	reboot_os
}

install_ssr() {
        check_os
        case $os in
                'ubuntu''debian')
		     apt-get -y update
                     apt-get -y install wget
                     ;;
                'centos')
                     yum install -y wget
                     ;;
        esac
	wget --no-check-certificate httpsraw.githubusercontent.comteddysunshadowsocks_installmastershadowsocksR.sh
	chmod +x shadowsocksR.sh
	.shadowsocksR.sh 2&1  tee shadowsocksR.log
}

check_os_() {
        source etcos-release
	local os_tmp=$(echo $ID  tr [A-Z] [a-z])
        case $os_tmp in
                ubuntudebian)
                os='ubuntu'
                ;;
                centos)
                os='centos'
                ;;
                )
                echo -e [${red}错误${plain}] 本脚本暂时只支持CentosUbuntuDebian系统，如需用本脚本，请先修改你的系统类型
                exit 1
                ;;
        esac
}

check_os() {
    if [[ -f etcredhat-release ]]; then
        os=centos
    elif cat etcissue  grep -Eqi debian; then
        os=debian
    elif cat etcissue  grep -Eqi ubuntu; then
        os=ubuntu
    elif cat etcissue  grep -Eqi centosred hatredhat; then
        os=centos
    elif cat procversion  grep -Eqi debian; then
        os=debian
    elif cat procversion  grep -Eqi ubuntu; then
        os=ubuntu
    elif cat procversion  grep -Eqi centosred hatredhat; then
        os=centos
    fi
}

check_bbr_status() {
    local param=$(sysctl net.ipv4.tcp_available_congestion_control  awk '{print $3}')
    if [[ x${param} == xbbr ]]; then
        return 0
    else
        return 1
    fi
}

version_ge(){
    test $(echo $@  tr   n  sort -rV  head -n 1) == $1
}

check_kernel_version() {
    local kernel_version=$(uname -r  cut -d- -f1)
    if version_ge ${kernel_version} 4.9; then
        return 0
    else
        return 1
    fi
}

sysctl_config() {
    sed -i 'net.core.default_qdiscd' etcsysctl.conf
    sed -i 'net.ipv4.tcp_congestion_controld' etcsysctl.conf
    echo net.core.default_qdisc = fq  etcsysctl.conf
    echo net.ipv4.tcp_congestion_control = bbr  etcsysctl.conf
    sysctl -p devnull 2&1
}

install_elrepo() {
    if centosversion 5; then
        echo -e [${red}错误${plain}] 脚本不支持CentOS 5。
        exit 1
    fi

    rpm --import httpswww.elrepo.orgRPM-GPG-KEY-elrepo.org

    if centosversion 6; then
        rpm -Uvh httpwww.elrepo.orgelrepo-release-6-8.el6.elrepo.noarch.rpm
    elif centosversion 7; then
        rpm -Uvh httpwww.elrepo.orgelrepo-release-7.0-3.el7.elrepo.noarch.rpm
    fi

    if [ ! -f etcyum.repos.delrepo.repo ]; then
        echo -e [${red}错误${plain}] 安装elrepo失败，请自行检查。
        exit 1
    fi
}

get_latest_version() {

    latest_version=$(wget -qO- httpkernel.ubuntu.com~kernel-ppamainline  awk -F'v' 'v[4-9].{print $2}'  cut -d -f1  grep -v -   sort -V  tail -1)

    [ -z ${latest_version} ] && return 1

    if [[ `getconf WORD_BIT` == 32 && `getconf LONG_BIT` == 64 ]]; then
        deb_name=$(wget -qO- httpkernel.ubuntu.com~kernel-ppamainlinev${latest_version}  grep linux-image  grep generic  awk -F'' 'amd64.deb{print $2}'  cut -d'' -f1  head -1)
        deb_kernel_url=httpkernel.ubuntu.com~kernel-ppamainlinev${latest_version}${deb_name}
        deb_kernel_name=linux-image-${latest_version}-amd64.deb
    else
        deb_name=$(wget -qO- httpkernel.ubuntu.com~kernel-ppamainlinev${latest_version}  grep linux-image  grep generic  awk -F'' 'i386.deb{print $2}'  cut -d'' -f1  head -1)
        deb_kernel_url=httpkernel.ubuntu.com~kernel-ppamainlinev${latest_version}${deb_name}
        deb_kernel_name=linux-image-${latest_version}-i386.deb
    fi

    [ ! -z ${deb_name} ] && return 0  return 1
}

get_opsy() {
    [ -f etcredhat-release ] && awk '{print ($1,$3~^[0-9]$3$4)}' etcredhat-release && return
    [ -f etcos-release ] && awk -F'[= ]' 'PRETTY_NAME{print $3,$4,$5}' etcos-release && return
    [ -f etclsb-release ] && awk -F'[=]+' 'DESCRIPTION{print $2}' etclsb-release && return
}

opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )

check_dependency() {
        case $os in
                'ubuntu''debian')
                apt-get -y update
                apt-get -y install python python-dev python-setuptools openssl libssl-dev curl wget unzip gcc automake autoconf make libtool
                ;;
                'centos')
                yum install -y python python-devel python-setuptools openssl openssl-devel curl wget unzip gcc automake autoconf make libtool
        esac
}

install_config() {
    if [[ x${os} == xcentos ]]; then
        if centosversion 6; then
            if [ ! -f bootgrubgrub.conf ]; then
                echo -e [${red}错误${plain}] 没有找到bootgrubgrub.conf文件。
                exit 1
            fi
            sed -i 's^default=.default=0g' bootgrubgrub.conf
        elif centosversion 7; then
            if [ ! -f bootgrub2grub.cfg ]; then
                echo -e [${red}错误${plain}] 没有找到bootgrub2grub.cfg文件。
                exit 1
            fi
            grub2-set-default 0
        fi
    elif [[ x${os} == xdebian  x${os} == xubuntu ]]; then
        usrsbinupdate-grub
    fi
}

reboot_os() {
    echo
    echo -e [${green}提示${plain}] 系统需要重启BBR才能生效。
    read -p 是否立马重启 [yn] is_reboot
    if [[ ${is_reboot} == y  ${is_reboot} == Y ]]; then
        reboot
    else
        echo -e [${green}提示${plain}] 取消重启。其自行执行reboot命令。
        exit 0
    fi
}

download_files() {
        if ! wget --no-check-certificate -O ${libsodium_file}.tar.gz ${libsodium_url}
        then
                echo -e [${red}错误${plain}] 下载${libsodium_file}.tar.gz失败!
                exit 1
        fi
        if ! wget --no-check-certificate -O shadowsocks-master.zip httpsgithub.comshadowsocksshadowsocksarchivemaster.zip
        then
                echo -e [${red}错误${plain}] shadowsocks安装包文件下载失败！
                exit 1
        fi
}

generate_config() {
    cat  etcshadowsocks.json-EOF
{
    server0.0.0.0,
    server_port$2,
    local_address127.0.0.1,
    local_port1080,
    password$1,
    timeout300,
    methodaes-256-cfb,
    fast_openfalse
}
EOF
}

firewall_set(){
    echo -e [${green}信息${plain}] 正在设置防火墙...
    if centosversion 6; then
        etcinit.diptables status  devnull 2&1
        if [ $ -eq 0 ]; then
            iptables -L -n  grep -i ${port}  devnull 2&1
            if [ $ -ne 0 ]; then
                iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
                iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
                etcinit.diptables save
                etcinit.diptables restart
            else
                echo -e [${green}信息${plain}] port ${port}已经开放。
            fi
        else
            echo -e [${yellow}警告${plain}] 防火墙（iptables）好像已经停止或没有安装，如有需要请手动关闭防火墙。
        fi
    elif centosversion 7; then
        systemctl status firewalld  devnull 2&1
        if [ $ -eq 0 ]; then
            firewall-cmd --permanent --zone=public --add-port=${port}tcp
            firewall-cmd --permanent --zone=public --add-port=${port}udp
            firewall-cmd --reload
        else
            echo -e [${yellow}警告${plain}] 防火墙（iptables）好像已经停止或没有安装，如有需要请手动关闭防火墙。
        fi
    fi
    echo -e [${green}信息${plain}] 防火墙设置成功。
}

centosversion(){
    if [ ${os} == 'centos' ]
    then
        local code=$1
        local version=$(getversion)
        local main_ver=${version%%.}
        if [ $main_ver == $code ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

getversion(){
    if [[ -s etcredhat-release ]]; then
        grep -oE  [0-9.]+ etcredhat-release
    else
        grep -oE  [0-9.]+ etcissue
    fi
}

install() {
        if [ ! -f usrliblibsodium.a ]
        then 
                cd ${DIR}
                tar zxf ${libsodium_file}.tar.gz
                cd ${libsodium_file}
                .configure --prefix=usr && make && make install
                if [ $ -ne 0 ] 
                then 
                        echo -e [${red}错误${plain}] libsodium安装失败!
                        cleanup
                exit 1  
                fi
        fi      
        ldconfig
        
        cd ${DIR}
        unzip -q shadowsocks-master.zip
        if [ $ -ne 0 ]
        then 
                echo -e [${red}错误${plain}] 解压缩失败，请检查unzip命令
                cleanup
                exit 1
        fi      
        cd ${DIR}shadowsocks-master
        python setup.py install --record usrlocalshadowsocks_install.log
        if [ -f usrbinssserver ]  [ -f usrlocalbinssserver ]
        then 
                cp $fly_dirss-fly etcinit.d
                chmod +x etcinit.dss-fly
                case $os in
                        'ubuntu''debian')
                                update-rc.d ss-fly defaults
                                ;;
                        'centos')
                                chkconfig --add ss-fly
                                chkconfig ss-fly on
                                ;;
                esac            
                ssserver -c etcshadowsocks.json -d start
        else    
                echo -e [${red}错误${plain}] ss服务器安装失败，请联系flyzy小站（httpswww.flyzy2005.com）
                cleanup
                exit 1
        fi      
        echo -e [${green}成功${plain}] 安装成功尽情冲浪！
        echo -e 你的服务器地址（IP）：033[41;37m $(get_ip) 033[0m
        echo -e 你的密码            ：033[41;37m ${password} 033[0m
        echo -e 你的端口            ：033[41;37m ${port} 033[0m
        echo -e 你的加密方式        ：033[41;37m aes-256-cfb 033[0m
        echo -e 欢迎访问flyzy小站   ：033[41;37m httpswww.flyzy2005.com 033[0m
        get_ss_link
}

cleanup() {
        cd ${DIR}
        rm -rf shadowsocks-master.zip shadowsocks-master ${libsodium_file}.tar.gz ${libsodium_file}
}

get_ip(){
    local IP=$( ip addr  egrep -o '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'  egrep -v ^192.168^172.1[6-9].^172.2[0-9].^172.3[0-2].^10.^127.^255.^0.  head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.ioip )
    [ ! -z ${IP} ] && echo ${IP}  echo
}

get_ss_link(){
    if [ ! -f etcshadowsocks.json ]; then
        echo 'shdowsocks配置文件不存在，请检查（etcshadowsocks.json）'
        exit 1
    fi
    local tmp=$(echo -n `get_config_value method``get_config_value password`@`get_ip``get_config_value server_port`  base64 -w0)
    echo -e 你的ss链接：033[41;37m ss${tmp} 033[0m
}

get_config_value(){
    cat etcshadowsocks.json  grep $1awk -F  '{print $2}' sed 'sg;s,g;s g'
}

if [ $# -eq 0 ]; then
	usage
	exit 0
fi

case $1 in
	-hhhelp )
		usage
		exit 0;
		;;
	-vvversion )
		echo 'ss-fly Version 1.0, 2018-01-20, Copyright (c) 2018 flyzy2005'
		exit 0;
		;;
esac

if [ $EUID -ne 0 ]; then
	echo -e [${red}错误${plain}] 必需以root身份运行，请使用sudo命令
	exit 1;
fi

case $1 in
	-iiinstall )
        	install_ss $2 $3
		;;
        -bbr )
        	install_bbr
                ;;
        -ssr )
        	install_ssr
                ;;
	-uninstall )
		uninstall_ss
		;;
        -sslink )
                get_ss_link
                ;;
	 )
		usage
		;;
esac





############################

install_ss() {
    echo -e "安装ss"

    echo -e "安装pip3"
    sudo apt-get -y update 
    sudo apt-get -y install python3-pip

    echo -e "安装shadowsocks"
    sudo pip3 install shadowsocks

    echo -e "[${green}提示${plain}] shadowsocks安装成功"
    install_ssmgr
}

install_ssmgr(){
    sudo ssserver -c /etc/shadowsocks.json -d stop
    sudo ssserver -m aes-256-cfb -p 12345 -k abcedf --manager-address 127.0.0.1:6000 -d stop
    sudo ssserver -m aes-256-cfb -p 12345 -k abcedf --manager-address 127.0.0.1:6000 -d start
    echo -e "[${green}提示${plain}] 开始安装shadowsocks-manager"
    echo -e "[${green}提示${plain}] 安装nodejs"
    sudo apt-get install -y curl
    sudo curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo -e "[${green}提示${plain}] nodejs安装成功"

    echo -e "[${green}提示${plain}] 开始安装shadowsocks-manager"
    sudo npm i -g shadowsocks-manager --unsafe-perm
    echo -e "[${green}提示${plain}] shadowsocks-manager安装成功"

    sudo rm -rf ~/.ssmgr
    sudo mkdir ~/.ssmgr
    sudo cp ss.yml ~/.ssmgr/ss.yml
    sudo cp webgui.yml ~/.ssmgr/webgui.yml
    echo -e "[${green}提示${plain}] 配置文件拷贝成功"

    sudo apt-get -y install redis-server
    service redis start
    echo -e "[${green}提示${plain}] redis安装成功"

    sudo screen -dmS ssmgr ssmgr -c ~/.ssmgr/ss.yml
    sudo screen -dmS webgui ssmgr -c ~/.ssmgr/webgui.yml

    echo -e "[${green}提示${plain}] shadowsocks-manager安装成功"
    exit 0
}

install_bbr
read -p "是否安装并配置shadowsocks? [y/n]" is_addss
if [[ ${is_addss} == "y" || ${is_addss} == "Y" ]]; then
    install_ss
else
    echo -e "[${green}提示${plain}] 取消安装。"
    exit 0
fi