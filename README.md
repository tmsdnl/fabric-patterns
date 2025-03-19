
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

### Option 2: Manual Setup with Included Scripts

The repository includes utility scripts for managing Fabric configuration files.

#### Using fabric-sync.sh

The `fabric-sync.sh` script helps install patterns and strategies to your Fabric configuration.

```bash
# Clone this repository
git clone https://github.com/tmsdnl/fabric-patterns.git
cd fabric-patterns

# Copy all patterns to ~/.config/fabric
./fabric-sync.sh

# Get help information
./fabric-sync.sh --help
```

#### Selective Updates

```bash
# Copy only the patterns directory
./fabric-sync.sh patterns

# Copy specific files
./fabric-sync.sh patterns/create_recognition/system.md

# Copy multiple items
./fabric-sync.sh patterns strategies
```

#### Using create.sh

The `create.sh` script helps create new patterns or strategies from templates.

```bash
# Create a new pattern (will prompt for name)
./create.sh pattern

# Create a new pattern with specified name
./create.sh pattern "Code Review"

# Create a new strategy
./create.sh strategy "Custom Strategy"

# Get help information
./create.sh --help
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
- **Create Script Features**:
  - **Easy creation**: Quickly create new patterns or strategies with proper naming
  - **Template-based**: Uses Fabric's official templates as starting points
  - **Naming convention**: Automatically formats names with underscores
- **Update Script Features**:
  - **Preview changes**: See exactly what will be created, updated, or left unchanged
  - **Confirmation**: Asks for confirmation before making any changes
  - **Selective copying**: Copy only the folders or files you specify
  - **Safe updates**: Detects and highlights only the files that need updating

## Available Patterns

- **create_recognition**: Helps craft thoughtful recognition statements for engineers based on their contributions and impact
- **content_classifier**: Classifies content into various categories to help with organization and understanding
- **summarize_topics**: Analyzes text to identify and summarize multiple topics or provide a structured summary of a single topic

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.