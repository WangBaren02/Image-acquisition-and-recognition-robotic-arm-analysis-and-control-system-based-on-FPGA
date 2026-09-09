# 第三方、参考与生成材料

本文件记录代码归因边界，不重新授权任何嵌入的源代码，也不把带有他人声明的代码写成个人原创。源文件中的 copyright、author、license 和厂商生成器说明保持原样。

## 从源文件直接确认的归因

| 当前路径/范围 | 直接证据 | 分类与展示方式 |
| --- | --- | --- |
| `rtl/camera/ov5640/`、`rtl/top/vision/ov5640_hdmi.v`、`rtl/top/vision/variants/ov5640_hdmi_3.v` | 文件头出现 `Author: EmbedFire`、野火平台说明、网址等信息。 | EmbedFire/野火参考或适配基础设施；README 不把它们整体写成个人原创。 |
| `rtl/memory/axi_ddr3/` | 文件头包含 EmbedFire/野火信息；`axi_ddr_top.v` 的注释引用 Xilinx MIG/AXI IP。 | 参考/适配包装；缺失完整 MIG/IP 配置。 |
| `rtl/display/hdmi/`、`rtl/display/seven_segment/` | 新上传对应文件保留 EmbedFire/野火实验平台信息。 | 参考/适配显示基础设施；保留原 header。 |
| `rtl/vision/color_space/rgb2ycbcr.v` | 文件头包含 正点原子/OpenEDV 支持和版权文字。 | 第三方参考/适配代码；保留原 header。 |
| [`rtl/vision/color_space/reference/VIP_RGB888_YCbCr444.v`](../rtl/vision/color_space/reference/VIP_RGB888_YCbCr444.v) | 文件中包含 CrazyBingo Corporation copyright、author 和授权使用说明。 | 第三方 reference；单独放在 `reference/`，不放入活动链路。 |
| [`rtl/vendor/altera_ip/Line_Shift_RAM_1Bit.v`](../rtl/vendor/altera_ip/Line_Shift_RAM_1Bit.v) | 文件中包含 `WIZARD-GENERATED FILE`、`altshift_taps`、Altera/Intel 生成器与法律说明。 | Altera/Intel generated wrapper；新上传的同名副本已确认重复。 |
| `rtl/vendor/intel_ip/` | 来自原始 Quartus 快照的 PLL、ROM、除法、开方和 CORDIC 相关生成材料。 | Intel/Altera vendor/generated material；单独保留。 |
| `rtl/display/hdmi/par_to_ser.v` | 实例化 Xilinx `ODDR2`、`OBUFDS` 器件原语。 | Xilinx primitive dependency；不等同于完整生成工程。 |

## 参考代码与项目代码的边界

以下文件或目录没有发现明确的第三方作者 header，但与项目技术资料、顶层框图和活动实例链路相符：

- `rtl/vision/segmentation/color_bin.v`；
- `rtl/top/vision/connect_component_top.v`；
- `rtl/vision/connected_components/connect_8_area.v`；
- `rtl/vision/feature_extraction/coordinate_centroid.v`；
- `rtl/vision/angle_estimation/angle_find.v`；
- `rtl/vision/morphology/` 下的 3 × 3/7 × 7 形态学包装和矩阵/行缓存；
- `rtl/vision/control/` 下的按键模块；
- `rtl/top/robotic_arm/`、`rtl/robotic_arm/` 和 `rtl/inter_board/spi/` 中的项目集成、机械臂控制和 SPI 使用；
- `rtl/vision/variants/` 下的 `newbe`、`tiaoshi` 和未启用候选。

这些范围只能暂记为“可能属于项目代码或适配代码”。没有第三方 header 不代表当前仓库所有者本人独立原创，也不能代替队友/参考工程确认。个人作品集使用前应由作者补充文件级或模块级贡献说明。

## 已排除的重复和生成文件

- 新上传 `rtl/new/SPI_slave.v` 与 [`rtl/inter_board/spi/SPI_slave.v`](../rtl/inter_board/spi/SPI_slave.v) 内容等价，因此最终树只保留一个公共模块，避免同名定义。
- 新上传 `rtl/new/impress/erosion/Line_Shift_RAM_1Bit.v` 与 `rtl/vendor/altera_ip/Line_Shift_RAM_1Bit.v` 字节级重复，因此不保留第二份 generated wrapper。
- 新上传 `rtl/new/impress/tiaoshi/key_filter.v` 与活动 `key_filter.v` 内容等价，因此不保留第二份。
- `xsim.dir/work/*.sdb`、`work.rlx`、`xvlog.log` 和 `xvlog.pb` 是 XSim/XVlog 生成物，没有纳入可浏览 RTL 或 Git 跟踪。

这些排除均基于重复/生成性质核对，不是算法重写。原始完整材料仍可从 [`archive/CICC_2025_Arm.zip`](../archive/CICC_2025_Arm.zip) 追溯。

## 许可证与公开前检查

- 请遵守每个源文件中的 copyright notice、原始 license、参考工程授权和 FPGA 厂商 IP 使用条款。
- 根目录 `LICENSE` 不应被理解为重新授权 `rtl/vendor/`、EmbedFire/野火、OpenEDV、CrazyBingo 或 Xilinx/Intel 生成材料。
- 在公开仓库前，应确认比赛技术报告、答辩材料、硬件照片、演示视频和第三方代码的公开范围。
