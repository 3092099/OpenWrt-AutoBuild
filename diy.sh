#!/usr/bin/env bash

echo "OpenWrt DIY script"

repo=${1:-openwrt}
owner=${2:-Test-Router}
build_date=$(TZ=Asia/Shanghai date "+%Y.%m.%d")

echo "当前编译的源代码来自：${repo}，固件型号是：${owner};"
echo "repo的值是：${repo}"
echo "======================="
echo "owner的值是：${owner}"
echo "======================="
echo "build_date的值是：${build_date}"
echo "======================="

# Add a feed source
sed -i "/helloworld/d" feeds.conf.default
sed -i '$a src-git kenzok8 https://github.com/kenzok8/small-package' feeds.conf.default

# passwall
rm -rf feeds/luci/applications/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# passwall2
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2

# Modify default IP
if [ "${owner}" = "Full-Router" ]; then
  sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/luci2/bin/config_generate
elif [ "${owner}" = "Main-Router" ]; then
  sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/luci2/bin/config_generate
else
  sed -i 's/192.168.1.1/192.168.1.11/g' package/base-files/luci2/bin/config_generate
fi

echo "feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/footer.htm的内容是（diy.sh）："
cat feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/footer.htm
echo "======================="
echo "feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/footer.htm的内容是（diy.sh）："
cat feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
echo "======================="

# Modify footer.htm&footer_login.htm
#if [ "${owner}" = "Full-Router" ]; then
  #sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2410_x64_全功能版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2410_x64_全功能版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
#elif [ "${owner}" = "Main-Router" ]; then
  #sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2410_x64_主路由版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2410_x64_主路由版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
#elif [ "${owner}" = "Side-Routes" ]; then
  #sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2410_x64_旁路由版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2410_x64_旁路由版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
#elif [ "${owner}" = "Simplified-Router" ]; then
  #sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2410_x64_精简版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2410_x64_精简版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
#else
  #sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2410_x64_测试版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  #sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2410_x64_测试版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
#fi

# Modify hostname
#sed -i 's/OpenWrt/OpenWrt-GXNAS/g' package/base-files/files/bin/config_generate

echo "package/lean/autocore/files/x86/index.htm的内容是"
cat package/lean/autocore/files/x86/index.htm
echo "======================="
echo "feeds/luci/modules/luci-base/po/zh-cn/base.po的内容是"
cat feeds/luci/modules/luci-base/po/zh-cn/base.po
echo "======================="

# 修改主机名字，修改你喜欢的就行（不能纯数字或者使用中文）
echo "修改主机名字前的zzz-default-settings的内容是"
cat ${defaultsettings}/files/zzz-default-settings
echo "======================="
sed -i "/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-GXNAS'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='.*'/hostname='OpenWrt-GXNAS'/g" ./package/base-files/files/bin/config_generate
echo "修改主机名字后的zzz-default-settings的内容是"
cat ${defaultsettings}/files/zzz-default-settings
echo "======================="

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

# Modify password to Null
sed -i '/CYXluq4wUazHjmCDBCqXF/d' ${defaultsettings}/files/zzz-default-settings

# Modify the version number
echo "修改编译时间前的zzz-default-settings的内容是"
cat ${defaultsettings}/files/zzz-default-settings
echo "======================="
sed -i "s/DISTRIB_REVISION='R[0-9]\+\.[0-9]\+\.[0-9]\+'/DISTRIB_REVISION='@R$build_date'/g" ${defaultsettings}/files/zzz-default-settings
sed -i "s/LEDE/OpenWrt-2410-x64-'${owner}' by GXNAS build/g" ${defaultsettings}/files/zzz-default-settings
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
