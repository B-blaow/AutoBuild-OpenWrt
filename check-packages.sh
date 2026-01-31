#!/usr/bin/env bash
set -e

#################################################
##################### 通用脚本 ###################
#################################################

##################################################
# 要检查的包列表
# 会匹配 CONFIG_PACKAGE_ 前缀
##################################################
CHECK_PKGS=(
  luci-app-ttyd
  nano
  luci-app-oaf
  open-app-filter
  oaf
  htop
  mosdns
  luci-app-mosdns
  luci-i18n-mosdns-zh-cn
  luci-app-homeproxy
  luci-i18n-homeproxy-zh-cn
  luci-i18n-adguardhome-zh-cn
  luci-app-adguardhome
  nikki
  luci-app-nikki
  luci-i18n-nikki-zh-cn
  cloudflared
  luci-app-cloudflared
  wireguard-tools
  SING_BOX_BUILD_WIREGUARD
  kmod-wireguard
  luci-app-mwan3
  mwan3
  luci-i18n-mwan3-zh-cn
)

echo "================================================="
echo " Package Status Check After defconfig"
echo "================================================="

for pkg in "${CHECK_PKGS[@]}"; do
  CONF="CONFIG_PACKAGE_${pkg}"

  if grep -q "^${CONF}=y" .config; then
    echo "✅ ${pkg}: =y"

  elif grep -q "^# ${CONF} is not set" .config; then
    echo "⚠️ ${pkg}: is not set"

  else
    echo "❌ ${pkg}: not found in .config"
  fi
done

echo "-------------------------------------------------"
echo " Package status check finished"
echo "================================================="
