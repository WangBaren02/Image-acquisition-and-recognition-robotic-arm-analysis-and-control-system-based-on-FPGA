# GitHub Portfolio Metadata Proposal

This file is a recommendation only. The repository name, description, and topics were not changed through GitHub Desktop, the GitHub API, or any remote operation.

## Proposed repository name

```text
FPGA-Vision-Robotic-Arm
```

Alternative if the original competition wording should remain discoverable:

```text
FPGA-Vision-Robotic-Arm-Control-System
```

## Recommended repository description

```text
Pure-FPGA real-time vision and robotic-arm control system with OV5640, YCbCr segmentation, morphology, connected components, SPI, DDR3/AXI, HDMI, inverse kinematics, and servo PWM. National Second Prize in the 9th China IC Innovation & Entrepreneurship Competition.
```

## Recommended topics

```text
fpga
verilog
rtl
digital-design
digital-ic
computer-vision
image-processing
robotic-arm
ov5640
ddr3
axi
hdmi
spi
connected-components
inverse-kinematics
servo-control
```

## Portfolio positioning

The current README is aimed at FPGA, RTL, and Digital IC front-end reviewers. The most searchable concepts are the concrete interfaces and algorithms evidenced in the source: OV5640 capture, RGB/YCbCr conversion, color-threshold segmentation, 7x7 and 3x3 morphology, 8-connected components, centroid/shape/orientation features, AXI/DDR3 buffering, HDMI output, SPI integration, FSM control, inverse-kinematics alternatives, and servo PWM.

The browsable image-side top-level diagram is [`media/vision_top_block_diagram.png`](../media/vision_top_block_diagram.png). The active image-processing chain and missing generated-IP dependencies are documented in [`docs/image_processing_reaudit.md`](image_processing_reaudit.md); these should be reviewed before making build or performance claims.

## Suggested GitHub settings after owner review

- Keep the repository public only if the competition materials, third-party headers, and vendor/IP redistribution terms permit it.
- Add the repository description and topics above manually in GitHub after confirming the proposed name.
- Use `media/system_overview.jpg` as the social-preview candidate only if the image is cleared for public portfolio use; the image-side block diagram is available as an additional documentation asset.
- Keep the original project archive available for provenance, but point recruiters to the browsable `rtl/` and `docs/` directories first.
