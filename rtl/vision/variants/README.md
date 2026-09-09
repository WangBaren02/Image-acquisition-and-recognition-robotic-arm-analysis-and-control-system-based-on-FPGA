# 图像处理备选版本

这里保存新上传目录中的实验、调试和未启用候选。它们用于版本对照和技术溯源，不代表当前活动链路，也不应与活动模块无选择地一起编译。

| 目录/文件 | 说明 |
| --- | --- |
| `newbe/connect_component_top.v` | 与当前连接顶层有效 RTL 基本相同、但保留更多实验注释的版本；模块名仍为 `connect_component_top`。 |
| `tiaoshi/color_bin.v` | 调试/阈值调整版 `color_bin`；与活动版本不能按同名直接替换。 |
| `tiaoshi/key_filiter_top.v` | 调试/调参版按键顶层。 |
| `../segmentation/variants/binarization.v` | 独立的 Y/Cb/Cr 二值化候选。 |
| `../color_space/variants/rgb2yuv.v` | 独立 RGB/YUV 转换候选，保留 EmbedFire/野火 header。 |
| `../morphology/variants/7x7/dilation_7x7.v` | 7 × 7 膨胀候选；当前链路使用 7 × 7 腐蚀和 3 × 3 膨胀。 |
| `../connected_components/variants/impress_erosion/connect_8_area.v` | 另一份同名 `connect_8_area` 定义。 |

顶层旧快照位于 [`rtl/top/vision/variants/ov5640_hdmi_3.v`](../../top/vision/variants/ov5640_hdmi_3.v)。
