# 图像处理代码重新审计与整理记录

**审计日期：** 2026-09-09
**审计范围：** 新上传的 `rtl/new/`、`VIP_TOP.png`、上一轮已经整理的图像端文件、现有机械臂侧 RTL、`rtl/vendor/` 以及 `archive/CICC_2025_Arm.zip`。
**整理目标：** 让 FPGA/RTL/数字 IC 前端面试者能够直接浏览图像处理链路，同时保留原始资料、第三方声明和 Git 历史。

本次只进行目录组织、重复文件排除、文档、媒体命名和文本编码整理。没有重写算法、修改端口/参数、修复 RTL review 项或补造缺失的 FPGA IP。

## 1. 输入文件清单

新上传的 `rtl/new/` 在整理前包含 50 个文件：

- 44 个 Verilog 源文件；
- 3 个 `*.sdb`、1 个 `*.rlx`、1 个 `xvlog.log`、1 个 `xvlog.pb`，共 6 个 XSim/XVlog 生成物；
- 目录分为 `ov5640`、`axi_ddr3_rw`、`hdmi`、`impress`、`newbe/newbe`、`rgb2yuv` 和 `seg` 等来源/实验目录。

新上传的 `VIP_TOP.png` 已核对为：

- 尺寸：2729 × 930；
- 色彩：8-bit RGB PNG；
- SHA-256：`5610f66c598516f63aa331bf2cc949aa7e3166fda10a2285c062407e50ab5d33`。

图片内容展示了图像端的 OV5640、`clk_wiz_0/1/2`、`rgb2ycbcr_inst`、`key_filiter_top_inst`、`connect_component_top_inst`、`top_seg_dynamic_inst`、`axi_ddr_top`、`vga_ctrl_inst`、`hdmi_ctrl_inst` 和 SPI/DDR3 外部接口。图片已使用语义化文件名保存为 [`media/vision_top_block_diagram.png`](../media/vision_top_block_diagram.png)，像素内容和 hash 未改动。

## 2. 整理前的新上传目录

```text
rtl/new/
├── SPI_slave.v
├── ov5640_hdmi.v
├── ov5640_hdmi(3).v
├── sim_sobel_tb.v
├── axi_ddr3_rw/
│   ├── axi_ctrl.v
│   ├── axi_ddr_top.v
│   ├── axi_master_read.v
│   └── axi_master_write.v
├── hdmi/
│   ├── encode.v
│   ├── hdmi_ctrl.v
│   ├── par_to_ser.v
│   └── vga_ctrl.v
├── impress/
│   ├── VIP_RGB888_YCbCr444.v
│   ├── angle_find.v
│   ├── binarization.v
│   ├── color_bin.v
│   ├── connect_8_area.v
│   ├── connect_component_top.v
│   ├── coordinate_centroid.v
│   ├── dilation.v
│   ├── key_filiter_top.v
│   ├── key_filter.v
│   ├── rgb2ycbcr.v
│   ├── erosion/
│   │   ├── Line_Shift_RAM_1Bit.v
│   │   ├── connect_8_area.v
│   │   ├── erosion.v
│   │   ├── line_shift_ram_8bit.v
│   │   └── matrix_generate_3x3_1bit.v
│   └── tiaoshi/
│       ├── color_bin.v
│       ├── key_filiter_top.v
│       └── key_filter.v
├── newbe/newbe/
│   ├── connect_component_top.v
│   ├── dilaion_7x7/dilation_7x7.v
│   └── erosion_7x7/
│       ├── erosion_7x7.v
│       ├── line_shift_ram_8bit_7x7.v
│       ├── matrix_generate_7x7_1bit.v
│       └── xsim.dir/、xvlog.log、xvlog.pb
├── ov5640/
│   ├── i2c_ctrl.v
│   ├── ov5640_cfg.v
│   ├── ov5640_data.v
│   └── ov5640_top.v
├── rgb2yuv/rgb2yuv.v
└── seg/
    ├── bcd_8421.v
    ├── seg_dynamic.v
    └── top_seg_dynamic.v
```

`impress`、`newbe`、`tiaoshi` 和带括号的顶层文件名反映了上传时的来源或实验版本，不能仅凭目录名判定最终综合版本或个人作者。

