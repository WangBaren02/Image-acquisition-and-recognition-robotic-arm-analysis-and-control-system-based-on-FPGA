# Repository Audit

> Audit snapshot: before the portfolio reorganization.
>
> Repository: `WangBaren02/Image-acquisition-and-recognition-robotic-arm-analysis-and-control-system-based-on-FPGA`
>
> Scope: repository contents, Git history, RTL structure, the `CICC_2025_Arm.zip` snapshot, technical documents, attribution evidence, and static integration risks. No RTL behavior was changed while producing this audit.

## 1. Audit basis and current Git state

- Current checkout: `main`, at `9b3d4fc` (`Update README.md`), tracking `origin/main`.
- Git history currently contains 15 commits from 2025-10-23 through 2025-10-30. The history is linear and has no merge commits or tags.
- The Git author on the existing commits is `Hanwen Zhang <WangBaren02@163.com>`. This is evidence about repository commit metadata, not sufficient evidence to assign authorship of every RTL module.
- The working tree was not clean at the start of the audit. Eighteen tracked files were marked modified, including `README.md`, `LICENSE`, and RTL files. `git diff --ignore-space-at-eol` reported no semantic content changes; the observed difference is a Windows CRLF/line-ending change. These pre-existing working-tree changes must not be mistaken for this reorganization.
- No root `.gitignore` or `.gitattributes` was present.
- There is no standalone Quartus/Vivado project file at the repository root. The visible image-side RTL has no accompanying clock-wizard/MIG/FIFO project sources.

The audit used the tracked tree, Verilog text/module declarations, explicit instantiations and external references, the ZIP directory listing and extracted source, the Quartus project settings inside the ZIP, the two PDF documents, and a visual inspection of `c6.png`.

## 2. Current directory structure before reorganization

```text
.
├── CICC_2025_Arm.zip
├── LICENSE
├── README.md
├── c6.png
├── new/
│   ├── axi_ddr3_rw/
│   │   ├── axi_ctrl.v
│   │   ├── axi_ddr_top.v
│   │   ├── axi_master_read.v
│   │   └── axi_master_write.v
│   ├── hdmi/
│   │   ├── encode.v
│   │   ├── hdmi_ctrl.v
│   │   ├── par_to_ser.v
│   │   └── vga_ctrl.v
│   ├── impress/
│   │   ├── VIP_RGB888_YCbCr444.v
│   │   ├── angle_find.v
│   │   ├── binarization.v
│   │   ├── connect_8_area.v
│   │   ├── connect_component_top.v
│   │   ├── coordinate_centroid.v
│   │   ├── dilation.v
│   │   ├── erosion/
│   │   │   ├── Line_Shift_RAM_1Bit.v
│   │   │   ├── connect_8_area.v
│   │   │   ├── erosion.v
│   │   │   ├── line_shift_ram_8bit.v
│   │   │   └── matrix_generate_3x3_1bit.v
│   │   └── rgb2ycbcr.v
│   ├── ov5640/
│   │   ├── i2c_ctrl.v
│   │   ├── ov5640_cfg.v
│   │   ├── ov5640_data.v
│   │   └── ov5640_top.v
│   ├── ov5640_hdmi.v
│   └── sim_sobel_tb.v
├── 技术文档.pdf
└── 答辩PPT.pdf
```

Tracked content at the snapshot consists of 27 Verilog files, one PNG, two PDFs, one ZIP archive, `README.md`, and `LICENSE`. There are no loose generated Quartus/Vivado databases outside the ZIP.

## 3. System architecture established from the files

The documents and RTL describe two FPGA domains:

1. **Vision / image-acquisition side** — the technical document identifies the Wildfire ShengTeng Mini Artix-7 board with an XC7A100T device. The visible RTL top is `new/ov5640_hdmi.v`, which contains OV5640 capture, RGB565-to-YCbCr conversion, the image-processing top, an AXI/DDR3 wrapper, and VGA/HDMI output.
2. **Robotic-arm side** — `CICC_2025_Arm.zip/CICC_2025_Arm.qsf` sets the family to `Cyclone IV E`, the device to `EP4CE6F17C8L`, and the top-level entity to `CICC_2025_Arm`. The technical document describes this side as the AWC_C4/Cyclone IV control board and the connection board to the ShengTeng board.

