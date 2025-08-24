<!--
	This project is licensed under the Apache License, Version 2.0.
	See the LICENSE file for details.
	Developer: Erivaldo Jair Xavier Mate
-->

# erim-cmake-configs

**Developer:** Erivaldo Jair Xavier Mate

**License:** Apache License 2.0 — see LICENSE for details.

**Attribution:** If you use or redistribute this project,
you must retain the copyright and license notice as 
required by the Apache License 2.0.

---

## Scripts

| Script      | Platform         | Description                               |
| ------------| ---------------- | ----------------------------------------- |
| `load.sh`   | Linux/macOS      | Bash script for hardlinking config files  |
| `load.ps1`  | Windows (PS)     | PowerShell version of `load.sh`           |
| `load.cmd`  | Windows (CMD)    | Batch version of `load.sh`                |

---

## Usage

> - First go to your project directory then run the script

> - If a file with the same name exists, it will be skipped or cause an error.

---

## Configuration Files

- **CMakePresets.json** and **erim-toolchain.cmake**: Provide CMake configuration and toolchain settings for your projects.
- **.clang-format**: Defines code formatting rules for C/C++ source files. Use the scripts above to hardlink it into your project for consistent style.

---

## Customization

Feel free to modify any scripts or configuration files to suit your workflow.
