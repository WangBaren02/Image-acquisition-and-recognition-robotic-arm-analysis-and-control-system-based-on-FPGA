# Third-Party, Reference, and Generated Material

This directory documents attribution boundaries. It does not relicense any embedded source and does not claim personal authorship for code that carries another party's notice.

## Explicit attribution found in source

- `rtl/camera/ov5640/` and `rtl/top/vision/ov5640_hdmi.v` contain EmbedFire / 野火 headers and URLs.
- `rtl/memory/axi_ddr3/` contains EmbedFire / 野火 headers; `axi_ddr_top.v` also describes a Xilinx MIG dependency.
- `rtl/display/hdmi/` contains EmbedFire / 野火 headers.
- `rtl/vision/color_space/VIP_RGB888_YCbCr444.v` contains a CrazyBingo Corporation copyright and author header.
- `rtl/vision/color_space/rgb2ycbcr.v` contains 正点原子 / OpenedV support and copyright text.
- `rtl/vendor/altera_ip/Line_Shift_RAM_1Bit.v` is an Altera/Intel generated `altshift_taps` wrapper.
- `rtl/vendor/intel_ip/` contains generated Intel/Altera PLL, ROM, divide, square-root, and CORDIC-related IP files imported from the original Quartus snapshot.

The original headers and legal notices remain in their source files. The root `LICENSE` is not intended to override those embedded notices or to relicense vendor/reference material.

## Conservative project-code classification

The following areas have no positive third-party attribution in the inspected headers and match the project architecture described in the technical documents:

- `rtl/vision/segmentation/`
- `rtl/vision/morphology/`
- the active `rtl/vision/connected_components/connect_8_area.v`
- `rtl/vision/feature_extraction/`
- `rtl/vision/angle_estimation/`
- `rtl/top/vision/connect_component_top.v`
- `rtl/top/robotic_arm/`
- `rtl/inter_board/spi/`
- `rtl/robotic_arm/`

These are recorded as probable project-specific or adapted code, not as confirmed personal authorship. The repository owner should fill in file-level/team-member ownership before using first-person contribution claims in a CV or interview presentation.
