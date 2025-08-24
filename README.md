


<!--
	This project is licensed under the Apache License, Version 2.0.
	See the LICENSE file for details.
	Developer: Erivaldo Jair Xavier Mate
-->

# erim-cmake-configs

**Developer:** Erivaldo Jair Xavier Mate

**License:** Apache License 2.0 — see LICENSE for details.

**Attribution:** If you use or redistribute this project, you must retain the copyright and license notice as required by the Apache License 2.0.

> **Reusable CMake and code style configuration for your C++ projects**

---

## Overview

This repository provides:

- **Scripts** for copyless hardlinking of configuration files into your project directories
- **CMake presets** and toolchain files for standardized builds
- **.clang-format** for consistent C/C++ code style

---

## Scripts

| Script         | Platform         | Description                                      |
| -------------- | ---------------- | ------------------------------------------------ |
| `load.sh`      | Linux/macOS      | Bash script for hardlinking config files          |
| `load.ps1`     | Windows (PS)     | PowerShell version of `load.sh`                   |
| `load.cmd`     | Windows (CMD)    | Batch version of `load.sh`                        |

---

## Usage

1. **Navigate to your target project directory** (where you want the config files to appear):
	 ```sh
	 cd path/to/your/project
	 ```
2. **Run the appropriate script from the erim-cmake-configs folder:**

	 - **Bash (Linux/macOS):**
		 ```sh
		 ../erim-cmake-configs/load.sh
		 ```
	 - **PowerShell (Windows):**
		 ```powershell
		 ..\erim-cmake-configs\load.ps1
		 ```
	 - **Command Prompt (Windows):**
		 ```cmd
		 ..\erim-cmake-configs\load.cmd
		 ```

> **Note:**
> - The scripts create copyless hardlinks (not symbolic links or file copies) for files that do not already exist in the current directory.
> - If a file with the same name exists, it will be skipped or may cause an error, depending on your platform and permissions.

---

## Configuration Files

- **CMakePresets.json** and **erim-toolchain.cmake**: Provide CMake configuration and toolchain settings for your projects.
- **.clang-format**: Defines code formatting rules for C/C++ source files. Use the scripts above to hardlink it into your project for consistent style.

---

## Customization

Feel free to modify any scripts or configuration files to suit your workflow.