The intended system-level data path is therefore:

```text
OV5640 camera
  -> RGB565 capture
  -> YCbCr conversion
  -> color threshold / binarization
  -> morphology
  -> two-pass 8-connected component processing
  -> centroid / highest-point / area feature extraction
  -> orientation estimation
  -> object information transferred to the arm-side controller
  -> coordinate conversion / inverse-kinematics lookup
  -> arm state control / interpolation
  -> five servo PWM outputs and air-pump control
```

The current visible image-side top and the ZIP arm-side top are not a single compile-complete tree. The arm-side `CICC_2025_Arm` top exposes `shape` and `color` inputs and an SPI port, while the visible `new/ov5640_hdmi.v` top exposes camera, DDR3, and HDMI interfaces but does not expose the object-information packet or instantiate the arm-side top. The board-to-board relationship is documented and an SPI bridge exists in the ZIP, but the complete cross-board build manifest is not present in the repository snapshot.

### Hardware and interfaces verified from source/documents

- OV5640 camera input with pixel clock, VSYNC, HREF, 8-bit camera data, SCCB clock/data, reset, and power-down signals: `new/ov5640_hdmi.v`.
- RGB565 pixel handling and 640 x 480 parameters in the image-side top and simulation source.
- DDR3 physical interface and an AXI-style read/write wrapper in `new/axi_ddr3_rw/`.
- VGA timing and HDMI TMDS encode/serialize modules in `new/hdmi/`.
- SPI master/slave/bridge sources in the ZIP. `SPI_Shengteng.v` packs/unpacks a 32-bit transaction containing 10-bit `VIP_X`, 10-bit `VIP_Y`, and a 9-bit `catch_4_angle` field.
- Cyclone IV arm top outputs five PWM signals and one air-pump enable signal.
- Clock names and domains visible in the source include camera pixel clock, system clock, 25 MHz/125 MHz/320 MHz image-side clocks, DDR UI clock, and 1 MHz/20 MHz/100 MHz arm-side clocks. Exact clock frequencies and CDC correctness are not independently verified here.

## 4. RTL module hierarchy

### 4.1 Image-side hierarchy in `new/`

```text
ov5640_hdmi
├── clk_wiz_0                         [external Xilinx-generated IP; not present]
├── clk_wiz_1                         [external Xilinx-generated IP; not present]
├── ov5640_top
│   ├── ov5640_cfg
│   ├── ov5640_data
│   └── i2c_ctrl
├── rgb2ycbcr
├── connect_component_top
│   ├── binarization
│   ├── erosion
│   │   └── matrix_generate_3x3_1bit
│   │       └── line_shift_ram_8bit
│   ├── dilation
│   │   └── matrix_generate_3x3_1bit
│   │       └── line_shift_ram_8bit
│   ├── connect_8_area
│   │   └── fifo_640x1              [external FIFO IP; not present]
│   ├── coordinate_centroid
│   └── angle_find
│       └── divide_angle             [external divider IP; not present]
├── axi_ddr_top
│   ├── axi_ctrl
│   │   ├── wr_fifo                  [external FIFO IP; not present]
│   │   └── rd_fifo                  [external FIFO IP; not present]
│   ├── axi_master_write
│   ├── axi_master_read
│   └── MIG/DDR controller            [external generated IP; not present]
├── vga_ctrl
└── hdmi_ctrl
    ├── encode x3
    └── par_to_ser x3
```

The image-processing pipeline order is explicit in `new/impress/connect_component_top.v`: `binarization` feeds `erosion`; the output then feeds `dilation`; the result feeds `connect_8_area`; the selected binary object feeds `coordinate_centroid`; and the centroid/highest-point/shape data feed `angle_find`.

`new/sim_sobel_tb.v` is a separate BMP-file simulation harness. It generates a synthetic 640 x 480 camera-like timing stream and writes an output BMP. It contains hard-coded Windows paths and is not a self-contained reproducible simulation until its input/output paths and complete IP list are supplied.

### 4.2 Robotic-arm hierarchy from `CICC_2025_Arm.zip`

