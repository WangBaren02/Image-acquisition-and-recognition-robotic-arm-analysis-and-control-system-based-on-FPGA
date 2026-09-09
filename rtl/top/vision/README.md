# 图像端顶层

当前候选图像端集成为 [`ov5640_hdmi.v`](ov5640_hdmi.v)，顶层模块名为 `ov5640_hdmi`。它连接：

- OV5640 配置与 RGB565 采集；
- RGB/Y/Cb/Cr 与颜色分割、形态学、连通域、特征和角度处理；
- SPI 目标信息发送；
- AXI/DDR3 写入/读出；
- VGA/HDMI 显示；
- 按键、LED 和数码管状态显示。

当前图像处理连接的细节见仓库根目录 [`docs/image_processing_reaudit.md`](../../../docs/image_processing_reaudit.md)。

## 版本选择

[`variants/ov5640_hdmi_3.v`](variants/ov5640_hdmi_3.v) 是上传目录中较早/简化的同名顶层快照。两个文件都定义 `ov5640_hdmi`，不得无选择地同时加入同一个 Verilog file list。当前目录的活动候选是上一级的 `ov5640_hdmi.v`。

## 工程依赖

顶层引用 `clk_wiz_0/1/2` 和 `axi_ddr` 等外部生成 IP。完整 Vivado 工程、时钟配置、DDR/MIG 配置和约束没有随本次图像处理代码上传，因此这里是可浏览的 RTL 快照，不是已声明可以独立重建的完整工程。

文件头中的 EmbedFire/野火信息保留不变；请参阅 [`third_party/README.md`](../../../third_party/README.md) 了解归因边界。
