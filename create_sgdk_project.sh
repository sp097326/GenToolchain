#!/bin/bash

# SGDK/Marsdev Project Generator
# Creates new Sega Genesis development projects with proper structure
# Based on working test_program template

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/test_program"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <project_name> [project_directory]"
    echo ""
    echo "Creates a new SGDK/Marsdev project with proper structure and configuration."
    echo ""
    echo "Arguments:"
    echo "  project_name      Name of the new project (required)"
    echo "  project_directory Directory where to create the project (optional, defaults to current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 my_game                    # Creates my_game/ in current directory"
    echo "  $0 my_game ~/projects/        # Creates my_game/ in ~/projects/"
    echo "  $0 my_game /path/to/projects/ # Creates my_game/ in specified path"
    echo ""
    echo "The script will create:"
    echo "  - Project directory with proper structure"
    echo "  - Configured Makefile"
    echo "  - SGDK boot files (sega.s, rom_head.c)"
    echo "  - Sample main.c with Hello World"
    echo "  - Documentation files"
}

# Function to validate project name
validate_project_name() {
    local name="$1"
    
    # Check if name is empty
    if [[ -z "$name" ]]; then
        print_error "Project name cannot be empty"
        return 1
    fi
    
    # Check if name contains only valid characters (alphanumeric, underscore, hyphen)
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Project name can only contain letters, numbers, underscores, and hyphens"
        return 1
    fi
    
    # Check if name starts with a letter or underscore
    if [[ ! "$name" =~ ^[a-zA-Z_] ]]; then
        print_error "Project name must start with a letter or underscore"
        return 1
    fi
    
    return 0
}

# Function to create project structure
create_project_structure() {
    local project_path="$1"
    local project_name="$2"
    
    print_status "Creating project structure..."
    
    # Create main project directory
    mkdir -p "$project_path"
    
    # Create subdirectories
    mkdir -p "$project_path/boot"
    mkdir -p "$project_path/src"
    mkdir -p "$project_path/inc"
    mkdir -p "$project_path/res"
    
    print_success "Project structure created"
}

# Function to copy template files
copy_template_files() {
    local project_path="$1"
    local project_name="$2"
    
    print_status "Copying template files..."
    
    # Check if template directory exists
    if [[ ! -d "$TEMPLATE_DIR" ]]; then
        print_error "Template directory not found: $TEMPLATE_DIR"
        print_error "Make sure this script is in the marsdev directory alongside test_program/"
        return 1
    fi
    
    # Copy boot files
    if [[ -f "$TEMPLATE_DIR/boot/sega.s" ]]; then
        cp "$TEMPLATE_DIR/boot/sega.s" "$project_path/boot/"
        print_status "Copied boot/sega.s"
    else
        print_warning "Template boot/sega.s not found, you'll need to copy it manually"
    fi
    
    if [[ -f "$TEMPLATE_DIR/boot/rom_head.c" ]]; then
        cp "$TEMPLATE_DIR/boot/rom_head.c" "$project_path/boot/"
        print_status "Copied boot/rom_head.c"
    else
        print_warning "Template boot/rom_head.c not found, you'll need to copy it manually"
    fi
    
    # Copy and customize main.c
    create_main_c "$project_path" "$project_name"
    
    # Copy Makefile and customize it
    create_makefile "$project_path" "$project_name"
    
    print_success "Template files copied and customized"
}

# Function to create customized main.c
create_main_c() {
    local project_path="$1"
    local project_name="$2"
    
    cat > "$project_path/main.c" << EOF
#include "genesis.h"

// $project_name - Sega Genesis Game
// Created with SGDK/Marsdev Project Generator

int main(bool hardReset) {
    // Suppress unused parameter warning
    (void)hardReset;
    
    // Initialize VDP
    VDP_setScreenWidth320();
    VDP_setScreenHeight224();
    
    // Set background color to blue
    VDP_setBackgroundColor(1);
    
    // Display project name and welcome message
    VDP_drawText("$project_name", 2, 2);
    VDP_drawText("Sega Genesis Development", 2, 4);
    VDP_drawText("Built with SGDK", 2, 5);
    VDP_drawText("", 2, 7);
    VDP_drawText("Press START to begin!", 2, 9);
    
    // Main game loop
    while(TRUE) {
        // Read controller input
        u16 joy = JOY_readJoypad(JOY_1);
        
        // Example: Exit message on START button
        if (joy & BUTTON_START) {
            VDP_clearText(2, 9, 20);
            VDP_drawText("START pressed!", 2, 9);
        }
        
        // Process VBlank
        SYS_doVBlankProcess();
    }
    
    return 0;
}
EOF
    
    print_status "Created customized main.c"
}