```text
CICC_2025_Arm
├── pll_ip                         [Intel/Altera generated IP]
├── key / key_1M
├── SPI_Shengteng
│   └── SPI_master
├── send_location
│   ├── color/shape counters and destination mapping
│   ├── pixel-coordinate to arm-coordinate conversion
│   └── packet/start sequencing
└── robotic_arm_low_clk
    ├── catch
    │   ├── inverse_kinematics_time or inverse_kinematics_cordic
    │   ├── divide_ip / sqrt_ip or cordic_ATAN2 [IP/algorithm alternatives]
    │   └── ROM data
    ├── laydown
    │   └── laydown_location_rom
    ├── state_ctrl
    ├── mode_select
    │   └── linear_interpolation
    └── five pwm_servo_1M instances + air_pump control
```

The Quartus file includes both `inverse_kinematics_cordic.v` and `inverse_kinematics_time.v` in its source assignments, but it also references two files absent from the extracted ZIP (`rtl/Top/CICC_2025_Arm_prime.v` and `rtl/arm/catch/inverse_kinematics.v`). The exact intended active implementation therefore needs owner confirmation before anyone claims a clean rebuild.

## 5. Major module roles

| Area | File(s) at audit time | Evidence-based role |
|---|---|---|
| Camera configuration | `new/ov5640/ov5640_cfg.v`, `i2c_ctrl.v` | Register-table/SCCB-style configuration and I2C control for OV5640. |
| Camera pixel capture | `new/ov5640/ov5640_data.v`, `ov5640_top.v` | Consumes camera pixel clock/data and produces RGB565 data-valid/frame timing. |
| RGB/YCbCr conversion | `new/impress/rgb2ycbcr.v`, `VIP_RGB888_YCbCr444.v` | Streaming color-space conversion variants; one source carries an explicit CrazyBingo header, the other carries a 正点原子/OpenedV header. |
| Segmentation | `new/impress/binarization.v` | Per-pixel threshold selection driven by Y/Cb/Cr and a color-selection signal. |
| Morphology | `new/impress/erosion/erosion.v`, `dilation.v`, matrix/line buffers | 3 x 3 neighborhood processing and erosion/dilation stages. |
| Connected components | `new/impress/connect_8_area.v` | Two-pass/row-buffer style labeling and extraction of the selected label; source comments identify 8-connected processing. |
| Feature extraction | `new/impress/coordinate_centroid.v` | Accumulates pixel count and coordinate sums, finds high/low points, classifies shape by area thresholds, and emits control/status flags. |
| Orientation | `new/impress/angle_find.v` | Computes an angle from centroid/highest-point data using a divider and piecewise arithmetic. The divider instance is not present in the visible tree. |
| DDR3/AXI | `new/axi_ddr3_rw/*.v` | User-side burst control, AXI read/write masters, and FIFO boundaries around a generated memory controller. |
| Display | `new/hdmi/*.v` | VGA timing, TMDS encoding, and parallel-to-serial differential output. |
| Arm-side communication | ZIP `rtl/SPI/*.v` | SPI mode-0 style master/slave and a 32-bit field bridge. |
| Coordinate/mission sequencing | ZIP `rtl/Top/send_location.v` | Counts classified objects, maps destination positions, converts coordinates, and generates arm-side valid/start signals. |
| Inverse kinematics | ZIP `rtl/arm/catch/inverse_kinematics_*.v`, `catch.v`, ROMs | Converts object coordinates/radius to ROM addresses and servo data; includes time-based and CORDIC alternatives in the snapshot. |
| Arm sequencing | ZIP `rtl/arm/state_ctrl.v`, `mode_select.v`, `linear_interpolation.v` | FSM-driven catch/place sequence, interpolation mode selection, and stepwise PWM target changes. |
| Actuation | ZIP `rtl/arm/pwm_servo_1M.v`, `robotic_arm_low_clk.v` | Five servo PWM generators and air-pump output orchestration. |
| Simulation | `new/sim_sobel_tb.v` and ZIP `rtl/**/tb_*.v`, `test_*.v` | BMP/video-stream harnesses and arm/SPI module-level testbenches. Actual simulator/tool configuration is incomplete or snapshot-specific. |

