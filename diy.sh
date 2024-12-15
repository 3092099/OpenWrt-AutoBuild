#!/usr/bin/env bash

repo=${1:-openwrt}
owner=${2:-Test-Router}

echo "OpenWrt DIY script"

echo "repo: ${repo}; owner: ${owner};"

# Modify default IP
if [ "${CONFIG_OWNER}" = "Full-Router" ]; then
  sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/files/bin/config_generate
elif [ "${CONFIG_OWNER}" = "Main-Router" ]; then
  sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/files/bin/config_generate
else
  sed -i 's/192.168.1.1/192.168.1.11/g' package/base-files/files/bin/config_generate
  exit 1
fi

# Modify hostname
sed -i 's/OpenWrt/OpenWrt-GXNAS/g' package/base-files/files/bin/config_generate

# Modify timezone
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# Modify banner
if [ "${repo}" = "lede" ]; then
  cp lede.banner package/base-files/files/etc/banner
else
  cp openwrt.banner package/base-files/files/etc/banner
fi

# lede    ==> ${defaultsettings}
# openwrt ==> feeds/ing/default-settings
defaultsettings=*/*/default-settings
[ "${repo}" = "openwrt" ] && language=zh_cn || language=zh_Hans

# 设置密码为空（安装固件时无需密码登陆，然后自己修改想要的密码）
sed -i '/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF./d' ${defaultsettings}/files/zzz-default-settings

# Modify the version number
sed -i "s/OpenWrt /${owner} build $(TZ=UTC-8 date "+%Y.%m.%d") by GXNAS /g" ${defaultsettings}/files/zzz-default-settings
sed -i "s/LEDE /${owner} build $(TZ=UTC-8 date "+%Y.%m.%d") by GXNAS /g" ${defaultsettings}/files/zzz-default-settings

# Remvoe openwrt_ing
sed -i '/sed -i "s\/# \/\/g" \/etc\/opkg\/distfeeds.conf/a\sed -i "\/openwrt_ing\/d" \/etc\/opkg\/distfeeds.conf' ${defaultsettings}/files/zzz-default-settings

# Modify maximum connections
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# Modify default theme
sed -i "s/bootstrap/argon/g" feeds/luci/collections/luci/Makefile
sed -i "s/bootstrap/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
  echo 'CONFIG_KERNEL_BUILD_USER="${owner}"' >>.config ||
  sed -i "s|\(CONFIG_KERNEL_BUILD_USER=\).*|\1$\"${owner}\"|" .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
  echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
  sed -i 's|\(CONFIG_KERNEL_BUILD_DOMAIN=\).*|\1$"GitHub Actions"|' .config

# 设置ttyd免帐号登录
sed -i 's/\/bin\/login/\/bin\/login -f root/' feeds/packages/utils/ttyd/files/ttyd.config

# Modify app list
sed -i 's|admin/vpn/|admin/services/|g' package/feeds/luci/luci-app-ipsec-vpnd/root/usr/share/luci/menu.d/luci-app-ipsec-vpnd.json   # grep "IPSec VPN Server" -rl ./
sed -i 's/"vpn"/"services"/g; s/"VPN"/"Services"/g' package/feeds/ing/luci-app-zerotier/luasrc/controller/zerotier.lua               # grep "ZeroTier" -rl ./
sed -i 's/"Argon 主题设置"/"主题设置"/g' package/feeds/ing/luci-app-argon-config/po/*/argon-config.po                                 # grep "Argon 主题设置" -rl ./

# Info
# luci-app-netdata 1.33.1汉化版 导致 web升级后 报错: /usr/lib/lua/luci/dispatcher.lua:220: /etc/config/luci seems to be corrupt, unable to find section 'main'
