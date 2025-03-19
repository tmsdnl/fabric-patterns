#!/bin/bash

# Script to copy folders and files to ~/.config/fabric with confirmation
# Created on $(date)

# Source and destination directories
SOURCE_DIR="$(dirname "$0")"
DEST_DIR="$HOME/.config/fabric"

# Global arrays for tracking changes
to_create=()
to_update=()
unchanged=()

# Function to check files that will be updated, created, or remain unchanged
check_changes() {
  local src="$1"
  local dst="$2"
  # Use global arrays
  to_create=()
  to_update=()
  unchanged=()
  
  # For directories, check each file inside
  if [ -d "$src" ]; then
    # Handle empty directories
    if [ -z "$(ls -A "$src")" ]; then
      if [ ! -d "$dst" ]; then
        to_create+=("$dst (empty directory)")
      fi
      return
    fi
    
    # Check if destination directory exists
    if [ ! -d "$dst" ]; then
      to_create+=("$dst (directory)")
      # Also add the content of the directory
      for subitem in "$src"/*; do
        if [ -e "$subitem" ]; then
          local subitem_name=$(basename "$subitem")
          local dst_subitem="$dst/$subitem_name"
          if [ -d "$subitem" ]; then
            check_changes "$subitem" "$dst_subitem"
          else
            to_create+=("$dst_subitem")
          fi
        fi
      done
      return
    fi
    
    for item in "$src"/*; do
      if [ -e "$item" ]; then
        local item_name=$(basename "$item")
        local dst_item="$dst/$item_name"
        
        if [ -d "$item" ]; then
          # Create the destination directory for comparison if it doesn't exist
          [ ! -d "$dst_item" ] && to_create+=("$dst_item (directory)")
          # Recursively check the subdirectory
          check_changes "$item" "$dst_item"
        else
          if [ ! -e "$dst_item" ]; then
            to_create+=("$dst_item")
          elif [ "$(stat -f "%m" "$item")" -gt "$(stat -f "%m" "$dst_item")" ]; then
            to_update+=("$dst_item")
          else
            unchanged+=("$dst_item")
          fi
        fi
      fi
    done
  else
    # For single files
    if [ ! -e "$dst" ]; then
      to_create+=("$dst")
    elif [ "$(stat -f "%m" "$src")" -gt "$(stat -f "%m" "$dst")" ]; then
      to_update+=("$dst")
    else
      unchanged+=("$dst")
    fi
  fi
}

# Function to copy a single item (file or directory)
copy_item() {
  local src="$1"
  local dst_dir="$2"
  local item_name=$(basename "$src")
  local dst="$dst_dir/$item_name"
  
  # Create destination directory if it doesn't exist
  mkdir -p "$dst_dir"
  
  if [ -d "$src" ]; then
    # For directories, copy recursively
    if [ -z "$(ls -A "$src")" ]; then
      # Handle empty directories
      mkdir -p "$dst"
      echo "Created empty directory: $dst"
    else
      if [ ! -d "$dst" ]; then
        mkdir -p "$dst"
      fi
      cp -R "$src/"* "$dst/"
      echo "Copied directory: $src → $dst"
    fi
  else
    # For files, simple copy
    cp "$src" "$dst"
    echo "Copied file: $src → $dst"
  fi
}

# Process all items to copy if no specific items are provided
process_all() {
  # Use the global arrays
  all_changes_to_create=()
  all_changes_to_update=()
  all_changes_unchanged=()
  
  echo "Scanning for changes..."
  echo
  
  # Find all directories in the source directory (exclude hidden directories)
  for item in "$SOURCE_DIR"/*/; do
    if [ -d "$item" ]; then
      local item_name=$(basename "$item")
      
      # Skip hidden directories
      if [[ "$item_name" != .* ]]; then
        local dst_dir="$DEST_DIR/$item_name"
        # Reset arrays
        to_create=()
        to_update=()
        unchanged=()
        
        check_changes "$item" "$dst_dir"
        
        # Add to global arrays
        for i in "${to_create[@]}"; do
          [[ -n "$i" ]] && all_changes_to_create+=("$i")
        done
        for i in "${to_update[@]}"; do
          [[ -n "$i" ]] && all_changes_to_update+=("$i")
        done
        for i in "${unchanged[@]}"; do
          [[ -n "$i" ]] && all_changes_unchanged+=("$i")
        done
      fi
    fi
  done
  
  # Summary of changes
  echo "Changes summary:"
  echo "-----------------"
  
  if [ ${#all_changes_to_create[@]} -gt 0 ]; then
    echo "Items to be created (${#all_changes_to_create[@]}):"
    for item in "${all_changes_to_create[@]}"; do
      echo "  - $item"
    done
    echo
  else
    echo "No new items will be created."
    echo
  fi
  
  if [ ${#all_changes_to_update[@]} -gt 0 ]; then
    echo "Items to be updated (${#all_changes_to_update[@]}):"
    for item in "${all_changes_to_update[@]}"; do
      echo "  - $item"
    done
    echo
  else
    echo "No items will be updated."
    echo
  fi
  
  if [ ${#all_changes_unchanged[@]} -gt 0 ]; then
    echo "Items that are unchanged (${#all_changes_unchanged[@]}):"
    for item in "${all_changes_unchanged[@]}"; do
      echo "  - $item"
    done
    echo
  fi
  
  # Ask for confirmation
  if [ ${#all_changes_to_create[@]} -eq 0 ] && [ ${#all_changes_to_update[@]} -eq 0 ]; then
    echo "No changes to make. Exiting."
    exit 0
  fi
  
  read -p "Do you want to proceed with these changes? (y/n): " confirm
  if [[ "$confirm" != [yY]* ]]; then
    echo "Operation cancelled."
    exit 0
  fi
  
  # Process the copy operations
  echo
  echo "Copying items..."
  for dir in "$SOURCE_DIR"/*/; do
    if [ -d "$dir" ]; then
      local dir_name=$(basename "$dir")
      
      # Skip hidden directories
      if [[ "$dir_name" != .* ]]; then
        copy_item "$dir" "$DEST_DIR"
      fi
    fi
  done
  
  echo "Update complete. Fabric configuration files have been copied to $DEST_DIR"
}

# Process specific items
process_specific_items() {
  local items=("$@")
  local all_changes_to_create=()
  local all_changes_to_update=()
  local all_changes_unchanged=()
  
  echo "Scanning specified items for changes..."
  echo
  
  for relative_path in "${items[@]}"; do
    local full_path="$SOURCE_DIR/$relative_path"
    
    if [ ! -e "$full_path" ]; then
      echo "Error: Item does not exist: $relative_path"
      continue
    fi
    
    # Calculate destination path
    local parent_dir=$(dirname "$relative_path")
    local item_name=$(basename "$relative_path")
    local dst_dir="$DEST_DIR/$parent_dir"
    local dst_path="$dst_dir/$item_name"
    
    # If it's the direct child of source dir, place it directly in DEST_DIR
    if [ "$parent_dir" = "." ]; then
      dst_dir="$DEST_DIR"
      dst_path="$DEST_DIR/$item_name"
    fi
    
    # Reset arrays
    to_create=()
    to_update=()
    unchanged=()
    
    check_changes "$full_path" "$dst_path"
    
    # Add to global arrays
    for i in "${to_create[@]}"; do
      [[ -n "$i" ]] && all_changes_to_create+=("$i")
    done
    for i in "${to_update[@]}"; do
      [[ -n "$i" ]] && all_changes_to_update+=("$i")
    done
    for i in "${unchanged[@]}"; do
      [[ -n "$i" ]] && all_changes_unchanged+=("$i")
    done
  done
  
  # Summary of changes
  echo "Changes summary for specified items:"
  echo "-----------------------------------"
  
  if [ ${#all_changes_to_create[@]} -gt 0 ]; then
    echo "Items to be created (${#all_changes_to_create[@]}):"
    for item in "${all_changes_to_create[@]}"; do
      echo "  - $item"
    done
    echo
  else
    echo "No new items will be created."
    echo
  fi
  
  if [ ${#all_changes_to_update[@]} -gt 0 ]; then
    echo "Items to be updated (${#all_changes_to_update[@]}):"
    for item in "${all_changes_to_update[@]}"; do
      echo "  - $item"
    done
    echo
  else
    echo "No items will be updated."
    echo
  fi
  
  if [ ${#all_changes_unchanged[@]} -gt 0 ]; then
    echo "Items that are unchanged (${#all_changes_unchanged[@]}):"
    for item in "${all_changes_unchanged[@]}"; do
      echo "  - $item"
    done
    echo
  fi
  
  # Ask for confirmation
  if [ ${#all_changes_to_create[@]} -eq 0 ] && [ ${#all_changes_to_update[@]} -eq 0 ]; then
    echo "No changes to make. Exiting."
    exit 0
  fi
  
  read -p "Do you want to proceed with these changes? (y/n): " confirm
  if [[ "$confirm" != [yY]* ]]; then
    echo "Operation cancelled."
    exit 0
  fi
  
  # Process the copy operations
  echo
  echo "Copying specified items..."
  for relative_path in "${items[@]}"; do
    local full_path="$SOURCE_DIR/$relative_path"
    
    if [ ! -e "$full_path" ]; then
      continue # Already reported error above
    fi
    
    # Calculate destination directory
    local parent_dir=$(dirname "$relative_path")
    
    # If it's the direct child of source dir, place it directly in DEST_DIR
    if [ "$parent_dir" = "." ]; then
      copy_item "$full_path" "$DEST_DIR"
    else
      # Create the parent directory structure in destination
      mkdir -p "$DEST_DIR/$parent_dir"
      copy_item "$full_path" "$DEST_DIR/$parent_dir"
    fi
  done
  
  echo "Update complete. Fabric configuration files have been copied to $DEST_DIR"
}

# Show usage
show_usage() {
  echo "Usage: $0 [OPTION] [items...]"
  echo
  echo "Options:"
  echo "  -h, --help    Show this help message and exit"
  echo
  echo "If no items are specified, all folders in the current directory will be processed."
  echo "Otherwise, only the specified items (files or directories) will be processed."
  echo
  echo "Examples:"
  echo "  $0                    # Process all folders"
  echo "  $0 patterns           # Process only the 'patterns' directory"
  echo "  $0 patterns/foo.md    # Process only the file 'foo.md' in the 'patterns' directory"
  echo "  $0 patterns strategies # Process 'patterns' and 'strategies' directories"
}

# Main execution
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_usage
  exit 0
fi

if [ $# -eq 0 ]; then
  # No arguments, process all folders
  process_all
else
  # Process specific items
  process_specific_items "$@"
fi