## 6. `CICC_2025_Arm.zip` contents

The archive contains a full Quartus project snapshot, not only arm RTL:

- 755 ZIP entries; approximately 80.9 MB after extraction.
- Quartus project files: `CICC_2025_Arm.qpf`, `.qsf`, `.qws`, plus an `atan2.qsys`/`.sopcinfo` component snapshot.
- Arm-side RTL under `rtl/arm/`, top-level and SPI sources under `rtl/Top/` and `rtl/SPI/`, and testbenches under `rtl/**/test` and `rtl/test`.
- Intel/Altera IP source/configuration under `ip/`: PLLs, ROMs, divide, square-root, and CORDIC/atan2 related files. The generated files retain Intel copyright/legal notices.
- Memory initialization files (`.mif`) for servo and destination ROMs.
- Generated/build content: `db/`, `incremental_db/`, `output_files/`, `greybox_tmp/`, and ModelSim `rtl_work/`, `.wlf`, `.sdo`, generated `.vo`, transcripts, and other reports.
- Backup files with `.bak` suffixes, including alternate or intermediate RTL versions.

The archive is therefore valuable as an original project backup but should not be exploded wholesale into the visible portfolio tree. The safe portfolio subset is the non-backup RTL/test source, the minimal Quartus project settings needed as documentation, and the IP descriptors/data required to explain the arm-side design. Build databases, programming images, waveform databases, and temporary directories should remain archive-only.

## 7. Code provenance classification

This classification is deliberately conservative. “Probable project-specific” is not the same as “confirmed personally authored.”

### 7.1 Explicit third-party/reference evidence

| Files | Evidence | Portfolio treatment |
|---|---|---|
| `new/axi_ddr3_rw/*.v` | File headers explicitly say `Author: EmbedFire`, identify 野火/EmbedFire URLs; `axi_ddr_top.v` also mentions a Xilinx MIG IP. | Keep headers. Mark as EmbedFire/reference-adapted infrastructure; do not present as personal original RTL. |
| `new/hdmi/*.v` | File headers explicitly say EmbedFire/野火. | Keep headers. Mark as reference/adapted display infrastructure. |
| `new/ov5640/*.v` and the header of `new/ov5640_hdmi.v` | File headers explicitly say EmbedFire/野火. | Keep headers. Mark as reference/adapted camera/integration infrastructure. |
| `new/impress/VIP_RGB888_YCbCr444.v` | Contains `Copyright (C) 2011-20xx CrazyBingo Corporation` and `Author: CrazyBingo`. | Keep the proprietary notice intact; place in the attribution ledger and do not claim authorship. |
| `new/impress/rgb2ycbcr.v` | Header identifies 正点原子/OpenedV support and copyright text. | Preserve the header and classify as third-party/reference-derived. |
| `new/impress/erosion/Line_Shift_RAM_1Bit.v` | Quartus/Altera `altshift_taps` generated-IP legal notice. | Treat as generated/vendor IP; do not edit behavior or header. |
| ZIP `ip/**` and generated IP wrappers | Intel/Altera legal notices, `altera_mf`, Quartus 17.1 metadata, and generated CORDIC/PLL/ROM/divide/sqrt structures. | Keep as vendor/generated IP only when needed for explanation/build context; preserve notices and do not call it personal RTL. |

### 7.2 Probable adapted or project-specific code requiring confirmation

- `new/impress/dilation.v`, `erosion.v`, `matrix_generate_3x3_1bit.v`, `line_shift_ram_8bit.v`, and the active `connect_8_area.v` have naming/comment patterns consistent with common FPGA video-processing examples, but their authorship is not proven by a complete header. Record them as **probable adapted/project-specific; owner confirmation required**.
- `new/impress/binarization.v`, `coordinate_centroid.v`, `angle_find.v`, and `connect_component_top.v` implement the algorithmic structure described in the technical document and have no positive third-party attribution in their headers. They are **probable project-specific**, but this audit does not establish which team member wrote them or whether any portions were adapted.
- ZIP `rtl/arm/**`, `rtl/Top/CICC_2025_Arm.v`, `send_location.v`, and `rtl/SPI/**` contain the project’s arm/control/integration naming and no explicit external-source header in the inspected files. They are **probable project-specific**, not confirmed personally authored. The user should confirm ownership before the README uses first-person claims.
- ZIP `rtl/Top/ov5640_hdmi.v` carries an EmbedFire header and is not part of the `CICC_2025_Arm.qsf` active source list. It should not be used as evidence of original arm-side RTL.

