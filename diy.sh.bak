#!/usr/bin/env bash

echo "OpenWrt DIY script"

repo=${1:-openwrt}
owner=${2:-Test-Router}
build_date=$(TZ=Asia/Shanghai date "+%Y.%m.%d")

# lede    ==> ${defaultsettings}
# openwrt ==> feeds/ing/default-settings
defaultsettings=*/*/default-settings
[ "${repo}" = "openwrt" ] && language=zh_cn || language=zh_Hans

echo "当前编译的源代码来自：${repo}，固件型号是：${owner};"
echo "repo的值是：${repo}"
echo "======================="
echo "owner的值是：${owner}"
echo "======================="
echo "build_date的值是：${build_date}"
echo "======================="

# passwall
#rm -rf feeds/luci/applications/luci-app-passwall
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# passwall2
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2

# Modify default IP
if [ "${owner}" = "Full-Router" ]; then
  sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/luci2/bin/config_generate
elif [ "${owner}" = "Main-Router" ]; then
  sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/luci2/bin/config_generate
else
  sed -i 's/192.168.1.1/192.168.1.11/g' package/base-files/luci2/bin/config_generate
fi

# Modify hostname
sed -i "/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-GXNAS'" ${defaultsettings}/files/zzz-default-settings
sed -i "s/hostname='.*'/hostname='OpenWrt-GXNAS'/g" ./package/base-files/files/bin/config_generate

# Modify timezone
#sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# Modify banner
cat >package/base-files/files/etc/banner <<EOF
 ██████╗ ██████╗ ███████╗███╗   ██╗██╗    ██╗██████╗ ████████╗
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██║    ██║██╔══██╗╚══██╔══╝
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║ █╗ ██║██████╔╝   ██║   
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║███╗██║██╔══██╗   ██║   
╚██████╔╝██║     ███████╗██║ ╚████║╚███╔███╔╝██║  ██║   ██║   
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   
---------------------------------------------------------------
        OpenWrt-2410-x64-${owner} Build GXNAS
---------------------------------------------------------------
EOF

# Modify password to Null
sed -i '/CYXluq4wUazHjmCDBCqXF/d' ${defaultsettings}/files/zzz-default-settings

# Modify the version number
echo "修改编译时间前的zzz-default-settings的内容是"
cat ${defaultsettings}/files/zzz-default-settings
echo "======================="
sed -i "s/DISTRIB_REVISION='R[0-9]\+\.[0-9]\+\.[0-9]\+'/DISTRIB_REVISION='@R$build_date'/g" ${defaultsettings}/files/zzz-default-settings
sed -i "s/LEDE/OpenWrt-2410-x64-${owner} by GXNAS build/g" ${defaultsettings}/files/zzz-default-settings
echo "修改编译时间后的zzz-default-settings内容是"
cat ${defaultsettings}/files/zzz-default-settings
echo "======================="

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
