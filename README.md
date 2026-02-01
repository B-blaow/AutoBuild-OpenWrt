AutoBuild OpenWrt / ImmortalWrt / LEDE



GitHub Actions CI 的 OpenWrt / ImmortalWrt / LEDE 自动化编译仓库


🔧 自动检测 / 修复 .config 中丢失的包（默认调用check-packages.sh只检测）可选check-packages-status.sh检测加连接ssh修复

GitHub Actions ubuntu /mnt分区被移除




GitHub Actions ubuntu-22.04 没有/mnt分区，默认只有约 18GB 可用空间，直接编译 OpenWrt 极易失败。

GitHub Actions Ubuntu-24.04 没有/mnt分区，默认分区可用空间约90GB(清理后可用空间超过100GB)

GitHub Actions ubuntu-latest 使用/mnt分区 作为编译工作目录（约66GB可用空间）




runner-clean.yml。被监听的工作流结束后自动运行CI Environment Cleanup 无需手动、定时触发CL环境清理（使用ubuntu-24.04编译不需要清理 ）

ssh-generate-config.yml生成.config文件直接push推送到正确目录，如果.config没有变化则不推送push



2️⃣ 检测 make defconfig 后被取消的包

make defconfig 的一个特点是：

feeds 中不存在 / 条件不满足 / 架构不匹配的包会被直接移除，但不会报错

本仓库提供脚本，在 make defconfig 后：

判断包是否：

=y

is not set

完全不存在于 .config

输出清晰状态，避免“以为选了，其实没进固件”


3️⃣ 自动修复被 defconfig 取消的包（可选）（lede专用脚本auto-fix-packages.sh）（immortalwrt、openwrt专用脚本auto-fix-packages-openwrt.sh）默认在yml中注释

针对 确认存在于 feeds 中，但被 defconfig 取消的包，
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