## 3. 当前候选图像端顶层

新上传的 `ov5640_hdmi.v` 是当前候选图像端集成顶层，模块名为 `ov5640_hdmi`。与同目录的 `ov5640_hdmi(3).v` 相比，当前候选版本增加或保留了按键调节、LED、数码管和 `color/shape` 输出等连接；两个文件定义了同名顶层模块，不能同时放入同一编译 file list。

从当前顶层可以直接核实的外部接口包括：

- 系统时钟/复位：`sys_clk`、`sys_rst_n`；
- OV5640 像素时钟、场/行同步、8-bit 数据和 SCCB/复位控制；
- DDR3 物理接口；
- HDMI TMDS 差分时钟/数据和 DDC；
- SPI `spi_scl`、`spi_mosi`、`spi_miso`、`spi_sel`；
- 颜色/模式/YCbCr/阈值调节输入、LED、6 位数码管以及 `color`/`shape` 输出。

当前顶层的可见实例层次如下：

```text
ov5640_hdmi
├── SPI_slave
├── clk_wiz_0                  [外部生成时钟 IP，源码未提供]
├── clk_wiz_1                  [外部生成时钟 IP，源码未提供]
├── clk_wiz_2                  [外部生成时钟 IP，源码未提供]
├── ov5640_top
│   ├── i2c_ctrl
│   ├── ov5640_cfg
│   └── ov5640_data
├── key_filiter_top
│   └── key_filter × 4
├── rgb2ycbcr
├── connect_component_top
│   ├── color_bin
│   ├── erosion_7x7 × 2
│   │   └── matrix_generate_7x7_1bit
│   │       └── line_shift_ram_8bit_7x7
│   │           └── ram_8x1024 × 6 [外部生成 RAM IP]
│   ├── erosion
│   │   └── matrix_generate_3x3_1bit
│   │       └── line_shift_ram_8bit
│   │           └── ram_8x1024 × 2 [外部生成 RAM IP]
│   ├── dilation
│   ├── connect_8_area
│   │   └── fifo_640x1 [外部生成 FIFO IP]
│   ├── coordinate_centroid
│   │   └── cordic_1 × 4 [外部生成 CORDIC IP]
│   └── angle_find
│       ├── cordic_0 [外部生成 CORDIC IP]
│       └── divide_angle × 2 [外部生成除法 IP]
├── top_seg_dynamic
│   └── seg_dynamic
│       └── bcd_8421
├── axi_ddr_top
│   ├── axi_ctrl
│   │   ├── wr_fifo [外部生成 FIFO IP]
│   │   └── rd_fifo [外部生成 FIFO IP]
│   ├── axi_master_write
│   ├── axi_master_read
│   └── axi_ddr [外部 MIG/DDR IP，源码未提供]
├── vga_ctrl
└── hdmi_ctrl
    ├── encode × 3
    └── par_to_ser × 4
        ├── ODDR2
        └── OBUFDS
```

顶层把 `ram_wr_data` 组成 SPI 发送数据 `Din`，把处理后的 `bin_out` 写入 AXI/DDR3 通路，再由读出数据驱动 VGA/HDMI 显示。`clk_wiz_0/1/2` 的实际输入输出频率、相位和约束不在本次上传中，因此不能由信号名推断出已经验证的时序性能。

## 4. 活动图像处理链路

### 4.1 由实例连接确认的顺序

当前 `connect_component_top.v` 直接连接的有效 RTL 顺序是：

```text
per_img_Y / per_img_Cb / per_img_Cr
    ↓
color_bin
    ↓
erosion_7x7
    ↓
erosion_7x7
    ↓
erosion（3 × 3）
    ↓
dilation（3 × 3）
    ↓
connect_8_area
    ↓
coordinate_centroid
    ↓
angle_find
```

各阶段的文件证据和作用如下：