### 7.3 What cannot be inferred

- The Git author, repository owner, team name, and absence of a third-party header do not prove personal authorship.
- The technical document describes team-level work and does not identify file-by-file ownership.
- No license text was found that automatically relicenses vendor/reference sources under the root MIT `LICENSE`; the root license must not be treated as overriding embedded third-party notices.

## 8. Files safe to move or import after this audit

The following operations are organization-only and do not require RTL edits, provided all project references are updated or the source is explicitly documented as a snapshot:

1. Move the current `new/` files into functional `rtl/` and `sim/` subdirectories with `git mv`; preserve file bytes and attribution headers.
2. Move `c6.png` to a semantic `media/system_overview.png` name without changing its pixels.
3. Move the two PDFs to semantic names under `docs/` without editing their content.
4. Move the original `CICC_2025_Arm.zip` to `archive/` as an unchanged backup after the selected arm RTL has been imported for browsing.
5. Import non-`.bak` arm/SPI/top test source from the extracted ZIP into browsable `rtl/robotic_arm`, `rtl/inter_board`, and `sim/robotic_arm` directories. These are new tracked files, not replacements for existing source.
6. Import the minimal vendor IP descriptors, wrappers, and `.mif` data as a clearly labeled vendor/IP subtree. Keep the generated legal notices unchanged.
7. Add documentation and an attribution ledger. These do not change the RTL implementation.

The duplicate `new/impress/erosion/connect_8_area.v` and the unused/generated `Line_Shift_RAM_1Bit.v` should not be silently deleted. They can be moved to a clearly labeled legacy/vendor subtree or left represented only by the original archive if their inclusion would create duplicate module definitions.

## 9. Files and artifacts that should not be modified

- Any Intel/Altera or Xilinx generated IP wrapper, legal header, `.qip`, `.qsys`, `.sopcinfo`, `.mif`, or generated VHDL required to explain the original project.
- The `db/`, `incremental_db/`, `output_files/`, `greybox_tmp/`, and ModelSim waveform/library/report directories inside the original ZIP. They are generated build artifacts, not hand-maintained RTL; retain them only through the original archive unless there is a specific reproducibility reason.
- `.bak` files from the original ZIP. They may be useful for provenance, but they should not be promoted to active source or used to infer the final implementation without owner confirmation.
- Existing RTL timing, combinational/sequential logic, module interfaces, reset polarity, and clocking behavior. This phase permits path/name organization only.

## 10. Current repository problems to track

### Presentation and organization

- `new/` is a semantic dead end for recruiters; it does not distinguish camera, vision, memory, display, arm control, IP, and simulation.
- The README is a short link list and uses `/c6.png`, which is not a semantic repository-relative media path.
- The arm-side source is hidden in a ZIP, so the system’s most interview-relevant control RTL cannot be browsed without downloading/extracting it.
- Technical documents and media have non-semantic Chinese/generic root-level names.
- There is no attribution ledger, portfolio metadata recommendation, or explicit build-status statement.

### Build/integration completeness

- The visible image-side top references `clk_wiz_0`, `clk_wiz_1`, `mig`/DDR infrastructure, `wr_fifo`, `rd_fifo`, `fifo_640x1`, and `divide_angle` without matching source in the visible tree.
- `connect_8_area` is defined in both `new/impress/connect_8_area.v` and `new/impress/erosion/connect_8_area.v`. Compiling both files together would create a duplicate module-name conflict; the active top appears to target the first file.
- `new/ov5640_hdmi.v` declares `ram_wr_data` as 24 bits while the active `connect_component_top` declares its corresponding output as 30 bits. This is a static interface-width review item, not a change to make during organization.
- `new/impress/angle_find.v` contains a `divide_angle` instance with an undeclared `aclk` signal in the visible source. It also uses chained-comparison syntax that needs RTL-owner review; no fix is made in this pass.
- `new/sim_sobel_tb.v` contains hard-coded `F:\\FPGA-EP4CE10F17C8\\...` BMP paths and depends on files outside the repository.
- The Quartus QSF inside the ZIP references missing `rtl/Top/CICC_2025_Arm_prime.v` and `rtl/arm/catch/inverse_kinematics.v`. The ZIP is not a verified clean-build package.
- The extracted arm project contains both time-based and CORDIC inverse-kinematics alternatives, and the active choice is not unambiguously documented by the snapshot.

