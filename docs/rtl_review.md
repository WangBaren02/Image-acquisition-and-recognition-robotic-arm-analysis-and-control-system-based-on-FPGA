# RTL Review Notes

This file records static review findings observed during the portfolio audit. It is intentionally not a bug-fix log: no finding below was changed during this organization pass, and none should be presented as a confirmed functional bug without simulation or owner review.

The paths below use the post-organization layout. Line numbers refer to the current source snapshot and may move as comments or documentation evolve.

## Image-side integration review items

| Priority | Location | Observation | Status |
|---|---|---|---|
| P0 / build dependency | [`rtl/top/vision/ov5640_hdmi.v`](../rtl/top/vision/ov5640_hdmi.v) | The visible image-side top instantiates `clk_wiz_0` and `clk_wiz_1`; the matching Xilinx-generated clock IP is not present in the visible repository tree. The same top also depends on the DDR/MIG integration supplied outside the tracked RTL. | Needs the original FPGA project/IP set before a clean build can be claimed. |
| P0 / build dependency | [`rtl/memory/axi_ddr3/axi_ctrl.v`](../rtl/memory/axi_ddr3/axi_ctrl.v), [`rtl/vision/connected_components/connect_8_area.v`](../rtl/vision/connected_components/connect_8_area.v) | The code instantiates `wr_fifo`, `rd_fifo`, and `fifo_640x1`, but the matching generated FIFO sources are not present in the visible source set. | Dependency inventory only; not repaired. |
| P1 / interface width | [`rtl/top/vision/ov5640_hdmi.v`](../rtl/top/vision/ov5640_hdmi.v), [`rtl/top/vision/connect_component_top.v`](../rtl/top/vision/connect_component_top.v) | The top-level `ram_wr_data` port is 24 bits while the connected `connect_component_top` signal is declared as 30 bits. This deserves owner review for truncation/extension intent. | Review candidate; no width change made. |
| P1 / external IP | [`rtl/vision/angle_estimation/angle_find.v`](../rtl/vision/angle_estimation/angle_find.v) | The active divider instance is named `divide_angle` and uses `.aclk(aclk)`, while no `aclk` declaration is visible in this module. The divider IP source is absent from the visible image-side tree. | Review candidate; no instance or clock change made. |
| P1 / expression semantics | [`rtl/vision/angle_estimation/angle_find.v`](../rtl/vision/angle_estimation/angle_find.v) | Conditions such as `x_h_max - 4 < x_cent < x_h_max + 4` use chained-comparison notation. Verilog expression semantics should be checked against the intended interval test. | Review candidate; no algorithm change made. |
| P2 / duplicate definition | [`rtl/vision/connected_components/connect_8_area.v`](../rtl/vision/connected_components/connect_8_area.v) and [`rtl/vision/connected_components/legacy/connect_8_area_legacy.v`](../rtl/vision/connected_components/legacy/connect_8_area_legacy.v) | Both files retain a module named `connect_8_area`. The legacy copy is kept for provenance and must not be compiled in the same file list as the active copy unless the project deliberately selects one. | Documented duplicate; no module rename made. |
| P2 / simulation reproducibility | [`sim/vision/sim_sobel_tb.v`](../sim/vision/sim_sobel_tb.v) | The testbench opens a BMP using a hard-coded Windows path under `F:\FPGA-EP4CE10F17C8\...` and depends on external image/IP files. | Portability issue; no testbench behavior change made. |

## Robotic-arm-side review items

| Priority | Location | Observation | Status |
|---|---|---|---|
| P0 / project snapshot | [`hardware/quartus/CICC_2025_Arm.qsf`](../hardware/quartus/CICC_2025_Arm.qsf) | The archived QSF references `rtl/Top/CICC_2025_Arm_prime.v` and `rtl/arm/catch/inverse_kinematics.v`, but those files are absent from the extracted ZIP. | Missing-source evidence recorded; no substitute selected. |
| P1 / coordinate arithmetic | [`rtl/top/robotic_arm/send_location.v`](../rtl/top/robotic_arm/send_location.v) | The `arm_Y` assignment contains a term derived from `VIP_X[9:7]` even though the surrounding comment describes the Y-coordinate mapping. It may be intentional or may warrant review against the coordinate model. | Review candidate; no arithmetic change made. |
| P1 / width consistency | [`rtl/top/robotic_arm/CICC_2025_Arm.v`](../rtl/top/robotic_arm/CICC_2025_Arm.v), [`rtl/top/robotic_arm/send_location.v`](../rtl/top/robotic_arm/send_location.v), [`rtl/robotic_arm/control/robotic_arm_low_clk.v`](../rtl/robotic_arm/control/robotic_arm_low_clk.v) | The inspected arm-side connections include a 9-bit Y-coordinate path and a narrower `wire [7:0] Y` declaration in the top-level snapshot. The intended truncation/extension should be checked with the original project owner. | Review candidate; no port or signal-width change made. |
| P1 / implementation selection | [`rtl/robotic_arm/kinematics/inverse_kinematics_time.v`](../rtl/robotic_arm/kinematics/inverse_kinematics_time.v), [`rtl/robotic_arm/kinematics/inverse_kinematics_cordic.v`](../rtl/robotic_arm/kinematics/inverse_kinematics_cordic.v) | The ZIP contains time-based and CORDIC inverse-kinematics alternatives, while the available QSF source list does not make the intended active path unambiguous. | Documentation/owner decision needed; neither alternative was removed. |

## Repository-level verification limits

- The ZIP archive contains a Quartus 17.1 project, Intel/Altera generated IP, build databases, ModelSim artifacts, and backup files. The archive is preserved as an original snapshot; generated content was not promoted to an active build tree.
- The visible source set does not include a complete image-side Vivado/Quartus manifest, all generated clocks/FIFOs/MIG files, or a reproducible simulation file list.
- Mixed source encodings were present before reorganization. The organization pass may normalize text encoding and line endings, but it must preserve RTL tokens, interfaces, attribution headers, and source completeness.
- No timing, throughput, latency, resource utilization, FPS, CDC correctness, or fixed-point precision claim is considered verified by this static review.

## Scope rule for future fixes

Any functional correction should be made in a separate, explicitly reviewed change with a reproducible test or synthesis/simulation result. This portfolio pass leaves the findings above unchanged.
