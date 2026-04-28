#!/bin/bash

# ReverseKit File Collection Script
# Collects ALL files with line counts (no filtering)

OUTPUT_FILE=".reversekit/scan/raw_data.json"

echo "🔍 Collecting file list..."

# Create output directory
mkdir -p .reversekit/scan

# Exclude patterns (non-source directories)
EXCLUDE_PATTERNS=(
    -path "*/node_modules/*"
    -o -path "*/__pycache__/*"
    -o -path "*/.git/*"
    -o -path "*/venv/*"
    -o -path "*/env/*"
    -o -path "*/.venv/*"
    -o -path "*/dist/*"
    -o -path "*/build/*"
    -o -path "*/.next/*"
    -o -path "*/target/*"
    -o -path "*/.gradle/*"
    -o -path "*/.idea/*"
    -o -path "*/.vscode/*"
    -o -path "*/coverage/*"
    -o -path "*/.pytest_cache/*"
    -o -path "*/.mypy_cache/*"
    -o -path "*/vendor/*"
)

# Find all files (excluding directories above)
echo "  Scanning directories..."
FILES=$(find . -type d \( "${EXCLUDE_PATTERNS[@]}" \) -prune -o -type f -print | grep -v "^\./\." | sort)

if [ -z "$FILES" ]; then
    echo "❌ No files found"
    exit 1
fi

FILE_COUNT=$(echo "$FILES" | wc -l)
echo "  Found $FILE_COUNT files"

# Build JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"scan_date\": \"$(date -I)\"," >> "$OUTPUT_FILE"
echo "  \"total_files\": $FILE_COUNT," >> "$OUTPUT_FILE"
echo "  \"files\": [" >> "$OUTPUT_FILE"

# Process each file
COUNTER=0
echo "$FILES" | while IFS= read -r file; do
    COUNTER=$((COUNTER + 1))
    
    # Count lines (handle binary files gracefully)
    if file "$file" | grep -q "text"; then
        LINES=$(wc -l < "$file" 2>/dev/null || echo 0)
    else
        LINES=0
    fi
    
    # Clean path (remove leading ./)
    CLEAN_PATH="${file#./}"
    
    # Add comma if not first entry
    if [ $COUNTER -gt 1 ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    
    # Write file entry
    echo -n "    {\"path\": \"$CLEAN_PATH\", \"lines\": $LINES}" >> "$OUTPUT_FILE"
    
    # Progress indicator
    if [ $((COUNTER % 100)) -eq 0 ]; then
        echo "  Processed $COUNTER files..."
    fi
done

# Close JSON
echo "" >> "$OUTPUT_FILE"
echo "  ]" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

echo "✅ File collection complete: $OUTPUT_FILE"
echo "  Total files: $FILE_COUNT"
