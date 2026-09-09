# RTL 静态 Review 记录

本文件只记录审计中观察到的风险、依赖缺口和需要作者确认的事项，不是 bug 修复记录。本轮没有根据下列项目修改 RTL 的功能行为、接口、参数或时序。除非补充原始工程、IP 配置、仿真或综合证据，否则不要把任何一项直接描述为“已确认的功能 bug”。

路径按当前整理后的仓库布局书写；行号可能随后续注释整理变化。

## 图像端集成

| 优先级 | 位置 | 观察 | 本轮处理 |
| --- | --- | --- | --- |
| P0：工程依赖 | [`rtl/top/vision/ov5640_hdmi.v`](../rtl/top/vision/ov5640_hdmi.v) | 顶层实例化 `clk_wiz_0`、`clk_wiz_1`、`clk_wiz_2`，但对应时钟 IP/配置未在当前可浏览源树中提供；同时依赖 DDR/MIG 侧工程。 | 只记录，不补 IP、不添加声明。 |
| P0：工程依赖 | [`rtl/memory/axi_ddr3/axi_ctrl.v`](../rtl/memory/axi_ddr3/axi_ctrl.v)、[`rtl/memory/axi_ddr3/axi_ddr_top.v`](../rtl/memory/axi_ddr3/axi_ddr_top.v) | 源码引用 `wr_fifo`、`rd_fifo` 和 `axi_ddr`；匹配的 FIFO/MIG 生成文件未随新上传图像端代码提供。 | 只记录，不伪造生成文件。 |
| P0：工程依赖 | [`rtl/vision/morphology/line_shift_ram_8bit.v`](../rtl/vision/morphology/line_shift_ram_8bit.v)、[`rtl/vision/morphology/7x7/line_shift_ram_8bit_7x7.v`](../rtl/vision/morphology/7x7/line_shift_ram_8bit_7x7.v) | 行缓存引用 `ram_8x1024`；当前仓库没有与之匹配的完整 RAM IP 配置。 | 只记录；保留行缓存 wrapper。 |
| P0：工程依赖 | [`rtl/vision/connected_components/connect_8_area.v`](../rtl/vision/connected_components/connect_8_area.v) | 活动实现引用 `fifo_640x1`；匹配的生成 FIFO 不在可浏览源树中。 | 只记录，不替换为行为模型。 |
| P0：工程依赖 | [`rtl/vision/feature_extraction/coordinate_centroid.v`](../rtl/vision/feature_extraction/coordinate_centroid.v)、[`rtl/vision/angle_estimation/angle_find.v`](../rtl/vision/angle_estimation/angle_find.v) | 分别引用 `cordic_1`、`cordic_0` 和 `divide_angle`；对应 IP 的数据格式、latency 和配置未提供。 | 只记录，不修改接口。 |
| P1：隐式/未声明网络 | [`rtl/top/vision/ov5640_hdmi.v`](../rtl/top/vision/ov5640_hdmi.v) | 文件内未见 `Dout`、`locked`、`locked1`、`clk_320m` 的显式声明，但它们被实例连接或使用。需结合原始工程的 Verilog 规则和约束确认是否有意使用隐式 net。 | 不擅自添加 `wire`，不改变顶层行为。 |
| P1：时钟域 | [`rtl/top/vision/ov5640_hdmi.v`](../rtl/top/vision/ov5640_hdmi.v)、图像端各级流处理模块 | 摄像头像素时钟、`clk_wiz` 输出、DDR 用户时钟和 HDMI/读出时钟同时出现；当前仓库没有完整时钟约束、CDC 说明或时序报告。 | 不对 CDC 正确性作结论。 |
| P1：算术/IP 时序 | [`rtl/vision/angle_estimation/angle_find.v`](../rtl/vision/angle_estimation/angle_find.v) | 角度路径同时使用平方和、CORDIC、两个 `divide_angle` 和结果打拍；`m_axis_dout_tvalid_r` 还出现在两个 sequential block 中，需结合原工程/仿真确认。 | 记录为 review 项，不合并两个 block，也不重排延迟。 |
| P1：算术边界 | [`rtl/vision/feature_extraction/coordinate_centroid.v`](../rtl/vision/feature_extraction/coordinate_centroid.v) | 文件包含像素计数、坐标累加、面积/坐标除法和多个 CORDIC 接口；位宽、除零、边界坐标和 IP latency 需要验证。 | 不修改算术表达式。 |
| P1：连通域边界 | [`rtl/vision/connected_components/connect_8_area.v`](../rtl/vision/connected_components/connect_8_area.v) | 代码使用行缓存、标签/区域状态和边界坐标运算；8 连通域在帧边界、行边界和区域数量边界处的行为应通过仿真确认。 | 不改变标签算法。 |
| P2：同名模块 | 活动 [`connect_8_area.v`](../rtl/vision/connected_components/connect_8_area.v) 与 [`variants/impress_erosion/connect_8_area.v`](../rtl/vision/connected_components/variants/impress_erosion/connect_8_area.v) | 两个文件都定义 `connect_8_area`，variant 不能和活动版本无选择地加入同一个 file list。 | 通过目录和文档隔离，不改模块名。 |
| P2：同名顶层 | [`ov5640_hdmi.v`](../rtl/top/vision/ov5640_hdmi.v) 与 [`variants/ov5640_hdmi_3.v`](../rtl/top/vision/variants/ov5640_hdmi_3.v) | 两个文件都定义 `ov5640_hdmi`，后者是旧/简化快照。 | 保留 variant，明确不能同时编译。 |
| P2：同名集成模块 | [`connect_component_top.v`](../rtl/top/vision/connect_component_top.v) 与 [`variants/newbe/connect_component_top.v`](../rtl/vision/variants/newbe/connect_component_top.v) | 两个文件都定义 `connect_component_top`；newbe 版本作为实验/版本记录保留。 | 不删除、不重命名。 |
| P2：调试版本冲突 | [`rtl/vision/segmentation/color_bin.v`](../rtl/vision/segmentation/color_bin.v) 与 [`variants/tiaoshi/color_bin.v`](../rtl/vision/variants/tiaoshi/color_bin.v) | 调试/阈值调整版本也定义 `color_bin`，接口/行为不能视为活动版本的同义副本。 | 目录隔离，file list 显式选择。 |
| P2：仿真可复现性 | [`sim/vision/sim_sobel_tb.v`](../sim/vision/sim_sobel_tb.v) | testbench 使用硬编码的 `F:\FPGA-EP4CE10F17C8\...` BMP 路径，并依赖外部图片/IP，当前不能直接作为可复现实验入口。 | 不修改 testbench 行为。 |

