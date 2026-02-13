# AutoBuild OpenWrt / ImmortalWrt / LEDE



## GitHub Actions CI 的 OpenWrt / ImmortalWrt / LEDE 自动化编译仓库


使用/mnt分区 作为编译工作目录（约66GB可用空间）


部分runner可能没/mnt分区也没有145GB大空间，只有72GB根分区，编译x84_64需要运行[free-disk-space.sh](scripts/free-disk-space.sh)脚本清理磁盘空间，清理后可用空间超过50GB(使用[free-disk-space.sh](scripts/free-disk-space.sh)脚本后编译速度较慢，注意时间！免费用户runner每次运行时间为6小时，超时自动关闭）

[72GB runner运行free-disk-space.sh 日志](74gb_runner_actions_logs/0_build.txt)


### [ssh-generate-config.yml](.github/workflows/ssh-generate-config.yml)生成.config文件直接`push`推送到正确目录，如果.config没有变化则不推送`push`


## 检测 make defconfig 后被取消的包

make defconfig 的一个特点是：

feeds 中不存在 / 条件不满足 / 架构不匹配的包会被直接移除，但不会报错

本仓库提供脚本，在 make defconfig 后：

判断包是否：

=y

is not set

完全不存在于 .config

## 输出清晰状态，避免“以为选了，其实没进固件”

🔧 自动检测 / 修复 .config 中丢失的包（默认调用[check-packages.sh](check-packages.sh)只检测）可选[check-packages-status.sh](check-packages-status.sh)检测加连接ssh修复
 

## 针对 `确认存在于feeds中`，但被 defconfig 取消的包
自动修复被 defconfig 取消的包（可选）（lede专用脚本[auto-fix-packages.sh](auto-fix-packages.sh)）（immortalwrt、openwrt专用脚本[auto-fix-packages-openwrt.sh](auto-fix-packages-openwrt.sh)）默认在yml中注释

提供自动修复脚本：

自动写回 .config

再次执行 make defconfig 规范化

若仍失败 → CI 直接中断（gating）


🚨 为什么一定要做 defconfig 校验？（提前知道插件有没有少）

如果你曾遇到：

固件里没 LuCI

插件没进固件却没报错

CI 成功但功能缺失

99% 是 defconfig 静默丢包


```
目录结构
.
├── openwrt/
│   ├── .config              配置文件
│   ├── openwrt1.sh          增加feeds脚本
│   └── openwrt2.sh          修改默认ip脚本
│
├── immortalwrt/
│   ├── .config              配置文件
│   ├── immortalwrt1.sh      增加feeds脚本
│   └── immortalwrt2.sh      修改默认ip脚本
│
├── lede/
│   ├── .config              配置文件
│   ├── lede1.sh             增加feeds脚本
│   └── lede2.sh             修改默认ip脚本
│
├── scripts/
│   ├── cleanup.sh           清理脚本，清理后可用空间约36GB，清理后不影响编译速度       
│   └── free-disk-space.sh   清理脚本，清理后可用空间超过50GB，清理后编译速度较慢
│        
├── check-packages-status.sh       检测config配置+连接ssh修复脚本（默认不连接ssh）
├── auto-fix-packages-openwrt.sh   immortalwrt & openwrt专用脚本检测+修复 .config 脚本（默认不调用）
├── auto-fix-packages.sh           lede专用脚本检测+修复 .config 脚本（默认不调用）
└── README.md
```



