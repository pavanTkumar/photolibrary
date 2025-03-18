#!/bin/bash
# Save this script as fix_plugins.sh in your Flutter project directory
# Make it executable with: chmod +x fix_plugins.sh
# Run it with: ./fix_plugins.sh

# Get the path to the pub cache
PUB_CACHE_DIR="$HOME/.pub-cache/hosted/pub.dev"

# Find all plugin build.gradle files
echo "Finding Flutter plugins that might need namespace fixes..."
PLUGIN_FILES=$(find $PUB_CACHE_DIR -name "build.gradle" -type f)

# Counter for modified files
MODIFIED_COUNT=0

# Process each build.gradle file
for file in $PLUGIN_FILES; do
  # Check if the file already has a namespace declaration
  if ! grep -q "namespace" "$file"; then
    # Get the plugin's package from AndroidManifest.xml
    MANIFEST_DIR=$(dirname "$file")
    MANIFEST_PATH="$MANIFEST_DIR/src/main/AndroidManifest.xml"
    
    if [ -f "$MANIFEST_PATH" ]; then
      PACKAGE=$(grep -o 'package="[^"]*"' "$MANIFEST_PATH" | cut -d'"' -f2)
      
      if [ ! -z "$PACKAGE" ]; then
        echo "Adding namespace '$PACKAGE' to $file"
        
        # Use sed to add namespace line after "android {" line
        if [[ "$OSTYPE" == "darwin"* ]]; then
          # macOS sed requires an empty string for -i
          sed -i '' "/android {/a\\
    namespace '$PACKAGE'
" "$file"
        else
          # Linux sed
          sed -i "/android {/a\\    namespace '$PACKAGE'" "$file"
        fi
        
        MODIFIED_COUNT=$((MODIFIED_COUNT + 1))
      else
        echo "Warning: Could not find package in AndroidManifest.xml for $file"
      fi
    else
      echo "Warning: Could not find AndroidManifest.xml for $file"
    fi
  fi
done

echo "Completed! Modified $MODIFIED_COUNT plugin build.gradle files."
echo "Now run 'flutter clean' and then 'flutter run' to rebuild your app."