| 阶段 | 当前文件 | 从 RTL 看到的作用 |
| --- | --- | --- |
| 颜色分割 | [`rtl/vision/segmentation/color_bin.v`](../rtl/vision/segmentation/color_bin.v) | 按颜色模式和 Y/Cb/Cr 阈值生成二值像素流，并输出颜色、LED、数码管和模式相关信号。 |
| 7 × 7 腐蚀 | [`rtl/vision/morphology/7x7/erosion_7x7.v`](../rtl/vision/morphology/7x7/erosion_7x7.v) | 活动链路中实例化两次；通过 7 × 7 矩阵和行缓存处理邻域。 |
| 3 × 3 腐蚀 | [`rtl/vision/morphology/erosion.v`](../rtl/vision/morphology/erosion.v) | 通过 3 × 3 矩阵生成模块对邻域二值数据进行腐蚀组合。 |
| 3 × 3 膨胀 | [`rtl/vision/morphology/dilation.v`](../rtl/vision/morphology/dilation.v) | 在活动链路中位于 3 × 3 腐蚀之后。 |
| 连通域 | [`rtl/vision/connected_components/connect_8_area.v`](../rtl/vision/connected_components/connect_8_area.v) | 处理二值流、行/帧同步、标签行缓存和目标区域输出；引用 `fifo_640x1`。 |
| 特征提取 | [`rtl/vision/feature_extraction/coordinate_centroid.v`](../rtl/vision/feature_extraction/coordinate_centroid.v) | 统计像素和坐标，生成质心、最高/最低点、面积、形状信息以及发送数据相关信号；引用 `cordic_1`。 |
| 方向角 | [`rtl/vision/angle_estimation/angle_find.v`](../rtl/vision/angle_estimation/angle_find.v) | 根据质心/边界信息生成 9 位 `angle_data`；引用 `cordic_0` 和 `divide_angle`。 |

### 4.2 仅存在于上传目录、但未进入当前活动链路的文件

| 文件/目录 | 处理结论 |
| --- | --- |
| `impress/binarization.v` | 独立的 Y/Cb/Cr 二值化候选；当前活动顶层使用 `color_bin`，因此整理到 `rtl/vision/segmentation/variants/`。 |
| `impress/VIP_RGB888_YCbCr444.v` | 带 CrazyBingo 版权/作者说明的颜色空间参考模块；整理到 `color_space/reference/`，不标成活动实现。 |
| `rgb2yuv/rgb2yuv.v` | 带 EmbedFire/野火 header 的独立转换候选；整理到 `color_space/variants/`。 |
| `impress/erosion/connect_8_area.v` | 另一份同名 `connect_8_area` 定义；整理到 `connected_components/variants/`，不能和活动版本同时编译。 |
| `impress/tiaoshi/*` | 调试/阈值调整版本；接口或参数与活动版本存在差异，整理到 `vision/variants/tiaoshi/`。 |
| `newbe/newbe/connect_component_top.v` | 有效 RTL token 与活动连接顶层基本一致，但包含更多注释实验内容；整理到 `vision/variants/newbe/`。 |
| `newbe/newbe/dilaion_7x7/dilation_7x7.v` | 7 × 7 膨胀候选；当前活动链路使用两次 7 × 7 腐蚀和 3 × 3 膨胀，故作为 variant 保留。 |
| `ov5640_hdmi(3).v` | 较早/简化的同名图像端顶层；作为 `rtl/top/vision/variants/ov5640_hdmi_3.v` 保留。 |

## 5. 主要模块作用与作品集价值

