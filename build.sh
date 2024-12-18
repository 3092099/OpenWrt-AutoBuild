#!/usr/bin/env bash

build_date=$(TZ=Asia/Shanghai date "+%Y.%m.%d")

if [ -z "${1}" ] || [ ! -f "${1}" ]; then
  echo "Usage: $0 <config file>"
  exit 1
fi

WORKSPACE="$(pwd)"

script_path=$(realpath "$(dirname "${1}")/diy.sh")
config_path=$(realpath "${1}")               # 绝对路径
CONFIG_FNAME=$(basename "${1}" .config) # 取文件名
CONFIG_ARRAY=(${CONFIG_FNAME//;/ })     # 分割成数组

if [ ${#CONFIG_ARRAY[@]} -ne 3 ]; then
  echo "${config_path} name error!" # config 命名规则: <repo>;<owner>;<name>.config
  exit 1
fi

CONFIG_REPO="${CONFIG_ARRAY[0]}"
CONFIG_OWNER="${CONFIG_ARRAY[1]}"
CONFIG_NAME="${CONFIG_ARRAY[2]}"
echo "CONFIG_REPO的值是：${CONFIG_REPO}"
echo "======================="
echo "CONFIG_OWNER的值是：${CONFIG_OWNER}"
echo "======================="
echo "CONFIG_NAME的值是：${CONFIG_NAME}"
echo "======================="
echo "build_date的值是：${build_date}"
echo "======================="

if [ "${CONFIG_REPO}" = "openwrt" ]; then
  REPO_URL="https://github.com/openwrt/openwrt"
  REPO_BRANCH="master"
elif [ "${CONFIG_REPO}" = "lede" ]; then
  REPO_URL="https://github.com/coolsnowwolf/lede"
  REPO_BRANCH="master"
else
  echo "${config_path} name error!"
  exit 1
fi

if [ ! -d "${CONFIG_REPO}" ]; then
  git clone --depth=1 -b "${REPO_BRANCH}" "${REPO_URL}" "${CONFIG_REPO}"
  # if [ -d "${CONFIG_REPO}/package/kernel/r8125" ]; then
  #   rm -rf ${CONFIG_REPO}/package/kernel/r8125
  # fi
  # if [ -d "${CONFIG_REPO}/package/lean/r8152" ]; then
  #   rm -rf ${CONFIG_REPO}/package/lean/r8152
  # fi
fi

# root.
export FORCE_UNSAFE_CONFIGURE=1

pushd "${CONFIG_REPO}"

git pull

sed -i "src-git gxnas https://github.com/gxnas/OpenWrt_Build_x64_Packages" feeds.conf.default

# Modify footer.htm&footer_login.htm
if [ "${CONFIG_OWNER}" = "Full-Router" ]; then
  sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2305_x64_全功能版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2305_x64_全功能版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
elif [ "${CONFIG_OWNER}" = "Main-Router" ]; then
  sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2305_x64_主路由版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2305_x64_主路由版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
elif [ "${CONFIG_OWNER}" = "Side-Routes" ]; then
  sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2305_x64_旁路由版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2305_x64_旁路由版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
elif [ "${CONFIG_OWNER}" = "Simplified-Router" ]; then
  sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2305_x64_精简版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2305_x64_精简版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
else
  sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2305_x64_测试版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2305_x64_测试版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
fi


./scripts/feeds update -a
# if [ -d ./feeds/packages/lang/golang ]; then
#   rm -rf ./feeds/packages/lang/golang
#   git clone --depth=1 -b 22.x https://github.com/sbwml/packages_lang_golang ./feeds/packages/lang/golang
# fi
./scripts/feeds install -a
./scripts/feeds uninstall $(grep Package ./feeds/ing.index | awk -F': ' '{print $2}')
./scripts/feeds install -p ing -a

cp -f "${config_path}" "./.config"
cp -f "${script_path}" "./diy.sh"

chmod +x "./diy.sh"
"./diy.sh" "${CONFIG_REPO}" "${CONFIG_OWNER}"

make defconfig

if [ "$GITHUB_ACTIONS" = "true" ]; then
  pushd "${GITHUB_WORKSPACE}"
  git pull
  cp -f "${WORKSPACE}/${CONFIG_REPO}/.config" "${GITHUB_WORKSPACE}/${config}"
  status=$(git status -s | grep "${CONFIG_FNAME}" | awk '{printf $2}')
  if [ -n "${status}" ]; then
    git add "${status}"
    git commit -m "update $(date +%Y-%m-%d" "%H:%M:%S)"
    git push -f
  fi
  popd
fi

echo "download package"
make download -j8 V=s

# find dl -size -1024c -exec ls -l {} \; -exec rm -f {} \;

echo "$(nproc) thread compile"
make -j$(nproc) V=s || make -j1 V=s
if [ $? -ne 0 ]; then
  echo "Build failed!"
  popd # ${CONFIG_REPO}
  exit 1
fi

pushd bin/targets/*/*

echo "编译成功，原始文件有："
ls -al
echo "CONFIG_REPO的值是：${CONFIG_REPO}"
echo "======================="
echo "CONFIG_OWNER的值是：${CONFIG_OWNER}"
echo "======================="
echo "build_date的值是：${build_date}"
echo "======================="

rm -rf packages *.buildinfo *.manifest *.bin sha256sums *rootfs.img profiles.json
rm -f *.img.gz
gzip -f *.img
echo "整理文件后，当前文件夹有："
ls -al
echo "======================="

mv openwrt-x86-64-generic-squashfs-combined.img.gz "${CONFIG_REPO}"-"${CONFIG_OWNER}"-"${build_date}"-bios.img.gz
mv openwrt-x86-64-generic-squashfs-combined-efi.img.gz "${CONFIG_REPO}"-"${CONFIG_OWNER}"-"${build_date}"-uefi.img.gz
echo "文件名优化后，当前文件夹有："
ls -al
echo "======================="

mv -f *.img.gz "${WORKSPACE}"

popd # bin/targets/*/*

popd # ${CONFIG_REPO}

du -chd1 "${CONFIG_REPO}"

echo "Done"