# Function to create customized Makefile
create_makefile() {
    local project_path="$1"
    local project_name="$2"
    
    cat > "$project_path/Makefile" << EOF
# $project_name - SGDK/Marsdev Makefile
# Generated by SGDK Project Generator

SGDK_PATH = ../sgdk
MARSDEV_PATH = ../m68k-gcc-toolchain/work

# Compiler and tools
CC = \$(MARSDEV_PATH)/bin/m68k-elf-gcc
AS = \$(MARSDEV_PATH)/bin/m68k-elf-as
LD = \$(MARSDEV_PATH)/bin/m68k-elf-ld
OBJCOPY = \$(MARSDEV_PATH)/bin/m68k-elf-objcopy
RESCOMP = java -jar \$(SGDK_PATH)/bin/rescomp.jar
SJASM = \$(SGDK_PATH)/bin/sjasm

# Paths
INC_PATH = \$(SGDK_PATH)/SGDK/inc
RES_PATH = \$(SGDK_PATH)/SGDK/res
LIB_PATH = \$(SGDK_PATH)/SGDK/lib

# Flags
CFLAGS = -m68000 -Wall -Wextra -std=c99 -ffreestanding -nostdlib -fomit-frame-pointer -I\$(INC_PATH) -I\$(RES_PATH) -Iinc
LDFLAGS = -T \$(SGDK_PATH)/SGDK/md.ld -nostdlib
LIBS = \$(LIB_PATH)/libmd.a \$(LIB_PATH)/libgcc.a

# Source files
SOURCES = main.c
SOURCES += \$(wildcard src/*.c)
OBJECTS = \$(SOURCES:.c=.o) boot/sega.o
TARGET = $project_name.bin
ELF_TARGET = $project_name.elf

# Build output directory
OUT = out

.PHONY: all clean test debug release run

all: release

release: \$(TARGET)

debug: CFLAGS += -DDEBUG=1 -g
debug: LIBS = \$(LIB_PATH)/libmd_debug.a \$(LIB_PATH)/libgcc.a
debug: \$(TARGET)

\$(OUT):
	mkdir -p \$(OUT)

\$(TARGET): \$(ELF_TARGET)
	\$(OBJCOPY) -O binary \$< \$@
	@echo "ROM built successfully: \$(TARGET)"
	@ls -la \$(TARGET)

\$(ELF_TARGET): \$(OBJECTS)
	\$(LD) \$(LDFLAGS) \$(OBJECTS) \$(LIBS) -o \$@

# Build boot files
\$(OUT)/rom_head.bin: \$(OUT)/rom_head.o | \$(OUT)
	\$(OBJCOPY) -O binary \$< \$@

\$(OUT)/rom_head.o: boot/rom_head.c | \$(OUT)
	\$(CC) \$(CFLAGS) -c \$< -o \$@

boot/sega.o: boot/sega.s \$(OUT)/rom_head.bin
	\$(CC) -x assembler-with-cpp -Wa,--register-prefix-optional,--bitwise-or \$(CFLAGS) -c \$< -o \$@

%.o: %.c
	\$(CC) \$(CFLAGS) -c \$< -o \$@

src/%.o: src/%.c
	@mkdir -p \$(dir \$@)
	\$(CC) \$(CFLAGS) -c \$< -o \$@

clean:
	rm -f \$(OBJECTS) \$(ELF_TARGET) \$(TARGET)
	rm -rf \$(OUT)
	find . -name "*.o" -delete

test: \$(TARGET)
	@echo "=== $project_name Build Test ==="
	@echo "ROM file: \$(TARGET)"
	@file \$(TARGET) 2>/dev/null || echo "ROM file created successfully"
	@echo "Size: \$(shell ls -lh \$(TARGET) | awk '{print \$5}')"
	@echo "Ready for emulator testing!"

# Run in Fusion emulator (if available)
run: \$(TARGET)
	@if command -v fusion &> /dev/null; then \\
		echo "Running \$(TARGET) in Fusion emulator..."; \\
		fusion \$(TARGET); \\
	else \\
		echo "Fusion emulator not found. ROM ready at: \$(TARGET)"; \\
	fi

help:
	@echo "$project_name - SGDK/Marsdev Project"
	@echo ""
	@echo "Available targets:"
	@echo "  all/release - Build optimized ROM (default)"
	@echo "  debug      - Build debug ROM with symbols"
	@echo "  clean      - Remove build files"
	@echo "  test       - Build and show ROM info"
	@echo "  run        - Build and run in emulator (if available)"
	@echo "  help       - Show this help"
	@echo ""
	@echo "Project structure:"
	@echo "  main.c     - Main program entry point"
	@echo "  src/       - Additional source files"
	@echo "  inc/       - Project include files"
	@echo "  res/       - Resources (graphics, sound)"
	@echo "  boot/      - SGDK boot files"

.DEFAULT_GOAL := all
EOF
    
    print_status "Created customized Makefile"
}

# Function to create project documentation
create_documentation() {
    local project_path="$1"
    local project_name="$2"
    
    # Create README.md with proper variable substitution
    cat > "$project_path/README.md" << EOF
# ${project_name}

A Sega Genesis/Mega Drive game developed with SGDK (Sega Genesis Development Kit) and the Marsdev toolchain.

## Project Structure

\`\`\`
${project_name}/
├── main.c              # Main program entry point
├── Makefile           # Build configuration
├── README.md          # This file
├── src/               # Additional source files
├── inc/               # Project include files
├── res/               # Resources (graphics, sound, music)
├── boot/              # SGDK boot files
│   ├── rom_head.c     # ROM header definition
│   └── sega.s         # Genesis startup assembly
└── out/               # Build output directory
\`\`\`

## Building

### Prerequisites

- SGDK (Sega Genesis Development Kit)
- Marsdev m68k-gcc toolchain
- Make

### Build Commands

\`\`\`bash
# Build optimized ROM
make

# Build debug version
make debug

# Clean build files
make clean

# Test build and show info
make test

# Run in emulator (if available)
make run

# Show help
make help
\`\`\`

### Output

- \`${project_name}.bin\` - Sega Genesis ROM file
- \`${project_name}.elf\` - ELF executable with debug symbols

## Development

### Adding New Source Files

1. Place \`.c\` files in the \`src/\` directory
2. Place \`.h\` files in the \`inc/\` directory
3. The Makefile will automatically include them

### Adding Resources

1. Place resource files (\`.res\`) in the \`res/\` directory
2. Use SGDK's ResComp tool to process them
3. Include generated headers in your code

### SGDK Documentation

- [SGDK Documentation](https://github.com/Stephane-D/SGDK/wiki)
- [SGDK API Reference](https://github.com/Stephane-D/SGDK/blob/master/inc/genesis.h)

## Testing

Test your ROM using:
- **Fusion** - Recommended Genesis emulator
- **Gens** - Classic Genesis emulator  
- **Real hardware** - Via flash cart

## Generated by SGDK Project Generator

This project was created using the SGDK/Marsdev project generator script.
EOF

    # Create .gitignore
    cat > "$project_path/.gitignore" << EOF
# Build outputs
*.bin
*.elf
*.o
*.lst
*.d
out/

# Debug files
*.out
*.nm
*.wch
symbol.txt

# IDE files
*.cbp
.vscode/
.idea/

# macOS
.DS_Store

# Backup files
*~
*.bak
*.tmp
EOF

    print_status "Created project documentation"
}

# Function to create sample resource file
create_sample_resources() {
    local project_path="$1"
    local project_name="$2"
    
    # Create a simple .gitkeep file in directories
    touch "$project_path/src/.gitkeep"
    touch "$project_path/inc/.gitkeep"
    touch "$project_path/res/.gitkeep"
    
    # Create sample include file
    cat > "$project_path/inc/game.h" << EOF
#ifndef GAME_H
#define GAME_H

#include "genesis.h"

// $project_name - Game definitions and prototypes

// Game constants
#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 224

// Function prototypes
void game_init(void);
void game_update(void);
void game_draw(void);

#endif // GAME_H
EOF

    print_status "Created sample resource files"
}

# Main function
main() {
    local project_name="$1"
    local target_dir="${2:-.}"  # Default to current directory if not specified
    
    # Show usage if no arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # Show help if requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Validate project name
    if ! validate_project_name "$project_name"; then
        exit 1
    fi
    
    # Resolve target directory
    target_dir=$(realpath "$target_dir")
    local project_path="$target_dir/$project_name"
    
    # Check if project directory already exists
    if [[ -d "$project_path" ]]; then
        print_error "Project directory already exists: $project_path"
        print_error "Please choose a different name or remove the existing directory"
        exit 1
    fi
    
    # Check if target directory is writable
    if [[ ! -w "$target_dir" ]]; then
        print_error "Cannot write to target directory: $target_dir"
        exit 1
    fi
    
    print_status "Creating new SGDK project: $project_name"
    print_status "Target directory: $project_path"
    
    # Create project
    create_project_structure "$project_path" "$project_name"
    copy_template_files "$project_path" "$project_name"
    create_documentation "$project_path" "$project_name"
    create_sample_resources "$project_path" "$project_name"
    
    # Final success message
    echo ""
    print_success "Project '$project_name' created successfully!"
    echo ""
    echo "Next steps:"
    echo "  cd $project_path"
    echo "  make          # Build the ROM"
    echo "  make test     # Test the build"
    echo ""
    echo "Project files:"
    echo "  📁 $project_path/"
    echo "  📄 main.c              - Main program"
    echo "  📄 Makefile           - Build configuration"  
    echo "  📄 README.md          - Project documentation"
    echo "  📁 src/               - Additional source files"
    echo "  📁 inc/               - Include files"
    echo "  📁 res/               - Resources"
    echo "  📁 boot/              - SGDK boot files"
    echo ""
    echo "Happy Genesis development! 🎮"
}

# Run main function with all arguments
main "$@"
