#!/bin/bash
#===============================================
# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' $(pwd)/package/base-files/files/bin/config_generate
#
#
#cat >> .config <<EOF
CONFIG_PACKAGE_vlmcsd=y
CONFIG_PACKAGE_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-i18n-vlmcsd-zh-cn=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_htop=y
EOF
