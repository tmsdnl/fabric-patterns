#!/bin/bash

# Script to create a new pattern or strategy based on templates
# Created on $(date)

# Source and destination directories
PROJECT_DIR="$(dirname "$0")"
FABRIC_CONFIG_DIR="$HOME/.config/fabric"

# Show usage
show_usage() {
  echo "Usage: $0 [pattern|strategy] [name]"
  echo
  echo "Options:"
  echo "  -h, --help    Show this help message and exit"
  echo
  echo "Arguments:"
  echo "  pattern|strategy    Type of item to create (required)"
  echo "  name                Name of the pattern/strategy (optional, will prompt if not provided)"
  echo
  echo "Examples:"
  echo "  $0 pattern          # Create a new pattern (will prompt for name)"
  echo "  $0 pattern \"Code Review\"  # Create a new pattern named 'code_review'"
  echo "  $0 strategy         # Create a new strategy (will prompt for name)"
}

# Convert spaces to underscores and lowercase
format_name() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'
}

# Create a new item (pattern or strategy)
create_item() {
  local item_type="$1"
  local display_name="$2"
  local formatted_name=$(format_name "$display_name")
  
  # Validate item type
  if [[ "$item_type" != "pattern" && "$item_type" != "strategy" ]]; then
    echo "Error: Invalid item type. Must be 'pattern' or 'strategy'."
    show_usage
    exit 1
  fi
  
  # Source template directory
  local template_dir=""
  if [[ "$item_type" == "pattern" ]]; then
    template_dir="$FABRIC_CONFIG_DIR/patterns/official_pattern_template"
    dest_dir="$PROJECT_DIR/patterns/$formatted_name"
  else
    template_dir="$FABRIC_CONFIG_DIR/strategies/official_strategy_template"
    dest_dir="$PROJECT_DIR/strategies/$formatted_name"
  fi
  
  # Check if template exists
  if [[ ! -d "$template_dir" ]]; then
    echo "Error: Template directory not found: $template_dir"
    echo "Make sure Fabric is properly installed and templates are available."
    exit 1
  fi
  
  # Check if destination directory already exists
  if [[ -d "$dest_dir" ]]; then
    echo "Error: $item_type '$formatted_name' already exists at $dest_dir"
    exit 1
  fi
  
  # Create destination parent directory if it doesn't exist
  if [[ "$item_type" == "pattern" ]]; then
    mkdir -p "$PROJECT_DIR/patterns"
  else
    mkdir -p "$PROJECT_DIR/strategies"
  fi
  
  # Copy template to destination
  cp -R "$template_dir" "$dest_dir"
  echo "Created new $item_type: $formatted_name at $dest_dir"
  
  echo
  echo "Next steps:"
  echo "1. Edit the files in $dest_dir to customize your $item_type"
  echo "2. Run ./update.sh to install it to your Fabric configuration"
  echo "3. Test it with: fabric -r $formatted_name"
}

# Main execution
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_usage
  exit 0
fi

# Check for required item type argument
if [[ $# -lt 1 ]]; then
  echo "Error: Missing item type (pattern or strategy)"
  show_usage
  exit 1
fi

item_type="$1"
shift

# Get name from remaining arguments or prompt
if [[ $# -ge 1 ]]; then
  # Combine all remaining arguments as the name
  item_name="$*"
else
  read -p "Enter name for the new $item_type: " item_name
  
  # Validate input
  if [[ -z "$item_name" ]]; then
    echo "Error: Name cannot be empty"
    exit 1
  fi
fi

# Create the item
create_item "$item_type" "$item_name"