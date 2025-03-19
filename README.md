
# Fabric

A collection of custom patterns and configurations for use with [Fabric CLI](https://github.com/danielmiessler/fabric).

## Setup Instructions

### Prerequisites

- [Fabric CLI](https://github.com/danielmiessler/fabric) installed
- Git (for cloning this repository)

### Option 1: Setup with Fabric CLI

```bash
# Install Fabric CLI if not already installed
brew install danielmiessler/fabric/fabric

# Setup custom patterns repository
fabric -S

# Choose [11] Custom Patterns Repository
# Provide repository URL: https://github.com/tmsdnl/fabric.git
# Provide folder name if different from patterns

# Verify installation by listing the latest patterns
fabric -n 10

# Alternative verification
ls ~/.config/fabric/patterns

# Update patterns from configured repository when needed
fabric -U
```

### Option 2: Manual Setup with update.sh

The repository includes an `update.sh` script for directly managing Fabric configuration files.

#### Basic Usage

```bash
# Clone this repository
git clone https://github.com/tmsdnl/fabric.git
cd fabric

# Copy all patterns to ~/.config/fabric
./update.sh

# Get help information
./update.sh --help
```

#### Selective Updates

```bash
# Copy only the patterns directory
./update.sh patterns

# Copy specific files
./update.sh patterns/create_recognition/system.md

# Copy multiple items
./update.sh patterns strategies
```

## Usage

### Using Custom Patterns

```bash
# List available patterns
fabric -p

# Run a specific pattern (e.g., create_recognition)
fabric -r create_recognition

# Run a pattern with input
fabric -r create_recognition -i "Engineer's name and achievements..."
```

### Features

- **Specialized Patterns**: Custom patterns for specific use cases like technical recognition
- **Update Script Features**:
  - **Preview changes**: See exactly what will be created, updated, or left unchanged
  - **Confirmation**: Asks for confirmation before making any changes
  - **Selective copying**: Copy only the folders or files you specify
  - **Safe updates**: Detects and highlights only the files that need updating

## Available Patterns

- **create_recognition**: Helps craft thoughtful recognition statements for engineers based on their contributions and impact

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.