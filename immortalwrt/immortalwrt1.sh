#!/bin/bash
#===============================================

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

#OpenAppFilter    
#git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter    


#add luci-app-mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
