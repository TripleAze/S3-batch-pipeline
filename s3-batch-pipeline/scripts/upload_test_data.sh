#!/bin/bash
set -e
# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Creating test objects..."
echo "test content 1" > test-object-1.txt
echo "test content 2" > test-object-2.txt

echo "Uploading to S3..."
aws s3 cp test-object-1.txt s3://state-bucket-abu-source-2025/test-object-1.txt
aws s3 cp test-object-2.txt s3://state-bucket-abu-source-2025/test-object-2.txt

# Upload manifest from project root or current dir
if [ -f "$PROJECT_ROOT/manifest.csv" ]; then
    echo "Found manifest in project root."
    aws s3 cp "$PROJECT_ROOT/manifest.csv" s3://state-bucket-abu-source-2025/manifest.csv
elif [ -f "manifest.csv" ]; then
    echo "Found manifest in current directory."
    aws s3 cp manifest.csv s3://state-bucket-abu-source-2025/manifest.csv
else
    echo "Error: manifest.csv not found!"
    exit 1
fi

echo "Upload complete!"
rm test-object-1.txt test-object-2.txt