## 机械臂端

| 优先级 | 位置 | 观察 | 本轮处理 |
| --- | --- | --- | --- |
| P0：工程快照缺口 | [`hardware/quartus/CICC_2025_Arm.qsf`](../hardware/quartus/CICC_2025_Arm.qsf) | QSF 引用了 `rtl/Top/CICC_2025_Arm_prime.v` 和 `rtl/arm/catch/inverse_kinematics.v`，但它们不在解压得到的可浏览文件中。 | 不用其他同名文件擅自替代。 |
| P1：坐标算术 | [`rtl/top/robotic_arm/send_location.v`](../rtl/top/robotic_arm/send_location.v) | `arm_Y` 相关表达式需要与坐标模型和竞赛实际映射核对；周边注释与信号片段不足以证明是错误。 | 只记录，不改映射。 |
| P1：位宽一致性 | [`rtl/top/robotic_arm/CICC_2025_Arm.v`](../rtl/top/robotic_arm/CICC_2025_Arm.v)、[`rtl/top/robotic_arm/send_location.v`](../rtl/top/robotic_arm/send_location.v)、[`rtl/robotic_arm/control/robotic_arm_low_clk.v`](../rtl/robotic_arm/control/robotic_arm_low_clk.v) | 检查到的 arm-side 连接包含不同宽度的坐标信号，意图可能是截断/扩展，也可能需要修订；须用原始工程和波形判断。 | 不改端口或位宽。 |
| P1：实现选择 | [`rtl/robotic_arm/kinematics/inverse_kinematics_time.v`](../rtl/robotic_arm/kinematics/inverse_kinematics_time.v)、[`rtl/robotic_arm/kinematics/inverse_kinematics_cordic.v`](../rtl/robotic_arm/kinematics/inverse_kinematics_cordic.v) | 仓库包含 time-based 和 CORDIC 两个逆运动学候选，现有快照不能充分证明竞赛最终选用哪一个。 | 两个版本都保留，等待作者确认。 |
| P1：信号命名/连接 | [`rtl/top/robotic_arm/CICC_2025_Arm.v`](../rtl/top/robotic_arm/CICC_2025_Arm.v) | 顶层声明了 `Din`，但 `SPI_Shengteng` 实例连接的是 `spi_Din`；需结合原始工程确认是否有意依赖隐式 net 或是命名遗漏。 | 不添加声明、不改连接。 |

## 仿真源文件完整性

| 优先级 | 位置 | 观察 | 本轮处理 |
| --- | --- | --- | --- |
| P1：文件不完整 | [`sim/robotic_arm/control/tb_state_ctrl.v`](../sim/robotic_arm/control/tb_state_ctrl.v) | 文件以一个包含 `state_ctrl` 端口列表的 `module tb_state_ctrl` 开始，但当前文件末尾没有 `endmodule`，也没有可见的完整 DUT 实例/激励。 | 这是原有快照中的问题，本轮不补写 testbench；已记录，不能宣称机械臂仿真文件集完整。 |

## 归因与工程复现限制

- 图像端摄像头、AXI/DDR3、HDMI、数码管和部分顶层文件带有 EmbedFire/野火信息；颜色空间文件含 OpenEDV/正点原子或 CrazyBingo 归属说明。具体清单见 [`third_party/README.md`](../third_party/README.md)。
- `rtl/vendor/` 和 `hardware/quartus/` 中的生成/厂商材料没有参与本轮编码清理；缺失的 Vivado clock/FIFO/RAM/MIG/CORDIC 配置没有被补写。
- 当前可浏览 RTL 不构成一个已经证明可以独立综合/仿真的完整图像端工程；不据此声称 throughput、FPS、latency、资源利用率、时钟频率、固定点精度或 CDC 正确性。
- 个人作者身份不能从 Git 提交作者、文件路径或“没有第三方 header”单独推出；README 中保留贡献 TODO。

## 处理原则

本轮只做了文件移动、重复文件排除、编码/行尾归一化、注释和文档整理。任何真正的功能修复都应另开一个明确的变更，补充原始 IP 配置以及仿真或综合证据后再审查。
