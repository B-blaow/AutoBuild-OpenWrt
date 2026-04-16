#!/bin/bash
#===============================================


# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

#OpenAppFilter   
#git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter    

# add mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns


git clone --depth=1 \
  https://github.com/immortalwrt/luci.git \
  -b openwrt-25.12 \
  /tmp/luci

mkdir -p package/luci-app-vlmcsd
cp -r /tmp/luci/applications/luci-app-vlmcsd/* package/luci-app-vlmcsd/

rm -rf /tmp/luci

#
git clone --depth=1 \
  https://github.com/coolsnowwolf/packages.git \
  -b master \
  /tmp/package

mkdir -p package/net/vlmcsd
cp -r /tmp/package/net/vlmcsd/* package/net/vlmcsd/

rm -rf /tmp/package



#homeproxy
git clone https://github.com/immortalwrt/homeproxy.git package/homeproxy
