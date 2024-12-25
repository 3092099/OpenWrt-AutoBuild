#!/usr/bin/env bash

echo "OpenWrt DIY script"

repo=${1:-openwrt}
owner=${2:-Test-Router}
build_date=$(TZ=Asia/Shanghai date "+%Y.%m.%d")

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

# lede    ==> ${defaultsettings}
# openwrt ==> feeds/ing/default-settings
defaultsettings=*/*/default-settings
[ "${repo}" = "openwrt" ] && language=zh_cn || language=zh_Hans

echo "（diy.sh）zzz-default-settings文件原始内容是："
cat ${defaultsettings}/files/zzz-default-settings
echo "=========================================="

# Modify password to Null
#sed -i '/CYXluq4wUazHjmCDBCqXF/d' ${defaultsettings}/files/zzz-default-settings

# Modify the version number
sed -i "s/DISTRIB_REVISION='R[0-9]\+\.[0-9]\+\.[0-9]\+'/DISTRIB_REVISION='@R$build_date'/g" ${defaultsettings}/files/zzz-default-settings
sed -i "s/LEDE/OpenWrt-2410-x64-${owner} by GXNAS build/g" ${defaultsettings}/files/zzz-default-settings

# Modify the luci-theme-argon
sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2305_x64 by GXNAS build @R'"$build_date"'/' feeds/luci/applications/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' feeds/luci/applications/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' feeds/luci/applications/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2305_x64 by GXNAS build @R$build_date|" feeds/luci/applications/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

echo "（diy.sh）zzz-default-settings文件修改后的内容是："
cat ${defaultsettings}/files/zzz-default-settings
echo "=========================================="

# Modify maximum connections
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# Modify default theme
sed -i "s/bootstrap/argon/g" feeds/luci/collections/luci/Makefile
sed -i "s/bootstrap/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci

echo "（diy.sh）feeds/luci文件下有是："
ls -Ahl feeds/luci/
echo "=========================================="

# Add kernel build user
[ -z $(grep "CONFIG_KERNEL_BUILD_USER=" .config) ] &&
  echo 'CONFIG_KERNEL_BUILD_USER="${owner}"' >>.config ||
  sed -i "s|\(CONFIG_KERNEL_BUILD_USER=\).*|\1$\"${owner}\"|" .config

# Add kernel build domain
[ -z $(grep "CONFIG_KERNEL_BUILD_DOMAIN=" .config) ] &&
  echo 'CONFIG_KERNEL_BUILD_DOMAIN="GitHub Actions"' >>.config ||
  sed -i 's|\(CONFIG_KERNEL_BUILD_DOMAIN=\).*|\1$"GitHub Actions"|' .config
