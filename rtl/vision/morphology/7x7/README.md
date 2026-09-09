# 7 × 7 形态学窗口

当前图像链路从 `connect_component_top` 中实例化 `erosion_7x7` 两次。该目录包含 7 × 7 腐蚀包装、矩阵生成和六路行缓存接口：

- `erosion_7x7.v`
- `matrix_generate_7x7_1bit.v`
- `line_shift_ram_8bit_7x7.v`

行缓存源码引用外部生成模块 `ram_8x1024`。匹配的完整 RAM IP/工程配置不在当前可浏览仓库中，因此这些文件应作为 RTL 快照阅读，不能单独宣称可以完成综合。

7 × 7 膨胀候选位于 [`../variants/7x7/dilation_7x7.v`](../variants/7x7/dilation_7x7.v)，不属于当前确认的活动链路。