| 模块 | 主要作用 | 适合面试讨论的点 |
| --- | --- | --- |
| `ov5640_hdmi` | 图像端系统集成 | 顶层端口、复位/初始化、模块间数据流、DDR/显示/SPI 的系统连接。 |
| `ov5640_top` | OV5640 配置与 RGB565 采集 | SCCB/I2C 风格配置、摄像头像素时钟、帧/行同步和数据有效。 |
| `rgb2ycbcr` | RGB 到 Y/Cb/Cr 的流式转换 | 像素同步信号随数据传递，以及硬件算术实现。 |
| `color_bin` | 颜色阈值分割和二值化 | 阈值控制、按键调参、模式选择与流式二值输出。 |
| `erosion_7x7` | 7 × 7 形态学腐蚀 | 行缓存、窗口生成、外部 RAM IP 接口和流式邻域处理。 |
| `erosion` / `dilation` | 3 × 3 形态学处理 | 3 × 3 窗口、二值逻辑组合和同步信号对齐。 |
| `connect_8_area` | 8 连通域处理 | 标签/行缓存、区域筛选和图像同步控制；外部 FIFO 依赖。 |
| `coordinate_centroid` | 几何特征与目标信息生成 | 像素计数、坐标累加、质心/边界、面积/形状以及 CORDIC 接口。 |
| `angle_find` | 目标方向角估计 | 整数/移位算术、除法/CORDIC IP 接口和结果有效时序。 |
| `axi_ddr_top` | DDR3 用户侧读写包装 | AXI master 读写、写入/读出时钟接口和 DDR3 物理接口。 |
| `vga_ctrl` / `hdmi_ctrl` | 视频时序与 HDMI 输出 | VGA timing、TMDS encode、差分串行化和器件原语。 |
| `top_seg_dynamic` | 6 位数码管状态显示 | BCD 转换、动态扫描和调试可观测性。 |
| `key_filiter_top` | 四路按键消抖/控制脉冲 | 控制域与像素处理域之间的调参信号连接；保留原始拼写。 |

## 6. 第三方、reference、generated 与可能的项目代码

### 6.1 从文件内容直接确认的归因

| 位置 | 证据 | 分类 |
| --- | --- | --- |
| `rtl/camera/ov5640/`、`rtl/top/vision/ov5640_hdmi.v` | 文件头出现 `Author: EmbedFire`、野火平台说明和相关网址。 | EmbedFire/野火参考或适配基础设施；不能直接写成个人原创。 |
| `rtl/memory/axi_ddr3/` | 文件头保留 EmbedFire/野火信息；`axi_ddr_top.v` 还引用 Xilinx MIG/AXI IP。 | 参考/适配包装，依赖外部生成 IP。 |
| `rtl/display/hdmi/`、`rtl/display/seven_segment/` | 新上传对应文件保留 EmbedFire/野火信息。 | 参考/适配显示基础设施。 |
| `rtl/vision/color_space/rgb2ycbcr.v` | 文件头包含 正点原子/OpenEDV 支持和版权文字。 | 第三方参考/适配代码。 |
| `rtl/vision/color_space/reference/VIP_RGB888_YCbCr444.v` | 文件内包含 CrazyBingo Corporation copyright、author 和授权使用说明。 | 第三方 reference；单独放置并保留法律声明。 |
| `rtl/vendor/altera_ip/Line_Shift_RAM_1Bit.v` | `WIZARD-GENERATED FILE`、`altshift_taps`、Altera/Intel 生成器声明。 | 厂商生成 IP wrapper；新上传的同名副本已确认重复，不再保留第二份。 |
| `rtl/vendor/intel_ip/` | 原始 Quartus 快照中的 PLL、ROM、除法、开方和 CORDIC 相关生成材料。 | Intel/Altera generated/vendor material。 |
| `rtl/display/hdmi/par_to_ser.v` | 实例化 Xilinx `ODDR2`、`OBUFDS`。 | Xilinx 器件原语依赖；不等同于完整生成工程。 |

### 6.2 尚不能确认个人原创的范围

以下文件没有发现明确第三方作者 header，且与框图/技术资料描述的项目链路相符，但这不足以证明是当前仓库所有者本人独立原创：

- `color_bin.v`；
- 活动 `connect_component_top.v` 和 `connect_8_area.v`；
- `coordinate_centroid.v` 与 `angle_find.v`；
- 3 × 3/7 × 7 形态学包装、矩阵和行缓存模块；
- `key_filter.v`、`key_filiter_top.v`；
- 机械臂侧坐标、运动学、FSM、插值、PWM 和项目集成代码；
- `SPI_slave.v` 的项目侧连接和数据格式。

审计分类为“可能属于项目代码或适配代码”，不是“已确认本人原创”。README 中因此保留了个人贡献 TODO。

## 7. 可安全移动、应保留和不应纳入活动源树的内容

### 7.1 已按依赖关系整理的文件

