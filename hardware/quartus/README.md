# Quartus Project Snapshot

This directory contains the small, human-readable project/configuration subset extracted from `archive/CICC_2025_Arm.zip`:

- `CICC_2025_Arm.qsf` identifies a Cyclone IV E `EP4CE6F17C8L` target and top-level entity `CICC_2025_Arm`.
- `CICC_2025_Arm.qpf` and `CICC_2025_Arm.qws` are the accompanying Quartus project files.
- `atan2.qsys` and `atan2.sopcinfo` are the archived CORDIC/atan2 component descriptors.

This is a project snapshot, not a claim of a clean standalone build. The QSF retains original relative paths and references `rtl/Top/CICC_2025_Arm_prime.v` and `rtl/arm/catch/inverse_kinematics.v`, which were absent from the extracted ZIP. Generated databases, programming images, reports, waveform files, and other build products remain only in the unchanged original archive.

The active browsable RTL and the generated IP wrappers are separated so that a recruiter can inspect the design without mistaking generated files for hand-written project logic.

