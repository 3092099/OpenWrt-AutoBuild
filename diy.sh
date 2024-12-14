#!/usr/bin/env bash

repo=${1:-openwrt}
owner=${2:-Test-Router}

echo "OpenWrt DIY script"

echo "repo: ${repo}; owner: ${owner};"

# Modify default IP
case "${owner}" in
    "Full-Router"|"Main-Router")
        sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/files/bin/config_generate
        ;;
    "Side-Routes"|"Simplified-Router"|"Test-Router")
        sed -i 's/192.168.1.1/192.168.1.11/g' package/base-files/files/bin/config_generate
        ;;
    *)
        # Handle unexpected values or errors
        echo "Invalid owner: ${owner}"
        exit 1
        ;;
esac

# Modify hostname
sed -i 's/OpenWrt/OpenWrt-GXNAS/g' package/base-files/files/bin/config_generate

# Modify timezone
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# Modify banner
if [ "${repo}" = "lede" ]; then
  cat >package/base-files/files/etc/banner <<EOF
     _________
    /        /\      _    ___ ___  ___
   /  LE    /  \    | |  | __|   \| __|
  /    DE  /    \   | |__| _|| |) | _|
 /________/  LE  \  |____|___|___/|___|        Lede-${owner} By GXNAS
 \        \   DE /
  \    LE  \    /  -------------------------------------------
   \  DE    \  /    %D %V, %C
    \________\/    -------------------------------------------

EOF
  fi
else
  cat >package/base-files/files/etc/banner <<EOF
 ██████╗ ██████╗ ███████╗███╗   ██╗██╗    ██╗██████╗ ████████╗
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██║    ██║██╔══██╗╚══██╔══╝
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║ █╗ ██║██████╔╝   ██║   
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║███╗██║██╔══██╗   ██║   
╚██████╔╝██║     ███████╗██║ ╚████║╚███╔███╔╝██║  ██║   ██║   
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   
  -------------------------------------------
  		%D %V, %C      OpenWrt-${owner} By GXNAS
  -------------------------------------------
EOF
fi

# lede    ==> ${defaultsettings}
# openwrt ==> feeds/ing/default-settings
defaultsettings=*/*/default-settings
[ "${repo}" = "openwrt" ] && language=zh_cn || language=zh_Hans

# Modify password to Null
sed -i '/CYXluq4wUazHjmCDBCqXF/d' ${defaultsettings}/files/zzz-default-settings

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

# Modify kernel and rootfs size
#sed -i 's/CONFIG_TARGET_KERNEL_PARTSIZE=.*$/CONFIG_TARGET_KERNEL_PARTSIZE=64/' .config
#sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*$/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/' .config

# Modify app list
sed -i 's|admin/vpn/|admin/services/|g' package/feeds/luci/luci-app-ipsec-vpnd/root/usr/share/luci/menu.d/luci-app-ipsec-vpnd.json   # grep "IPSec VPN Server" -rl ./
sed -i 's/"vpn"/"services"/g; s/"VPN"/"Services"/g' package/feeds/ing/luci-app-zerotier/luasrc/controller/zerotier.lua               # grep "ZeroTier" -rl ./
sed -i 's/"Argon 主题设置"/"主题设置"/g' package/feeds/ing/luci-app-argon-config/po/*/argon-config.po                                 # grep "Argon 主题设置" -rl ./

# Info
# luci-app-netdata 1.33.1汉化版 导致 web升级后 报错: /usr/lib/lua/luci/dispatcher.lua:220: /etc/config/luci seems to be corrupt, unable to find section 'main'