### Encoding and comments

- Several current files are GBK/GB18030 encoded while others are UTF-8; this is why some comments render as mojibake in a UTF-8 terminal.
- `new/sim_sobel_tb.v` is encoded as GB18030 while other tracked RTL is UTF-8; it renders as mojibake when a UTF-8-only viewer reads it. The source can be normalized to UTF-8 without changing its decoded comments or RTL tokens. Literal replacement characters were observed in some ZIP test sources and should remain an explicit review item rather than being silently reconstructed.
- Reference/vendor headers must not be “cleaned up” in a way that removes their attribution. Any comment-only cleanup must be limited, UTF-8-safe, and behavior-neutral.

## 11. Proposed post-audit portfolio structure

This was the structure selected for the next organization phase; it is based on actual dependencies rather than a mechanical copy of a template:

```text
rtl/
├── top/
│   ├── vision/                  # image-side top-level integration
│   └── robotic_arm/             # Cyclone IV arm-side top-level integration
├── camera/ov5640/               # OV5640 capture/configuration
├── vision/
│   ├── color_space/
│   ├── segmentation/
│   ├── morphology/
│   ├── connected_components/
│   ├── feature_extraction/
│   └── angle_estimation/
├── memory/axi_ddr3/             # AXI/controller wrapper and FIFO boundary
├── display/hdmi/                # VGA/HDMI timing and TMDS
├── inter_board/spi/             # arm-side SPI bridge
├── robotic_arm/
│   ├── kinematics/
│   ├── placement/
│   ├── control/
│   └── servo/
└── vendor/intel_ip/             # generated IP/config/data, clearly labeled
sim/
├── vision/
└── robotic_arm/
docs/
├── repository_audit.md
├── rtl_review.md
├── technical_report.pdf
├── competition_presentation.pdf
└── github_metadata.md
media/
third_party/
hardware/quartus/
archive/
```

The structure intentionally keeps the algorithmic RTL visible while making reference/vendor material and the original full snapshot easy to identify.

## 12. Audit decision

The repository is suitable for a documentation-and-organization pass, not for an algorithm rewrite or a claim of clean standalone reproducibility. The next pass may rename/move files, import the selected arm-side source, add documentation, add semantic media names, and make narrowly scoped comment/encoding cleanup. It must not change RTL behavior, repair the review findings, remove original materials, or claim personal authorship where the evidence is incomplete.

## 13. Post-audit organization record

The organization pass following this audit performed the following bounded operations:

- Moved the original `new/` RTL into functional `rtl/` subtrees with `git mv`; moved the image, PDFs, and ZIP with `git mv` as well.
- Imported 35 non-backup arm/SPI/top RTL and test sources from the extracted ZIP for browsing. The ZIP's duplicate/reference `rtl/Top/ov5640_hdmi.v` was not duplicated into the active tree because the repository already has the visible image-side wrapper; it remains available in the unchanged archive.
- Imported 31 selected arm-side IP/configuration files byte-for-byte into `rtl/vendor/intel_ip/` and `hardware/quartus/`. Quartus build databases, waveforms, reports, programming images, and `.bak` files remain archive-only.
- Normalized visible hand-maintained RTL/test text to UTF-8/LF and removed trailing whitespace without changing the comment-stripped RTL token stream. The generated `Line_Shift_RAM_1Bit.v`, vendor/IP subtree, and Quartus snapshot were preserved as supplied.
- Added the portfolio README, attribution ledger, GitHub metadata proposal, review notes, ignore/attribute rules, and archive/configuration explanations.

The final state still requires owner confirmation for personal contribution claims, the active inverse-kinematics alternative, and the missing project/IP files identified in `docs/rtl_review.md`.