```text
rtl/top/vision/                         当前图像端集成顶层
rtl/camera/ov5640/                      摄像头配置与采集
rtl/vision/color_space/                 活动颜色空间转换
rtl/vision/color_space/reference/       第三方颜色空间参考
rtl/vision/color_space/variants/        未启用的转换候选
rtl/vision/segmentation/                活动颜色分割
rtl/vision/segmentation/variants/      二值化候选
rtl/vision/morphology/                  活动 3 × 3/7 × 7 形态学
rtl/vision/morphology/variants/         未启用形态学候选
rtl/vision/connected_components/        活动 8 连通域
rtl/vision/feature_extraction/         质心/边界/面积/形状
rtl/vision/angle_estimation/            方向角估计
rtl/vision/control/                     图像端按键控制
rtl/vision/variants/                    newbe/tiaoshi/旧版本
rtl/memory/axi_ddr3/                    AXI/DDR3 用户侧包装
rtl/display/hdmi/                      VGA/HDMI
rtl/display/seven_segment/             数码管
sim/vision/                             图像端仿真文件
media/                                  作品集图片和框图
```

### 7.2 已确认的重复文件处理

以下内容在删除前逐一做了字节/内容核对：

- 新上传 `rtl/new/SPI_slave.v` 与现有 `rtl/inter_board/spi/SPI_slave.v` 内容等价；保留公共 SPI 文件，避免同名模块重复。
- 新上传 `rtl/new/impress/erosion/Line_Shift_RAM_1Bit.v` 与 `rtl/vendor/altera_ip/Line_Shift_RAM_1Bit.v` 字节级重复；保留已标注的 vendor 版本。
- 新上传 `rtl/new/impress/tiaoshi/key_filter.v` 与活动 `key_filter.v` 内容等价；不重复纳入最终树。

这些是确认后的重复排除，不是对算法逻辑的修改。

### 7.3 生成物处理

`xsim.dir/work/*.sdb`、`work.rlx`、`xvlog.log`、`xvlog.pb` 是 XSim/XVlog 生成物，不包含应当作为作品集手写 RTL 展示的算法实现；它们没有纳入 Git 跟踪。`.gitignore` 已补充相应生成物规则。原始 `archive/CICC_2025_Arm.zip` 不修改、不解压回写，作为完整历史备份保留。

## 8. 文件移动映射

主要移动关系如下；移动使用 Git rename 语义，保留历史，且对实际内容不同的旧版本使用 archive/variant 分层：

| 原始位置 | 整理后位置 |
| --- | --- |
| `rtl/new/ov5640_hdmi.v` | `rtl/top/vision/ov5640_hdmi.v` |
| `rtl/new/ov5640_hdmi(3).v` | `rtl/top/vision/variants/ov5640_hdmi_3.v` |
| `rtl/new/impress/connect_component_top.v` | `rtl/top/vision/connect_component_top.v` |
| `rtl/new/ov5640/*.v` | `rtl/camera/ov5640/` |
| `rtl/new/axi_ddr3_rw/*.v` | `rtl/memory/axi_ddr3/` |
| `rtl/new/hdmi/*.v` | `rtl/display/hdmi/` |
| `rtl/new/seg/*.v` | `rtl/display/seven_segment/` |
| `rtl/new/impress/rgb2ycbcr.v` | `rtl/vision/color_space/rgb2ycbcr.v` |
| `rtl/new/impress/VIP_RGB888_YCbCr444.v` | `rtl/vision/color_space/reference/VIP_RGB888_YCbCr444.v` |
| `rtl/new/rgb2yuv/rgb2yuv.v` | `rtl/vision/color_space/variants/rgb2yuv.v` |
| `rtl/new/impress/color_bin.v` | `rtl/vision/segmentation/color_bin.v` |
| `rtl/new/impress/binarization.v` | `rtl/vision/segmentation/variants/binarization.v` |
| `rtl/new/impress/erosion/{erosion,dilation,line_shift_ram_8bit,matrix_generate_3x3_1bit}.v` | `rtl/vision/morphology/` |
| `rtl/new/newbe/newbe/erosion_7x7/*.v` | `rtl/vision/morphology/7x7/` |
| `rtl/new/newbe/newbe/dilaion_7x7/dilation_7x7.v` | `rtl/vision/morphology/variants/7x7/` |
| `rtl/new/impress/connect_8_area.v` | `rtl/vision/connected_components/connect_8_area.v` |
| `rtl/new/impress/erosion/connect_8_area.v` | `rtl/vision/connected_components/variants/impress_erosion/connect_8_area.v` |
| `rtl/new/impress/coordinate_centroid.v` | `rtl/vision/feature_extraction/coordinate_centroid.v` |
| `rtl/new/impress/angle_find.v` | `rtl/vision/angle_estimation/angle_find.v` |
| `rtl/new/impress/{key_filter,key_filiter_top}.v` | `rtl/vision/control/` |
| `rtl/new/newbe/newbe/connect_component_top.v` | `rtl/vision/variants/newbe/` |
| `rtl/new/impress/tiaoshi/{color_bin,key_filiter_top}.v` | `rtl/vision/variants/tiaoshi/` |
| `rtl/new/sim_sobel_tb.v` | `sim/vision/sim_sobel_tb.v` |
| `VIP_TOP.png` | `media/vision_top_block_diagram.png` |

