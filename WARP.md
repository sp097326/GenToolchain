# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

Marsdev is a cross-platform toolchain for Sega Mega Drive / Super 32X / Sharp X68000 development. It provides GCC-based m68k and sh toolchains, along with SGDK (Sega Genesis Development Kit) for high-level Genesis/Mega Drive programming.

## Common Development Commands

### Toolchain Build & Setup
```bash
# Build core m68k toolchain (required)
make m68k-toolchain

# Build with Newlib support (optional)
make m68k-toolchain-newlib

# Build for 32X development (sh toolchain)
make sh-toolchain

# Build SGDK (requires Java)
make sgdk

# Install toolchain system-wide
sudo make install

# Source environment (after installation)
source /opt/toolchains/mars/mars.sh
```

### Project Development
```bash
# Create new SGDK project
./create_sgdk_project.sh my_game

# Build ROM (in project directory)
make                # or make release
make debug         # build with debug symbols
make clean         # remove build files
make test          # build and show ROM info
make run           # build and run in emulator (if available)

# Working with examples
cd examples/sgdk-skeleton
make
```

### Key File Operations
```bash
# Check ROM file details
file rom.bin
ls -lh *.bin

# Test ROM in emulator
fusion rom.bin      # if Fusion installed
gens rom.bin        # if Gens installed
```

## Architecture & Code Structure

### Toolchain Architecture
- **m68k-elf toolchain**: Primary 68000 compiler for Genesis/Mega Drive
- **sh-elf toolchain**: SuperH compiler for 32X coprocessors
- **SGDK**: High-level C framework with VDP, joypad, sound APIs
- **Boot system**: Genesis ROMs require specific startup code and ROM headers

### Project Structure Pattern
```
project_name/
├── main.c                  # Main program entry point
├── Makefile               # Build configuration with SGDK paths
├── boot/                  # Genesis boot files (required)
│   ├── rom_head.c        # ROM header definition
│   └── sega.s            # Genesis startup assembly
├── src/                  # Additional source files
├── inc/                  # Project include files
├── res/                  # Resources (.res files for ResComp)
└── out/                  # Build intermediate files
```

### SGDK Framework Components
- **VDP (Video Display Processor)**: Graphics, sprites, backgrounds
- **Joypad System**: Controller input handling
- **Sound System**: PSG, FM, PCM audio
- **DMA**: Direct memory access for data transfer
- **Resource Compiler**: Converts assets to Genesis format

### Build Process Flow
1. **ROM Header**: `rom_head.c` compiled to `rom_head.bin`
2. **Boot Assembly**: `sega.s` assembled with startup vectors
3. **Main Program**: C sources compiled with SGDK headers
4. **Linking**: ELF creation with SGDK libraries (`libmd.a`, `libgcc.a`)
5. **ROM Generation**: Binary conversion for Genesis format

## Development Environment Notes

### Path Configuration
The toolchain uses hardcoded paths relative to `/Users/amanzanilla/Desktop/retrodev/marsdev`. Projects reference:
- `SGDK_PATH = ../sgdk`
- `MARSDEV_PATH = ../m68k-gcc-toolchain/work`

### Key Directories
- `examples/`: Various skeleton projects and samples
- `sgdk/`: SGDK framework installation
- `test_program/`: Working reference implementation
- `m68k-gcc-toolchain/`: GCC toolchain build directory

### Dependencies
- **System**: `build-essential`, `texinfo`, `wget`
- **SGDK**: Java JRE (OpenJDK 11+)
- **macOS**: Xcode command line tools, Homebrew

### Makefile Patterns
Projects use consistent Makefile structure:
- Separate debug/release builds
- Automatic source file detection in `src/`
- Resource compilation support
- Standard clean/test targets

## Emulator Integration
- **Fusion**: Recommended Genesis emulator
- **Gens**: Classic Genesis emulator
- **Real Hardware**: Flash cart compatibility
- ROM files are standard `.bin` format

## Resource Management
- Place `.res` files in `res/` directory
- Use SGDK's ResComp for asset conversion
- Include generated headers in source code
- Graphics: tiles, sprites, palettes
- Audio: PSG, FM synthesis, PCM samples

## Troubleshooting Common Issues
- **Java dependency**: SGDK build requires JRE installation
- **Missing boot files**: Copy from SGDK samples or use project generator
- **Path issues**: Ensure SGDK and toolchain paths match project structure
- **Assembly errors**: Verify `rom_head.bin` exists before assembling `sega.s`
- **Linker errors**: Check SGDK library paths and `md.ld` linker script