上一轮整理得到的旧图像端文件与新上传内容存在实质差异，已移动到 `archive/previous_image_processing/`，没有被覆盖或删除。

## 9. 编码与行为保护

新上传文件原先混用了 UTF-8、GB18030、CRLF 和损坏的中文注释字节。对活动/备选的手写 `.v` 文件进行了 UTF-8/LF 归一化；保留了第三方 copyright、reference 和 vendor/generated 文件的法律声明。没有改动模块名、端口、参数、`always`/`assign` 结构或算法表达式。

本轮已对整理前暂存版本与整理后工作树完成注释/字符串剥离后的 RTL token 对比，并检查模块声明、空文件、未闭合文件和外部依赖。41 个当前图像端/视觉 Verilog 文件的 token 对比通过；若未来再次替换源文件，出现任何非注释 token 差异都必须停止并回到人工 review。本报告不会把静态通过写成综合/仿真通过。

## 10. 当前问题与未修复 review 项

以下问题只记录，不在本轮修复：

1. 图像端顶层依赖 `clk_wiz_0/1/2`、`axi_ddr`、`wr_fifo`、`rd_fifo`、`fifo_640x1`、`ram_8x1024`、`cordic_0`、`cordic_1` 和 `divide_angle`，相应完整工程/IP 配置未随新上传目录提供。
2. `ov5640_hdmi.v` 中出现 `Dout`、`locked`、`locked1`、`clk_320m` 等需要结合原始工程确认的信号；本轮不擅自添加声明或改变顶层行为。
3. `angle_find.v` 中的 CORDIC/除法 IP 数据宽度、valid/latency 和角度结果需要原始 IP 配置与仿真确认。
4. `coordinate_centroid.v` 中的面积/坐标算术、CORDIC 延迟和边界条件需要仿真确认。
5. 活动与 variant 目录仍存在同名模块，例如 `connect_8_area`、`ov5640_hdmi`、`connect_component_top` 和调试版 `color_bin`；file list 必须显式选择版本。
6. `sim/vision/sim_sobel_tb.v` 仍含硬编码 Windows BMP 路径，并依赖外部图片/IP；本轮不改变 testbench 行为。
7. 新旧图像端快照内容不同，不能在 GitHub 描述中把本次上传简单写成旧文件的目录重命名。
8. Git 提交历史和文件 header 不能单独证明个人贡献；README 中保留 TODO，等待仓库所有者确认。

完整 review 表在 [`docs/rtl_review.md`](rtl_review.md)。

## 11. 审计结论

新上传的图像处理代码已经从 `new/` 目录整理为“活动链路 / 备选版本 / 第三方参考 / 原始快照”四个可读层次。最适合求职展示的核心路径是：

```text
OV5640 → rgb2ycbcr → color_bin → 7 × 7 腐蚀 × 2
        → 3 × 3 腐蚀 → 3 × 3 膨胀 → 8 连通域
        → 质心/边界/面积/形状 → 方向角估计
```

该结论是基于当前源文件的实例连接，不是对缺失 FPGA 工程/IP 的综合结果。仓库保持未 commit、未 push，等待所有者 review 后再决定是否提交。
